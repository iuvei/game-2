--
-- Author: Anthony
-- Date: 2014-10-22 14:37:14
-- Filename: mgr_gem.lua
--
local pairs = pairs
local table = table
----------------------------------------------------------------
local client_gem = import(".client_gem")
----------------------------------------------------------------
local M = class("mgr_gem")
----------------------------------------------------------------
function M:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function M:get_data()
    return self.__data
end
----------------------------------------
function M:set_data( data )
    table.walk(data, function(v, k)
        self.__data[v.GUID] = client_gem.new(v)
    end)

    -- print("---------set_gems")
    -- dump(self.__data)
end
----------------------------------------
function M:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function M:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
-- 根据guid得到hero
function M:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function M:update(newdata)

    -- 添加一条新数据
    self.__data[newdata.GUID] = client_gem.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return M
----------------------------------------------------------------