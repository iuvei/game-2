--
-- Author: Anthony
-- Date: 2014-10-22 14:36:25
-- Filename: client_item.lua
--
----------------------------------------------------------------
local item_helper = require("app.mediator.item_helper")
local configMgr = require("config.configMgr")
----------------------------------------------------------------
local M = class("client_item")
----------------------------------------------------------------
function M:ctor(data)
    self.__data = nil
	self:set_data(data)
end
----------------------------------------
function M:get_data()
    return self.__data
end
----------------------------------------
function M:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function M:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function M:setkey( key, data )
    self.__data[key] = data
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function M:gen_new(olddata)
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
function M:get_info()
    local dataid = self:get( "dataId" )
	local conf = configMgr:getConfig("item")
	local conf_info = conf:get_info(dataid)
	local icon = conf:get_icon(dataid)

	local outinfo = {
	    dataId      = dataid,
        kindId      = math.floor(dataid/10000000),
	    GUID        = self:get( "GUID" ),
	    name        = conf_info.name,
	    desc        = conf_info.desc,
	    quality     = item_helper.get_serial_qualityId(dataid),
	    require_level = conf_info.Level,
	    money_type	= conf_info.MoneyType,
	    base_price  = conf_info.BasePrice,
	    icon       	= icon,
	    num			= self:get( "num" ),
	    -- layed_num	= conf_info.LayedNum,
	}
    return outinfo
end

----------------------------------------------------------------
return M