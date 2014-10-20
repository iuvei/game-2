--
-- Author: Anthony
-- Date: 2014-08-29 10:46:48
--
------------------------------------------------------------------------------
require("common.pbc.protobuf")
local cmdInfo = import(".cmd")
------------------------------------------------------------------------------
local M = {}
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
function M:init()
	self.proto = {}

	-- -- 注册所有包
	for k,v in pairs(cmdInfo) do
		-- print(k,dump(v))
		self:register(v)
	end

end
------------------------------------------------------------------------------
function M:register(params)
	-- 过滤client才使用handle
	local proto = nil
	if params.handlefile and params.handlefile ~= "" then
		proto =  require("app.net"..params.handlefile)
	end

	self.proto[params.name] = {id=params.id,handle=proto}
end
------------------------------------------------------------------------------
function M:packet_pack(cmdname,...)

	local proto = self.proto[cmdname]
	if proto == nil then
		print("packet_pack cmdname",cmdname,"Unregistered! ")
		return nil
	end

	local function _pack(pbname, ... )
		return protobuf.encode(G.."."..pbname, ... or {})
	end
	return protobuf.pack(G..".Packet cmd body", proto.id, _pack(cmdname,...))
end
------------------------------------------------------------------------------
function M:packet_unpack(...)

	local cmdid, body = protobuf.unpack(G..".Packet cmd body", ...)

	local ci = cmdInfo[cmdid]
	if ci == nil then
		print("packet_unpack cmdid",cmdid,"Unregistered! ")
		return nil
	end

	local proto = self.proto[ci.name]
	if proto == nil then
		print("packet_unpack cmdid",ci.id,"name",ci.name,"Unregistered! ")
		return nil
	end

	local function _unpack(pbname,... )
		return protobuf.decode(G.."."..pbname,...)
	end
	return cmdid,_unpack(ci.name,body)
end
------------------------------------------------------------------------------
function M:packet_handle(cmdid,...)
	if cmdid == nil then
		return 0
	end

	local ci = cmdInfo[cmdid]
	if ci == nil then
		print("packet_handle cmdid",cmdid,"Unregistered! ")
		return 0
	end

	--TODO 加密
	local handle = self.proto[ci.name].handle
	if handle then
		return handle:handle(...)
	end
	handle = nil
end
------------------------------------------------------------------------------
M:init()
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------