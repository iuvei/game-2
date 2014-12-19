--
-- Author: Anthony
-- Date: 2014-08-20 18:08:05
-- 通信接口
--
--                       _oo0oo_
--                      o8888888o
--                      88" . "88
--                      (| -_- |)
--                      0\  =  /0
--                    ___/`---'\___
--                  .' \\|     |-- '.
--                 / \\|||  :  |||-- \
--                / _||||| -:- |||||- \
--               |   | \\\  -  --/ |   |
--               | \_|  ''\---/''  |_/ |
--               \  .-\__  '-'  ___/-. /
--             ___'. .'  /--.--\  `. .'___
--          ."" '<  `.___\_<|>_/___.' >' "".
--         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--         \  \ `_.   \_ __\ /__ _/   .-` /  /
--     =====`-.____`.___ \_____/___.-`___.-'=====
--                       `=---='
--
--
--     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
--               佛祖保佑         永无BUG
--				 心外无法         法外无心
------------------------------------------------------------------------------
printInfo("----------------load network begin-----------------------")
cc.utils = require("framework.cc.utils.init")
cc.net	 = require("framework.cc.net.init")
local message_buffer 	= import(".message_buffer")
local states 			= import(".network_states")
local pf 				= import(".packet_factory").create()
------------------------------------------------------------------------------
--
printInfo("socket.getTime:%f", cc.net.SocketTCP.getTime())
printInfo("os.time:%f", os.time())
printInfo("socket._VERSION: %s", cc.net.SocketTCP._VERSION)
------------------------------------------------------------------------------
-- 该接口是全局变量
local network = {}
----------------------------
local player_instance = nil
------------------------------------------------------------------------------
function network:attach_player( player )
	player_instance = player
end
------------------------------------------------------------------------------
function network:connect(__command, __host, __port,conf)
	-- print("network:connect",__command, __host, __port)

	self:disconnect()

	-- 类型：ls：登录服务器,gs_auth：游戏服务器验证,gs：游戏服务器
	if __command == nil  then
		__command = "ls"
	end
	self.command = __command

	if self.CMD == nil then
		self.CMD = {
			onError 	= nil,
			onLoginSucc = nil,
			onEnterSucc = nil,
		}

		if conf then
			self.CMD.onError 	 = conf.onError
			self.CMD.onLoginSucc = conf.onLoginSucc
			self.CMD.onEnterSucc = conf.onEnterSucc
		end
	end

    --------------------------------------------------
    -- SocketTCP
	self._socket = cc.net.SocketTCP.new()
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.on_status))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.on_status))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.on_status))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.on_status))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.recv_data))

	-- 连接
	self._socket:connect(__host, __port,false)

	if self.command == "ls" then
		-- 连接loginserver 状态
		states:change_state(self,states.ST.S_CONNECT_LOGIN)
	end
end
------------------------------------------------------------------------------
function network:disconnect()
	if self._socket then
		-- 必须调用，断开
		self._socket:disconnect()
		self._socket = nil
		self.command = "ls"
	end
	message_buffer:reset_last_buff()
end
------------------------------------------------------------------------------
-- 重置
function network:reset()
	states:reset(self)
end
------------------------------------------------------------------------------
function network:send(_data,_command)
	if self._socket then
		local package, session = message_buffer:pack( _command or self.command,_data )
		self._socket:send( package )
		return session
	else
		-- 回调
		local f = self.CMD.onError
		if f then
			f("not_conneted")
			f = nil
		end
		return nil
	end
end
------------------------------------------------------------------------------
-- 加密发送, 与game server通讯时用到
function network:encode_send(cmdname,...)
	local text = pf:packet_pack(cmdname,...)
	if text then
		-- 加密
		text = crypt.desencode(self.secret, text)
		return self:send( text )
		-- print("----------------")
		-- print("encode_text is:", cc.utils.ByteArray.toString(text, 16))
	end
	return nil
end
------------------------------------------------------------------------------
-- 解密且处理 handle
function network:decode_execute(session, text)

	-- print("----------------")
	-- print("sceret is:", cc.utils.ByteArray.toString(self.secret, 16))
	-- print("decode_text is:", cc.utils.ByteArray.toString(text, 16))

	if text == nil or text == "" or self.secret == nil or self.secret == "" then
		-- 服务端只要有请求，服务端必定会有回馈，
		-- 如果服务端不处理，返回的text为空
		return
	end
	-- 解密
	text = crypt.desdecode(self.secret, text)
	return pf:execute_handle(player_instance,pf:packet_unpack(text))
end
------------------------------------------------------------------------------
function network:on_status(__event)
	printInfo("socket status: %s", __event.name)
	if __event.name == "SOCKET_TCP_CLOSED" then
		self._socket = nil
		message_buffer:reset_last_buff()
	end
	states:on_status(self,__event)
end

------------------------------------------------------------------------------
function network:recv_data(__event)
	-- print("socket receive raw data:", cc.utils.ByteArray.toString(__event.data, 16))

	-- 收包，组包 并 执行包
	message_buffer:recv_data( self.command,__event.data, function ( msg )
		--dispatch
		states:dispatch(self, msg )
	end)
end
------------------------------------------------------------------------------
printInfo("----------------load network end-----------------------")
return network