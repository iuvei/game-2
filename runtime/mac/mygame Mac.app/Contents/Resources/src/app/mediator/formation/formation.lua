--
-- Author: Anthony
-- Date: 2014-10-13 16:02:15
-- 阵形数据
----------------------------------------------------------------
local M = class("formation")
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
    return {
        index   = olddata.index,
        GUID    = olddata.dataId,
        -- dataId  = olddata.dataId,
    }
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function M:get_info()
    return self:get_data()
end

----------------------------------------------------------------
return M