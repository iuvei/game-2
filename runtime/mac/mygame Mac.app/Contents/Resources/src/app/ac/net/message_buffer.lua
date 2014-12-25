--
-- Author: Anthony
-- Date: 2014-08-28 15:52:23
-- 把底层网络包组成可用逻辑包，最终会让packet_factory解析成具体逻辑包
------------------------------------------------------------------------------
local bit32 = require("common.utils.bit32")
------------------------------------------------------------------------------
local message_buffer = {}

local last_buff = "" --上次剩余
------------------------------------------------------------------------------
--
------------------------------------
-- login 发送接受格式
local function writeline(text)
	return text .. "\n"
end
------------------------------------
-- 登陆到loginserver时用到
local function package_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

------------------------------------
-- 游戏服的包
local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end
------------------------------------
-- 得到一个完整的包
local function recv_package(text, f )
	local result
	result, last_buff = f(last_buff)
	if result then
		return result, last_buff
	end

	result, last_buff = f(last_buff..text)
	return result, last_buff
end

------------------------------------------------------------------------------
-- 登录game server握手包后，发送接收格式
------------------------------------
-- game server 握手包特殊格式
local function send_package(text)
	local size = #text
	local package = string.char(bit32.extract(size,8,8))..
					string.char(bit32.extract(size,0,8))..
					text
	return package
end
------------------------------------
-- game server 正常包格式
local function send_request(v, _session)
	local size = #v + 4
	local package = string.char(bit32.extract(size,8,8))..
					string.char(bit32.extract(size,0,8))..
					v..
					string.char(bit32.extract(_session,24,8))..
					string.char(bit32.extract(_session,16,8))..
					string.char(bit32.extract(_session,8,8))..
					string.char(bit32.extract(_session,0,8))
	return package
end
------------------------------------
-- game server 正常包格式
local function recv_response(v)
	local _content = v:sub(1,-6)
	local _ok = v:sub(-5,-5):byte()
	local _session = 0
	for i=-4,-1 do
		local c = v:byte(i)
		_session = _session + bit32.lshift(c,(-1-i) * 8)
	end
	return {ok = _ok ~=0 , content = _content, session = _session}
end
------------------------------------
-- 解数据包
local function _unpack( command,text )
	if command == "gs" then -- 游戏服务器的包
		return recv_response(text)
	else
		return text
	end
end
------------------------------------
local function _dispatch_package( command, text, package_fun, execute_fun )

	-- 执行到不能组成完整包
	local v = nil
	local last = text --第一次时用到
	while true do
		v, last = recv_package( last, package_fun )
		if not v then
			break
		end
		-- 执行
		execute_fun( _unpack( command, v ) )
	end
end
------------------------------------------------------------------------------
-- 对外函数
------------------------------------
-- 重置缓冲区
function message_buffer:reset_last_buff()
	last_buff = ""
	self.session = 0
end
------------------------------------
-- 收包，组包 并 执行包
function message_buffer:recv_data( command, text, execute_fun )
	-- print("message_buffer recv_data",command)
	local v = nil
	if command == "ls" then -- 登录服务器的包
		_dispatch_package( command, text, package_line, execute_fun )
	else--if command == "gs" then -- 游戏服务器握手包
		_dispatch_package( command, text, unpack_package, execute_fun )
	-- elseif command == "gs" then -- 游戏服务器的包
	-- 	self:dispatch_package( command, text, unpack_package, execute_fun )
	-- else
	-- 	return nil
	end
end
------------------------------------
-- 组成最终游戏数据包
function message_buffer:pack( command,text )
	if command == "ls" then -- 登录服务器的包
		return writeline(text)
	elseif command == "gs_auth" then -- 游戏服务器握手包格式
		return send_package(text)
	elseif command == "gs" then -- 游戏服务器的包
		if self.session == nil then
			self.session = 0
		end
		-- 发一次包增加一次
		self.session = self.session+1
		return send_request(text, self.session), self.session
	else
		return nil
	end
end
------------------------------------------------------------------------------
return message_buffer