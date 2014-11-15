--
-- Author: Anthony
-- Date: 2014-10-15 20:22:54
--
local M = class("client_data_base")
----------------------------------------------------------------
function M:ctor()
	self.__data = nil
end
----------------------------------------
function M:getdata()
    return self.__data
end
----------------------------------------
function M:setdata( data )
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
    local newdata = {}
    return newdata
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function M:get_info()
    local outinfo = self:getdata()
    return outinfo
end
----------------------------------------------------------------
return M