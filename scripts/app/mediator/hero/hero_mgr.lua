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
    self:get_hero(newdata.GUID):flush_item_effect()
    -- print("---------update")
    -- dump(self.__data)

end
----------------------------------------
function hero_mgr:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------------------------------
-- 逻辑处理函数
----------------------------------------
function hero_mgr:ask_createhero( heroid )
    self.player:send("CS_AskCreateHero", {
        playerid    = self.player:get_playerid(),
        heroid      = heroid,
    })
end

----------------------------------------------------------------
return hero_mgr
----------------------------------------------------------------