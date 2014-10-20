--
-- Author: Anthony
-- Date: 2014-10-12 23:13:17
-- heros数据管理器
----------------------------------------------------------------
local client_hero = import(".client_hero")
----------------------------------------------------------------
local M = class("mgr_heros")
----------------------------------------------------------------
function M:ctor(player)
    self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function M:get_heros()
	return self.__data
end
----------------------------------------
function M:set_heros( data )

	local heros ={}
    for k,v in pairs(data) do
    	local nd = client_hero.new(v)
        self.__data[v.GUID] = nd
    end

    -- print("---------set_heros")
    -- dump(self.__data)
end
----------------------------------------
function M:get_heros_count()
	return table.getn(self.__data)
    -- local count = 0
    -- for k,v in pairs(self.__data) do
    --     count = count + 1
    -- end
    -- return count
end
----------------------------------------
-- 根据guid得到hero
function M:get_hero_by_GUID(GUID)
    local heros = self:get_heros()
    local hero = heros[GUID]
    if hero then
        return hero:get_info()
    end
    return nil
end
----------------------------------------
function M:update(newdata)
    local heros = self:get_heros()
    if heros[newdata.GUID] then
        print("mgr_heros update replace ",newdata.GUID)
    end

    -- 添加一条新数据
    local nd = client_hero.new(newdata)
    self.__data[newdata.GUID] = nd
    -- print("---------update")
    -- dump(self.__data)
end
----------------------------------------
function M:remove( GUID )
    self.__data[GUID] = nil
end
----------------------------------------------------------------
-- 逻辑处理函数
----------------------------------------
function M:ask_createhero( heroid )
        self.player:send("CS_AskCreateHero", {
            playerid    = self.player:get_playerid(),
            heroid      = heroid,
        })
end
----------------------------------------------------------------
return M
----------------------------------------------------------------