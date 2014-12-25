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
        local buffer = cc.FileUtils:getInstance():getStringFromFile(v)
        protobuf.register(buffer)
        local path,name,suffix = string.match(v, "(.*/)(%w+).(%w+)")
        proto[name] = protobuf.decode("google.protobuf.FileDescriptorSet", buffer).file[1]
    end
end
register_files{"proto/packets.pb"}
------------------------------------------------------------------------------
-- local G = proto.packets.package
------------------------------------------------------------------------------
function packet_factory:init()
	self.proto_id = {}
	self.proto_name = {}
	self.proto_handle = {}

	local cmdInfo = require("app.packets.cmd")
	-- 注册所有包
	for k,v in ipairs(cmdInfo) do
		-- print(k,dump(v))
		self.proto_id[v.name] = v.id
		if self.proto_name[v.id] then
			error("had "..v.id.." "..v.name.." msg!!")
		end
		self.proto_name[v.id] = v.name

		-- 过滤client才使用handle
		if v.file and v.file ~= "" then
			self.proto_handle[v.id] =  require("app.packets."..v.file)
		end
	end

end

------------------------------------------------------------------------------
-- 打包 逻辑消息包
local function _pack(pbname, ... )
	return protobuf.encode(proto.packets.package.."."..pbname, ... or {})
end

function packet_factory:packet_pack(cmdname,...)
	local id = self.proto_id[cmdname]
	if id == nil then
		printError("packet_pack cmdname:%s Unregistered!",cmdname)
		return
	end
	return _pack("Packet", {cmd=id, body=_pack(cmdname, ...)} )
end
------------------------------------------------------------------------------
-- 解包 逻辑消息包
local function _unpack(pbname, body )
	return protobuf.decode(proto.packets.package.."."..pbname, body)
end

function packet_factory:packet_unpack(text)
	local packet = _unpack("Packet",text)
	local name = self.proto_name[packet.cmd]
	if name == nil then
		printError("packet_unpack cmdid:%d Unregistered!",packet.cmd)
		return
	end

	return packet.cmd,_unpack(name,packet.body)
end
------------------------------------------------------------------------------
-- handle execute
function packet_factory:execute_handle(player_instance,cmdid,text)
	-- local name = self.proto_name[cmdid]
	-- if name == nil then
	-- 	printError("packet_execute cmdid:%d Unregistered!",cmdid)
	-- 	return nil
	-- end
	if cmdid == nil then
		printError("packet_execute cmdid:%d Unregistered!",cmdid)
		return
	end

	return self.proto_handle[cmdid](player_instance,text)
end
------------------------------------------------------------------------------
return packet_factory