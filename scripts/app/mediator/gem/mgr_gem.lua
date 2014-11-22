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
local mgr_gem = class("mgr_gem")
----------------------------------------------------------------
function mgr_gem:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function mgr_gem:get_data()
    return self.__data
end
----------------------------------------
function mgr_gem:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_gems")
    -- dump(self.__data)
end
----------------------------------------
function mgr_gem:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function mgr_gem:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
-- 根据guid得到hero
function mgr_gem:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function mgr_gem:update(newdata)

    -- 添加一条新数据
    self.__data[newdata.GUID] = client_gem.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return mgr_gem
----------------------------------------------------------------