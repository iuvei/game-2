--
-- Author: Anthony
-- Date: 2014-10-22 14:37:14
-- Filename: comitem_mgr.lua
-- 消耗品
--
-- local pairs = pairs
-- local table = table
----------------------------------------------------------------
local comitem = import(".comitem")
----------------------------------------------------------------
local comitem_mgr = class("comitem_mgr")
----------------------------------------------------------------
function comitem_mgr:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function comitem_mgr:get_data()
    return self.__data
end
----------------------------------------
function comitem_mgr:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_items")
    -- dump(self.__data)
end
----------------------------------------
function comitem_mgr:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function comitem_mgr:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
-- 根据guid得到hero
function comitem_mgr:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function comitem_mgr:update(newdata)
    -- 添加一条新数据
    self.__data[newdata.GUID] = comitem.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return comitem_mgr
----------------------------------------------------------------