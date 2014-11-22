--
-- Author: Anthony
-- Date: 2014-11-11 11:42:09
-- Filename: client_debris.lua
--
----------------------------------------------------------------
local item_helper = require("app.mediator.item_helper")
local configMgr = require("config.configMgr")
----------------------------------------------------------------
local client_debris = class("client_debris")
----------------------------------------------------------------
function client_debris:ctor(data)
    self.__data = nil
	self:set_data(data)
end
----------------------------------------
function client_debris:get_data()
    return self.__data
end
----------------------------------------
function client_debris:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function client_debris:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function client_debris:setkey( key, data )
    self.__data[key] = data
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function client_debris:gen_new(olddata)
    local newdata = {
        GUID    = olddata.GUID,
        dataId  = olddata.dataId,
        num 	= olddata.num
    }
    return newdata
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function client_debris:get_info()
    local dataid = self:get( "dataId" )
	local conf = configMgr:getConfig("debris")
	local conf_info = conf:get_info(dataid)

	local outinfo = {
	    dataId      = dataid,
        kindId      = item_helper.get_serial_classid(dataid),
	    GUID        = self:get( "GUID" ),
	    name        = conf_info.name,
	    desc        = conf_info.desc,
	    quality     = item_helper.get_serial_qualityId(dataid),
	    require_level = conf_info.Level,
	    money_type	= conf_info.MoneyType,
	    base_price  = conf_info.BasePrice,
	    icon       	= conf:get_icon(dataid),
	    num			= self:get( "num" ),
	}
    return outinfo
end

----------------------------------------------------------------
return client_debris