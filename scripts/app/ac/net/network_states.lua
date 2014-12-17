--
-- Author: Anthony
-- Date: 2014-08-28 15:47:17
-- 客户端的连接状态，在这里具体处理连接逻辑
------------------------------------------------------------------------------
local crypt = require("crypt")
local timer = require("common.utils.Timer")
local cmd = require("app.packets.cmd")
------------------------------------------------------------------------------
local heartbeat_timeid = nil
------------------------------------------------------------------------------
local network_states = {}
------------------------------------------------------------------------------
local states_act = {}
------------------------------------------------------------------------------
network_states.ST = {
	S_NOT_CONNECT			= "S_NOT_CONNECT",
	-- LOGIN
	S_CONNECT_LOGIN			= "S_CONNECT_LOGIN",
	S_CONNECT_LOGIN_RET		= "S_CONNECT_LOGIN_RET",
	S_EXCHANGE_KEY			= "S_EXCHANGE_KEY",
	S_SCERET				= "S_SCERET",
	S_AUTH_BEGIN			= "S_AUTH_BEGIN",
	S_AUTH					= "S_AUTH",
	S_AUTH_END 				= "S_AUTH_END",
	S_ERROR 				= "S_ERROR",

	-- GAME SERVER
	S_CONNECT_GS			= "S_CONNECT_GS",
	S_CONNECT_GS_RET		= "S_CONNECT_GS_RET",
	S_GS_SEND_AUTH			= "S_GS_SEND_AUTH",
	S_GS_REV_AUTH			= "S_GS_REV_AUTH",
	S_GS_AUTH_END			= "S_GS_AUTH_END",

	S_GS_NORMAL				= "S_GS_NORMAL",
}
local ST = network_states.ST
------------------------------------------------------------------------------
local curstate = ST.S_NOT_CONNECT
------------------------------------------------------------------------------
-- LOGIN
function states_act.S_CONNECT_LOGIN(network,params)
	-- connect
	-- network._socket:connect(params.host, params.port)
end
------------------------------------------------------------------------------
function states_act.S_CONNECT_LOGIN_RET(network,params)
	network_states:change_state(network,ST.S_EXCHANGE_KEY)
end
------------------------------------------------------------------------------
function states_act.S_EXCHANGE_KEY(network,params)
		network.challenge = crypt.base64decode(params)
		network.clientkey = crypt.randomkey()
		-- print("clientkey"..network.clientkey)
		network:send(crypt.base64encode(crypt.dhexchange(network.clientkey)))

		network_states:change_state(network,ST.S_SCERET)
end
------------------------------------------------------------------------------
function states_act.S_SCERET(network,params)

	-- print("···",params,network.clientkey)
	network.secret = crypt.dhsecret(crypt.base64decode(params), network.clientkey)
	-- print("sceret is ", crypt.hexencode(network.secret))

	--
	local hmac = crypt.hmac64(network.challenge, network.secret)
	network:send(crypt.base64encode(hmac))

	-- send version for check
	-- like: version "1.0.0.0.21"
	network:send(crypt.base64encode(VERSION.."."..#cmd))

	network_states:change_state(network,ST.S_AUTH_BEGIN)
end
------------------------------------------------------------------------------
function states_act.S_AUTH_BEGIN(network,params)
	-- print("···",params)
	local code = tonumber(string.sub(params, 1, 3))
	if code ~= 201 then
		--
		network_states:onError(network, code)
		return
	end
	--
	local function encode_token(token)
		return  string.format("%s@%s:%s",
				crypt.base64encode(token.user),
				crypt.base64encode(token.server),
				crypt.base64encode(token.pass))
	end
	local etoken = crypt.desencode(network.secret, encode_token(token))
	-- local b = crypt.base64encode(etoken)
	network:send(crypt.base64encode(etoken))

	network_states:change_state(network,ST.S_AUTH)
end
------------------------------------------------------------------------------
function states_act.S_AUTH(network,params)

	-- auth ok
	local code = tonumber(string.sub(params, 1, 3))
	-- assert(code == 200)
	if code ~= 200 then
		network_states:onError(network, code)
		return
	end

	-- 取出发过来的gameserver的ip和port
	local result = crypt.base64decode(string.sub(params, 5))
	local subid, host, port  = result:match("([^@]+)@([^:]+):(.+)")

	network.subid = subid
	-- network.subid = crypt.base64decode(string.sub(params, 5))
	printLog("DEBUG","login ok, subid =%s host:%s port:%d", network.subid,host, port)

	-- 回调
	local f = network.CMD.onLoginSucc
	if f then
		f(network.subid)
	end

	token.gs_host = host
	token.gs_port = port
	network_states:change_state(network,ST.S_AUTH_END,{host= token.gs_host, port=token.gs_port})
end
------------------------------------------------------------------------------
function states_act.S_AUTH_END(network,params)
	-- print("S_AUTH_END")
end
------------------------------------------------------------------------------
-- GAME SERVER
-- 连接
function states_act.S_CONNECT_GS(network,params)
	-- KNMsg.getInstance():boxShow("连接服务器 "..params.host..":"..params.port, {
	-- 	confirmFun = function()
			-- connect to game server
			printLog("DEBUG","connect to game server host:%s port:%d",params.host,params.port)
			if network.index == nil then
				network.index = 0
			end
			network.index = network.index+1
			network:connect("gs_auth",params.host, params.port)
	-- 	end
	-- })
end
------------------------------------------------------------------------------
-- 连接成功
function states_act.S_CONNECT_GS_RET(network,params)
	network_states:change_state(network,ST.S_GS_SEND_AUTH,params)
end
------------------------------------------------------------------------------
function states_act.S_GS_SEND_AUTH(network,params)
	-- handshake
	-- base64(uid)@base64(server)#base64(subid):index:base64(hmac)
	local handshake = string.format("%s@%s#%s:%d", 	crypt.base64encode(token.user),
													crypt.base64encode(token.server),
													crypt.base64encode(network.subid),
													network.index)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), network.secret)

	network:send(handshake .. ":" .. crypt.base64encode(hmac))

	network_states:change_state(network,ST.S_GS_REV_AUTH)
