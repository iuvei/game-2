--
-- Author: Anthony
-- Date: 2014-10-13 14:48:10
-- hero数据
----------------------------------------------------------------
local MapConstants  = require("app.ac.MapConstants")
local configMgr = require("config.configMgr")
----------------------------------------------------------------
local M = class("client_hero")
----------------------------------------------------------------
function M:ctor(data)
    self.__data = nil
	self:set_data(data)
end
----------------------------------------
function M:get_data()
    return self.__data
end
----------------------------------------
function M:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function M:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function M:setkey( key, data )
    self.__data[key] = data
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function M:gen_new(olddata)

    -- 转出skill
    local skills = {}
    if olddata.skills then
        for k,v in pairs(olddata.skills) do
            skills[k] = { templateId = v.templateId ,level = v.level}
        end
    end

    -- 新数据
    local newdata = {
        dataId  = olddata.dataId,
        GUID    = olddata.GUID,
        campId  = MapConstants.PLAYER_CAMP,
        level   = olddata.level,
        quality = olddata.quality,
        stars   = olddata.stars,
        exp     = olddata.exp,
        favor   = olddata.favor, -- 好友度
        armId   = olddata.armId,
        skills  = skills,
    }
    -- dump(newdata)
    return newdata
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function M:get_info()

    local confHeros = configMgr:getConfig("heros")
    local confHeroData = confHeros:GetHeroDataById(self:get( "dataId" ))
    local cfheroArt = confHeros:GetHerosArt(confHeroData.artId)

    -- 国家信息
    local countryInfo = {
        id      = confHeroData.country,
        name    = confHeros:getCountryName(confHeroData.country)
    }

    --新数据
    local outInfo = {
        dataId      = self:get( "dataId" ),
        GUID        = self:get( "GUID" ),
        exp         = self:get( "exp" ) or 0,
        favor       = self:get( "favor" ) or 0,

        typename    = confHeroData.typename,
        nickname    = confHeroData.nickname,
        level       = self:get( "level" ),
        speed       = confHeroData.speed,
        hit         = confHeroData.hit,
        MovDis      = confHeroData.MovDis,
        AtkDis      = confHeroData.AtkDis,
        attack      = confHeroData.attack,
        defense     = confHeroData.defense,
        maxHp       = confHeroData.maxHp,
        campId      = self:get( "campId" ),
        quality     = self:get( "quality" ),    -- 品质
        stars       = self:get( "stars" ),      -- 星级
        artId       = confHeroData.artId,
        headIcon    = cfheroArt.headIcon,
        formationId = confHeroData.formationId,
        ArmId       = confHeroData.ArmId,--self:get( "armId" ),
        SkillRule   = confHeroData.SkillRule,
        skills      = self:get( "skills" ),
        countryInfo = countryInfo,
        Desc        = confHeroData.Desc
    }
    return outInfo
end
----------------------------------------------------------------
return M