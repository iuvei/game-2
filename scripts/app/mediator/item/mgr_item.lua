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
local mgr_item = class("mgr_item")
----------------------------------------------------------------
function mgr_item:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function mgr_item:get_data()
    return self.__data
end
----------------------------------------
function mgr_item:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_items")
    -- dump(self.__data)
end
----------------------------------------
function mgr_item:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function mgr_item:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
-- 根据guid得到hero
function mgr_item:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function mgr_item:update(newdata)
    -- 添加一条新数据
    self.__data[newdata.GUID] = client_item.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return mgr_item
----------------------------------------------------------------