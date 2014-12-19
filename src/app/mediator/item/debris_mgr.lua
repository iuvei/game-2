--
-- Author: Anthony
-- Date: 2014-11-11 11:52:58
-- Filename: debris_mgr.lua
--
-- local pairs = pairs
-- local table = table
----------------------------------------------------------------
local debris = import(".debris")
----------------------------------------------------------------
local debris_mgr = class("debris_mgr")
----------------------------------------------------------------
function debris_mgr:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function debris_mgr:get_data()
    return self.__data
end
----------------------------------------
function debris_mgr:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_debriss")
    -- dump(self.__data)
end
----------------------------------------
function debris_mgr:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function debris_mgr:remove( GUID )
    self.__data[GUID] = nil
    -- dump(self.__data)
end
----------------------------------------
-- 根据guid得到hero
function debris_mgr:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function debris_mgr:update(newdata)
    -- 添加一条新数据
    self.__data[newdata.GUID] = debris.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return debris_mgr