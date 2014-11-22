--
-- Author: Anthony
-- Date: 2014-08-29 10:46:48
-- packetFactory.lua
------------------------------------------------------------------------------
require("common.pbc.protobuf")
------------------------------------------------------------------------------
local packet_factory = {}
-- 创建一个消息工厂
function packet_factory.create( )
	local m = packet_factory
	m:init()
	return m
end
------------------------------------------------------------------------------
local proto = {}
------------------------------------------------------------------------------
local function register_files(files)
    for _,v in ipairs(files) do
        -- local addr = io.open(v, "rb")
        -- local buffer = addr:read"*a"
        -- addr:close()
        local buffer = CCFileUtils:sharedFileUtils():getFileData(v)
        protobuf.register(buffer)
        local path,name,suffix = string.match(v, "(.*/)(%w+).(%w+)")
        proto[name] = protobuf.decode("google.protobuf.FileDescriptorSet", buffer).file[1]
    end
end
register_files{"proto/packets.pb"}
------------------------------------------------------------------------------
local G = proto.packets.package
------------------------------------------------------------------------------
function packet_factory:init()
	self.proto = {}
	self.proto_id = {}

	local handle = nil

	local cmdInfo = require("app.packets.cmd")
	-- 注册所有包
	for k,v in pairs(cmdInfo) do
		-- print(k,dump(v))
		-- 过滤client才使用handle
		if v.handlefile and v.handlefile ~= "" then
			handle =  require("app.packets"..v.handlefile)
		end
		self.proto[v.name] = {id=v.id,handle=handle}
		self.proto_id[v.id] = v
	end

end

------------------------------------------------------------------------------
-- 打包 逻辑消息包
local function _pack(pbname, ... )
	return protobuf.encode(G.."."..pbname, ... or {})
end

function packet_factory:packet_pack(cmdname,...)
	local proto = self.proto[cmdname]
	if proto == nil then
		printError("packet_pack cmdname:%s Unregistered!",cmdname)
		return nil
	end
	return _pack("Packet", {cmd=proto.id, body=_pack(cmdname, ...)} )
end
------------------------------------------------------------------------------
-- 解包 逻辑消息包
local function _unpack(pbname, body )
	return protobuf.decode(G.."."..pbname, body)
end

function packet_factory:packet_unpack(text)
	local packet = _unpack("Packet",text)
	local ci = self.proto_id[packet.cmd]
	if ci == nil then
		printError("packet_unpack cmdid:%d Unregistered!",packet.cmd)
		return nil
	end

	return packet.cmd,_unpack(ci.name,packet.body)
end
------------------------------------------------------------------------------
-- handle execute
function packet_factory:get_handle(cmdid)
	local ci = self.proto_id[cmdid]
	if ci == nil then
		printError("packet_execute cmdid:%d Unregistered!",cmdid)
		return nil
	end

	return self.proto[ci.name].handle
end
------------------------------------------------------------------------------
return packet_factory