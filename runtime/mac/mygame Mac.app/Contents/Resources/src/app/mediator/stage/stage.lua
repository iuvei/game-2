--
-- Author: Anthony
-- Date: 2014-12-11 12:10:47
-- Filename: stage.lua
--
----------------------------------------------------------------
local stage = class("stage")
----------------------------------------------------------------
function stage:ctor(data)
    self.__data = nil
	self:set_data(data)
end
----------------------------------------
function stage:get_data()
    return self.__data
end
----------------------------------------
function stage:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function stage:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function stage:setkey( key, data )
    self.__data[key] = data
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function stage:gen_new(olddata)
    return {
        Id    	= olddata.Id,
        count  	= olddata.count,
        stars   = olddata.stars
    }
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function stage:get_info()
	return self.__data
end

----------------------------------------------------------------
return stage