end
------------------------------------------------------------------------------
function states_act.S_GS_REV_AUTH(network,params)
	--收到握手包
	local code = tonumber(string.sub(params, 1, 3))
	-- assert(code == 200)
	if code ~= 200 then
		network_states:onError(network, code)
		return
	end

	-- 改变打包收包方式
	network.command = "gs"
	network_states:change_state(network,ST.S_GS_AUTH_END,code)
end
------------------------------------------------------------------------------
function states_act.S_GS_AUTH_END(network,params)
	network_states:change_state(network,ST.S_GS_NORMAL)

	-- 开始定时发送心跳包
	network_states:new_heartbeat(network)

	-- 回调
	local f = network.CMD.onEnterSucc
	if f then
		f(network.subid)
	end
end
------------------------------------------------------------------------------
function states_act.S_ERROR(network,params)
end
------------------------------------------------------------------------------
function states_act.S_GS_NORMAL(network,params)
	-- print("ST.S_GS_NORMAL",ST.S_GS_NORMAL)

	-- dump(params)
	if params.ok then
		-- print("session:",params.session)
		network:decode_execute(params.session,params.content)
	else
		timer:kill(heartbeat_timeid)
		heartbeat_timeid = nil
		KNMsg.getInstance():boxShow("网络出现异常", {
				confirmFun = function()
					switchscene("login")
				end
			})
	end
end
------------------------------------------------------------------------------
-- network states
------------------------------------------------------------------------------
-- 分发
function network_states:dispatch(network, params )
	local f = states_act[curstate]
	if f then
		f(network,params)
	end
end
------------------------------------------------------------------------------
function network_states:change_state(network,state,params)
	printLog("DEBUG","change_state %s -> %s",curstate,state)
	curstate = state
	if params then
		self:dispatch(network, params )
	end
end
------------------------------------------------------------------------------
local socket = require "socket"
function network_states:new_heartbeat(network)

	-- network:encode_send("CSC_SysHeartBeat")
	-- 每5秒发一次心跳
	heartbeat_timeid = timer:start(function( dt, data, timerId)
		network.pingstartvalue = socket.gettime()
		network:encode_send("CSC_SysHeartBeat")
	end, 5)
end
------------------------------------------------------------------------------
function network_states:reset(network)
	network.secret = nil
	-- 错误就删除所有定时
	-- timer:killAll()
	timer:kill(heartbeat_timeid)
	heartbeat_timeid = nil
	network_states:change_state(network,ST.S_NOT_CONNECT)
	-- 断开网络
	network:disconnect()
	-- network_states:change_state(network,ST.S_ERROR)
end

------------------------------------------------------------------------------
function network_states:on_status(network,__event)
	if __event.name == "SOCKET_TCP_CONNECTED" then
		local state = curstate
		if curstate == ST.S_CONNECT_LOGIN then
			state = ST.S_CONNECT_LOGIN_RET
		elseif curstate == ST.S_CONNECT_GS then
			state = ST.S_CONNECT_GS_RET
		end

		network_states:change_state(network,state,__event)
	elseif __event.name == "SOCKET_TCP_CONNECT_FAILURE"
			or __event.name == "SOCKET_TCP_CLOSED" then
			-- print("···",curstate)

		if __event.name == "SOCKET_TCP_CLOSED" and ( curstate == ST.S_NOT_CONNECT ) then
			return
		end

		-- 完全断开后才开始连接gameserver。不然手机上会出问题！
		if __event.name == "SOCKET_TCP_CLOSED" and ( curstate == ST.S_AUTH_END ) then
			network_states:change_state(network,ST.S_CONNECT_GS,{host= token.gs_host, port=token.gs_port})
			return
		end

		self:reset(network)

		-- 回调
		local f = network.CMD.onError
		if f then
			f(__event.name)
		end
	end
end
------------------------------------------------------------------------------
function network_states:onError(network, code)

	local text = "state:"..network.command
	if network.command == "ls" then

		--[[
			400 Bad Request . 握手失败
			401 Unauthorized . 自定义的 auth_handler 不认可 token
			403 Forbidden . 自定义的 login_handler 执行失败
			406 Not Acceptable . 该用户已经在登陆中。（只发生在 multilogin 关闭时）
			200 OK
		]]
		if code == 400 then
			text = text .. ", Bad Request"
		elseif code == 401 then
			text = text .. ", Unauthorized"
		elseif code == 403 then
			text = text .. ", Forbidden"
		elseif code == 406 then
			text = text .. ", Not Acceptable"
		elseif code == 406 then
			text = text .. ", Not Acceptable"
		elseif code == 407 then
			-- text = text .. ", check version failed"
			text = "版本不对，请更新！"
		else
			text =  text..", "..code
		end
	elseif network.command == "gs_auth" then
		--[[
			404 User Not Found
			403 Index Expired
			401 Unauthorized
			400 Bad Request
			200 OK
		]]
		if code == 400 then
			text = text .. ", Bad Request"
		elseif code == 401 then
			text = text .. ", Unauthorized"
		elseif code == 403 then
			text = text .. ", Index Expired"
		elseif code == 404 then
			text = text .. ", User Not Found"
		else
			text = text..", "..code
		end
	end

	self:reset(network)

	-- 回调
	local f = network.CMD.onError
	if f then
		f(text)
	end
end
------------------------------------------------------------------------------
return network_states