--
-- Author: Anthony
-- Date: 2014-10-12 23:13:17
-- heros数据管理器
local pairs = pairs
local table = table
----------------------------------------------------------------
local client_hero = import(".client_hero")
----------------------------------------------------------------
local mgr_heros = class("mgr_heros")
----------------------------------------------------------------
function mgr_heros:ctor(player)
    self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function mgr_heros:get_data()
	return self.__data
end
----------------------------------------
function mgr_heros:set_data( data )
    table.walk(data, function(v, k)
        self:update(v)
    end)

    -- print("---------set_heros")
    -- dump(self.__data)
end
----------------------------------------
function mgr_heros:get_count()
    return table.nums(self.__data)
end
----------------------------------------
-- 根据guid得到hero
function mgr_heros:get_hero_by_GUID(GUID)
    local data = self.__data[GUID]
    if data then
        return data:get_info()
    end
    return nil
end
function mgr_heros:get_hero(GUID)
    return self.__data[GUID]
end
----------------------------------------
function mgr_heros:update(newdata)
    -- local heros = self:get_data()
    -- if heros[newdata.GUID] then
    --     print("mgr_heros update replace ",newdata.GUID)
    -- end

    -- 添加一条新数据
    self.__data[newdata.GUID] = client_hero.new(newdata)

    -- 刷新相关
    self:get_hero(newdata.GUID):flush_item_effect()
    -- print("---------update")
    -- dump(self.__data)

end
----------------------------------------
function mgr_heros:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------------------------------
-- 逻辑处理函数
----------------------------------------
function mgr_heros:ask_createhero( heroid )
    self.player:send("CS_AskCreateHero", {
        playerid    = self.player:get_playerid(),
        heroid      = heroid,
    })
end

----------------------------------------------------------------
return mgr_heros
----------------------------------------------------------------