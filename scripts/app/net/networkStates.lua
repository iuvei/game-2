--
-- Author: Anthony
-- Date: 2014-08-28 15:47:17
-- 客户端的连接状态，在这里具体处理连接逻辑
------------------------------------------------------------------------------
local timer = require("common.utils.Timer")
------------------------------------------------------------------------------
-- TODO token
token = {
	-- server = "gs101",
	-- user = "hello",
	-- pass = "password",
	-- gs_host = "127.0.0.1",
	-- gs_port = "8888",
}
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
local statesAct = {}
------------------------------------------------------------------------------
M.ST = {
	-- LOGIN
	S_CONNECT_LOGIN			= "S_CONNECT_LOGIN",
	S_CONNECT_LOGIN_RET		= "S_CONNECT_LOGIN_RET",
	S_EXCHANGE_KEY			= "S_EXCHANGE_KEY",
	S_SCERET				= "S_SCERET",
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
local ST = M.ST
------------------------------------------------------------------------------
local curstate = ST.S_CONNECT_LOGIN

------------------------------------------------------------------------------
-- 分发
function M:dispatch(parent, params )
	local f = statesAct[curstate]
	if f then
		f(parent,params)
	end
end
------------------------------------------------------------------------------
-- LOGIN
function statesAct.S_CONNECT_LOGIN(parent,params)
	-- connect
	-- parent._socket:connect(params.host, params.port)
end
------------------------------------------------------------------------------
function statesAct.S_CONNECT_LOGIN_RET(parent,params)
	M:ChangeState(parent,ST.S_EXCHANGE_KEY)
end
------------------------------------------------------------------------------
function statesAct.S_EXCHANGE_KEY(parent,params)
		parent.challenge = crypt.base64decode(params)
		parent.clientkey = crypt.randomkey()
		-- print("clientkey"..parent.clientkey)
		parent:send(crypt.base64encode(crypt.dhexchange(parent.clientkey)))

		M:ChangeState(parent,ST.S_SCERET)
end
------------------------------------------------------------------------------
function statesAct.S_SCERET(parent,params)

	-- print("···",params,parent.clientkey)
	parent.secret = crypt.dhsecret(crypt.base64decode(params), parent.clientkey)
	-- print("sceret is ", crypt.hexencode(parent.secret))

	--
	local hmac = crypt.hmac64(parent.challenge, parent.secret)
	parent:send(crypt.base64encode(hmac))

	--
	local function encode_token(token)
		return  string.format("%s@%s:%s",
				crypt.base64encode(token.user),
				crypt.base64encode(token.server),
				crypt.base64encode(token.pass))
	end
	local etoken = crypt.desencode(parent.secret, encode_token(token))
	-- local b = crypt.base64encode(etoken)
	parent:send(crypt.base64encode(etoken))

	M:ChangeState(parent,ST.S_AUTH)
end
------------------------------------------------------------------------------
function statesAct.S_AUTH(parent,params)
	-- server auth ok
	-- 断开连接
	-- parent:disconnect()

	local code = tonumber(string.sub(params, 1, 3))
	-- assert(code == 200)
	if code ~= 200 then
		M:onError(parent, code)
		return
	end

	-- 取出发过来的gameserver的ip和port
	local result = crypt.base64decode(string.sub(params, 5))
	local subid, host, port  = result:match("([^@]+)@([^:]+):(.+)")

	parent.subid = subid
	-- parent.subid = crypt.base64decode(string.sub(params, 5))
	print("login ok, subid =", parent.subid,host, port)

	-- 回调
	local f = parent.CMD.onLoginSucc
	if f then
		f(parent.subid)
	end

	token.gs_host = host
	token.gs_port = port
	M:ChangeState(parent,ST.S_AUTH_END,{host= token.gs_host, port=token.gs_port})
end
------------------------------------------------------------------------------
function statesAct.S_AUTH_END(parent,params)
	-- print("S_AUTH_END")
end
------------------------------------------------------------------------------
-- GAME SERVER
-- 连接
function statesAct.S_CONNECT_GS(parent,params)
	-- KNMsg.getInstance():boxShow("连接服务器 "..params.host..":"..params.port, {
	-- 	confirmFun = function()
			-- connect to game server
			print("connect to game server",params.host,params.port)
			if parent.index == nil then
				parent.index = 0
			end
			parent.index = parent.index+1
			parent:connect("gs_auth",params.host, params.port)
	-- 	end
	-- })
end
------------------------------------------------------------------------------
-- 连接
function statesAct.S_CONNECT_GS_RET(parent,params)
	M:ChangeState(parent,ST.S_GS_SEND_AUTH,params)
end
------------------------------------------------------------------------------
function statesAct.S_GS_SEND_AUTH(parent,params)
	-- handshake
	-- base64(uid)@base64(server)#base64(subid):index:base64(hmac)
	local handshake = string.format("%s@%s#%s:%d", 	crypt.base64encode(token.user),
													crypt.base64encode(token.server),
													crypt.base64encode(parent.subid),
													parent.index)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), parent.secret)

	parent:send(handshake .. ":" .. crypt.base64encode(hmac))

	M:ChangeState(parent,ST.S_GS_REV_AUTH)
