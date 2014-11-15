--
-- Author: Anthony
-- Date: 2014-10-22 14:37:14
-- Filename: mgr_items.lua
--
local pairs = pairs
local table = table
----------------------------------------------------------------
local client_item = import(".client_item")
----------------------------------------------------------------
local M = class("mgr_item")
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
        self.__data[v.GUID] = client_item.new(v)
    end)

    -- print("---------set_items")
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
    self.__data[newdata.GUID] = client_item.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return M
----------------------------------------------------------------