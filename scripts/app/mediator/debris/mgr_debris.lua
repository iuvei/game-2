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
local mgr_debris = class("mgr_debris")
----------------------------------------------------------------
function mgr_debris:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function mgr_debris:get_data()
    return self.__data
end
----------------------------------------
function mgr_debris:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_debriss")
    -- dump(self.__data)
end
----------------------------------------
function mgr_debris:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function mgr_debris:remove( GUID )
    self.__data[GUID] = nil
    -- dump(self.__data)
end
----------------------------------------
-- 根据guid得到hero
function mgr_debris:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function mgr_debris:update(newdata)
    -- 添加一条新数据
    self.__data[newdata.GUID] = client_debris.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return mgr_debris