end
------------------------------------------------------------------------------
function statesAct.S_GS_REV_AUTH(parent,params)
	--收到握手包
	local code = tonumber(string.sub(params, 1, 3))
	-- assert(code == 200)
	if code ~= 200 then
		M:onError(parent, code)
		return
	end

	-- 改变打包收包方式
	parent.command = "gs"
	M:ChangeState(parent,ST.S_GS_AUTH_END,code)
end
------------------------------------------------------------------------------
function statesAct.S_GS_AUTH_END(parent,params)
	M:ChangeState(parent,ST.S_GS_NORMAL)

	-- 开始定时发送心跳包
	timer:start(function( dt, data, timerId)
		NETWORK:encode_send("C2S_SysHeartBeat")
	end, 1)

	-- 回调
	local f = parent.CMD.onEnterSucc
	if f then
		f(parent.subid)
	end
end
------------------------------------------------------------------------------
function statesAct.S_ERROR(parent,params)
end
------------------------------------------------------------------------------
function statesAct.S_GS_NORMAL(parent,params)
	-- print("ST.S_GS_NORMAL",ST.S_GS_NORMAL)

	-- dump(params)
	if params.ok then
	-- params.session
		parent:decode_handle(params.content)
	else
		KNMsg.getInstance():boxShow("网络出现异常", {
				confirmFun = function()
					-- M:reset()
					switchscene("login")
				end
			})
	end
end
------------------------------------------------------------------------------
function M:ChangeState(parent,state,params)
	print("ChangeState",curstate,"->",state)
	curstate = state
	if params then
		self:dispatch(parent, params )
	end
end
------------------------------------------------------------------------------
function M:reset()
	-- 错误就删除所有定时
	timer:killAll()
	M:ChangeState(NETWORK,ST.S_CONNECT_LOGIN)
	-- 断开网络
	NETWORK:disconnect()
	-- M:ChangeState(parent,ST.S_ERROR)
end

------------------------------------------------------------------------------
function M:onStatus(parent,__event)
	if __event.name == "SOCKET_TCP_CONNECTED" then
		local state = curstate
		if curstate == ST.S_CONNECT_LOGIN then
			state = ST.S_CONNECT_LOGIN_RET
		elseif curstate == ST.S_CONNECT_GS then
			state = ST.S_CONNECT_GS_RET
		end

		M:ChangeState(parent,state,__event)
	elseif __event.name == "SOCKET_TCP_CONNECT_FAILURE"
			or __event.name == "SOCKET_TCP_CLOSED" then
			-- print("···",curstate)
		-- 完全断开后才开始连接gameserver。不然手机上会出问题！
		if __event.name == "SOCKET_TCP_CLOSED" and ( curstate == ST.S_AUTH_END ) then
			M:ChangeState(parent,ST.S_CONNECT_GS,{host= token.gs_host, port=token.gs_port})
			return
		end

		self:reset()

		-- 回调
		local f = parent.CMD.onError
		if f then
			f(__event.name)
		end
	end
end
------------------------------------------------------------------------------
function M:onError(parent, code)

	local text = parent.command
	if parent.command == "ls" then

		--[[
			400 Bad Request . 握手失败
			401 Unauthorized . 自定义的 auth_handler 不认可 token
			403 Forbidden . 自定义的 login_handler 执行失败
			406 Not Acceptable . 该用户已经在登陆中。（只发生在 multilogin 关闭时）
			200 OK
		]]
		if code == 400 then
			text = text .. ",Bad Request"
		elseif code == 401 then
			text = text .. ",Unauthorized"
		elseif code == 403 then
			text = text .. ",Forbidden"
		elseif code == 406 then
			text = text .. ",Not Acceptable"
		end
	elseif parent.command == "gs_auth" then
		--[[
			404 User Not Found
			403 Index Expired
			401 Unauthorized
			400 Bad Request
			200 OK
		]]
		if code == 400 then
			text = text .. ",Bad Request"
		elseif code == 401 then
			text = text .. ",Unauthorized"
		elseif code == 403 then
			text = text .. ",Index Expired"
		elseif code == 404 then
			text = text .. ",User Not Found"
		end
	end

	self:reset()

	-- 回调
	local f = parent.CMD.onError
	if f then
		f(text)
	end

	-- -- KNMsg:getInstance():flashShow(text)
	-- KNMsg.getInstance():boxShow("网络出现异常,code = "..parent.command..","..code , {
	-- 		confirmFun = function()
	-- 			M:ChangeState(parent,ST.S_CONNECT_LOGIN)
	-- 			-- switchScene("login")
	-- 		end
	-- 	})
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------