--
-- Author: Anthony
-- Date: 2014-10-13 16:02:15
-- equip
----------------------------------------------------------------
local configMgr = require("config.configMgr")
-- local game_attr = require("app.ac.game_attr")
local item_operator = require("app.mediator.item.item_operator")
----------------------------------------------------------------
local equip = class("equip")
----------------------------------------------------------------
function equip:ctor(data)
    self.__data = nil
	self:set_data(data)
end
----------------------------------------
function equip:get_data()
    return self.__data
end
----------------------------------------
function equip:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function equip:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function equip:setkey( key, data )
    self.__data[key] = data
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function equip:gen_new(olddata)
    return {
        GUID    = olddata.GUID,
        dataId  = olddata.dataId,
        num     = olddata.num,
        elevel  = olddata.elevel, -- enhanced level 强化等级
    }
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function equip:get_info()
    return item_operator:get_equip_info( self.__data )
end

----------------------------------------------------------------
return equip