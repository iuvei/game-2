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
cc.utils = require("framework.cc.utils.init")
cc.net	 = require("framework.cc.net.init")
local crypt = require("crypt")
local netPack = import(".netPack")
local states = import(".networkStates")
------------------------------------------------------------------------------
printInfo("----------------load network begin-----------------------")
printInfo("socket.getTime:%f", cc.net.SocketTCP.getTime())
printInfo("os.gettime:%f", os.time())
printInfo("socket._VERSION: %s", cc.net.SocketTCP._VERSION)
printInfo("----------------load network end-----------------------")
------------------------------------------------------------------------------
-- 该接口是全局变量
local NETWORK = {}
------------------------------------------------------------------------------
function NETWORK:connect(__command, __host, __port,conf)
	-- print("NETWORK:connect",__command, __host, __port)

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
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))

	-- 连接
	self._socket:connect(__host, __port,false)
end
------------------------------------------------------------------------------
function NETWORK:disconnect()
	if self._socket then
		-- 必须调用，断开
		self._socket:disconnect()
		self._socket = nil
		self.command = "ls"
	end
	netPack:resetLastBuff()
end
------------------------------------------------------------------------------
-- 重置
function NETWORK:reset()
	states:reset()
end
------------------------------------------------------------------------------
function NETWORK:send(_data,_command)
	if self._socket then
		self._socket:send( netPack:pack( _command or self.command,_data ) )
	else
		-- 回调
		local f = self.CMD.onError
		if f then
			f("not_conneted")
		end
	end
end
------------------------------------------------------------------------------
-- 加密发送
function NETWORK:encode_send(cmdname,...)
	local encode = netPack:encode(cmdname,...)
	if encode then
		self:send( encode, _command)
	end
end
------------------------------------------------------------------------------
-- 解密且处理 handle
function NETWORK:decode_handle(...)
	return netPack:decode_handle(...)
end
------------------------------------------------------------------------------
function NETWORK:onStatus(__event)
	printInfo("socket status: %s", __event.name)
	if __event.name == "SOCKET_TCP_CLOSED" then
		self._socket = nil
		netPack:resetLastBuff()
	end
	states:onStatus(self,__event)
end

------------------------------------------------------------------------------
function NETWORK:onData(__event)
	-- print(states,"socket receive raw data:", cc.utils.ByteArray.toString(__event.data, 16))

	local result = netPack:onData( self.command,__event.data )
	if result == nil then
		-- 继续接收下个包
		print("NETWORK:onData need Complete package!!")
		return
	end
	-- 解包
	result = netPack:unpack( self.command,result )
	states:dispatch(self, result )
end
------------------------------------------------------------------------------
return NETWORK
------------------------------------------------------------------------------