--
-- Author: Anthony
-- Date: 2014-08-28 15:52:23
-- 网络包的处理：包括TCP粘包，解包，打包
------------------------------------------------------------------------------
local bit32 = require("common.utils.bit32")
local pf = import(".packetFactory")
------------------------------------------------------------------------------
local M = {}

local lastBuff = "" --上次剩余
------------------------------------------------------------------------------
-- login 发送接受格式
------------------------------------------------------------------------------
local function writeline(text)
	return text .. "\n"
end
------------------------------------------------------------------------------
--
local function unpack_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
local function unpack_f(text, f )
	local result
	result, lastBuff = f(lastBuff..text)
	return result
end

------------------------------------------------------------------------------
-- 登录game server握手包后，发送接收格式
------------------------------------------------------------------------------
-- game server 握手包特殊格式
local function send_package(text)
	local size = #text
	local package = string.char(bit32.extract(size,8,8))..
					string.char(bit32.extract(size,0,8))..
					text
	return package
end
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
-- 重置缓冲区
function M:resetLastBuff()
	lastBuff = ""
end
------------------------------------------------------------------------------
-- 打包
function M:pack( command,text )
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
		return send_request(text, self.session)
	else
		return nil
	end
end
------------------------------------------------------------------------------
--收包
function M:onData( command,text )
	-- print("net pack onData",command)
	if command == "ls" then -- 登录服务器的包
		return unpack_f(text,unpack_line)
	elseif command == "gs_auth" then -- 游戏服务器握手包
		return unpack_f(text,unpack_package)
	elseif command == "gs" then -- 游戏服务器的包
		return unpack_f(text,unpack_package)
	else
		return nil
	end
end
------------------------------------------------------------------------------
-- 解包
function M:unpack( command,text )
	if command == "gs" then -- 游戏服务器的包
		return recv_response(text)
	else
		return text
	end
end
------------------------------------------------------------------------------
--
function M:encode( cmdname, ... )
	return pf:packet_pack(cmdname, ... )
end
------------------------------------------------------------------------------
--
function M:decode_handle( ... )
	pf:packet_handle(pf:packet_unpack(...))
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------