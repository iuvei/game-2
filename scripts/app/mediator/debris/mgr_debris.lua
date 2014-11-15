--
-- Author: Anthony
-- Date: 2014-11-11 11:52:58
-- Filename: mgr_debris.lua
--
local pairs = pairs
local table = table
----------------------------------------------------------------
local client_debris = import(".client_debris")
----------------------------------------------------------------
local M = class("mgr_debris")
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
        self.__data[v.GUID] = client_debris.new(v)
    end)

    -- print("---------set_debriss")
    -- dump(self.__data)
end
----------------------------------------
function M:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function M:remove( GUID )
    self.__data[GUID] = nil
    -- dump(self.__data)
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
    self.__data[newdata.GUID] = client_debris.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return M