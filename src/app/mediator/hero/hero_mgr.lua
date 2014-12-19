--
-- Author: Anthony
-- Date: 2014-10-12 23:13:17
-- heros数据管理器
-- local pairs = pairs
local table = table
----------------------------------------------------------------
local hero = import(".hero")
----------------------------------------------------------------
local hero_mgr = class("hero_mgr")
----------------------------------------------------------------
function hero_mgr:ctor(player)
    self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function hero_mgr:get_data()
	return self.__data
end
----------------------------------------
function hero_mgr:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_heros")
    -- dump(self.__data)
end
----------------------------------------
function hero_mgr:get_count()
    return table.nums(self.__data)
end
----------------------------------------
-- 根据guid得到hero
function hero_mgr:get_hero_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
function hero_mgr:get_hero(GUID)
    return self.__data[GUID]
end
----------------------------------------
function hero_mgr:update(newdata)
    -- local heros = self:get_data()
    -- if heros[newdata.GUID] then
    --     print("hero_mgr update replace ",newdata.GUID)
    -- end

    -- 添加一条新数据
    self.__data[newdata.GUID] = hero.new(newdata)

    -- 刷新相关
    self.__data[newdata.GUID]:flush_item_effect()
    -- print("---------update")
    -- dump(self.__data)

end
----------------------------------------
function hero_mgr:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------
function hero_mgr:get_equip(hero_guid,equip_dataId)
    -- 刷新相关
    local data = self.__data[hero_guid]:get_data()
    for i,v in ipairs(data.equips) do
        if v.dataId == equip_dataId then
            return v
        end
    end
end
----------------------------------------
-- 根据guid获取
function hero_mgr:get_equip_by_guid(hero_guid,equip_guid)
    local data = self.__data[hero_guid]:get_data()
    for i,v in ipairs(data.equips) do
        if v.GUID == equip_guid then
            return v
        end
    end
end
----------------------------------------
-- 刷新武将身上的装备，如果原来没有，则直接穿上
function hero_mgr:update_equip(hero_guid,equip)
    local item_helper = require("app.mediator.item.item_helper")
    local class = item_helper.get_serial_classid(equip.dataId)
    if class ~= 1 then --必须装备
        return
    end

    -- 刷新相关
    local hero  = self.__data[hero_guid]
    local data = hero:get_data()
    for i,v in ipairs(data.equips) do
        -- print(i,v)
        if item_helper.get_serial_type(v.dataId)==item_helper.get_serial_type(equip.dataId) then
            data.equips[i] = equip
            -- 刷新item effect
            hero:flush_item_effect()
            -- dump(self.__data[hero_guid]:get_data())
            return
        end
    end
    -- 如果没有说明是新的，直接insert
    table.insert(data.equips,equip)
    -- 刷新item effect
    hero:flush_item_effect()
    -- dump(self.__data[hero_guid]:get_data())
end
----------------------------------------------------------------
-- 逻辑处理函数
-- ----------------------------------------


----------------------------------------------------------------
return hero_mgr
----------------------------------------------------------------