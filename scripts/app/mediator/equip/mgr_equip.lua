--
-- Author: Anthony
-- Date: 2014-10-13 16:01:25
-- mgr_equip
-- 这里面的为背包里面的装备，如果已经使用，则该数据是会存储到hero的equips里面
local pairs = pairs
local table = table
----------------------------------------------------------------
local client_equip = import(".client_equip")
----------------------------------------------------------------
local mgr_equip = class("mgr_equip")
----------------------------------------------------------------
function mgr_equip:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function mgr_equip:get_data()
    return self.__data
end
----------------------------------------
function mgr_equip:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_equips")
    -- dump(self.__data)
end
----------------------------------------
function mgr_equip:get_count()
    return table.nums(self.__data)
end
----------------------------------------
function mgr_equip:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
-- 根据guid得到equip
function mgr_equip:get_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
----------------------------------------
function mgr_equip:update(newdata)
    -- local heros = self:get_data()
    -- if heros[newdata.GUID] then
    --     print("mgr_equips update replace ",newdata.GUID)
    -- end

    -- 添加一条新数据
    self.__data[newdata.GUID] = client_equip.new(newdata)
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------------------------------
return mgr_equip