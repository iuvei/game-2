--
-- Author: Anthony
-- Date: 2014-07-09 15:59:56
-- hero的配置管理器
------------------------------------------------------------------------------
local StringData    = require("config.zhString")
-- 武将配置表
local conf_heros    = require("config.heros.heros")
------------------------------------------------------------------------------
local conf_herosMgr = {}
------------------------------------------------------------------------------
function conf_herosMgr:GetHeroData(typeId,quality)

    local hero = conf_heros.all_type[typeId][quality]
    if hero == nil then
        print("conf_herosMgr:GetHeroData error! typeId",typeId," quality",quality)
        return nil
    end
    -- 兵种配置表
    local arm = self:GetArmsData(hero.ArmId)

    -- 取出skills
    local skills = {}
    local conf_skills = conf_herosMgr:getHeroSkills(hero.SkillRule)
    if conf_skills then
        for k,v in pairs(conf_skills) do
            skills[k] = { templateId = v.skillTempId ,level = v.skllLevel}
        end
    end

    -- 属性
    local outData = {
        typename    = arm.TypeName,
        nickname    = hero.nickname,
        level       = hero.Level,
        speed       = arm.Speed,
        hit         = arm.Hit,
        MovDis      = arm.MovDis,
        AtkDis      = arm.AtkDis,
        attack      = hero.PhysicsAtk,
        defense     = hero.PhysicsDef,
        maxHp       = hero.MaxHP,
        -- campId      = campid,
        quality     = hero.Quality,
        artId       = hero.Artid,
        formationId = hero.FormationId,
        ArmId       = hero.ArmId,
        SkillRule   = hero.SkillRule,
        country     = hero.country,
        stars       = hero.stars,
        Desc        = hero.Desc,
        skills      = skills,
    }
    return outData
end
------------------------------------------------------------------------------
function conf_herosMgr:GetHeroDataById(id)
    local typeId = math.floor(id / 1000)
    local quality = math.floor(id % 1000)
    return self:GetHeroData(typeId,quality)
end
------------------------------------------------------------------------------
function conf_herosMgr:GetHeroById(id)
    local typeId = math.floor(id / 1000)
    local quality = math.floor(id % 1000)
    return conf_heros.all_type[typeId][quality]
end
------------------------------------------------------------------------------
function conf_herosMgr:GetHeroTypeCount()
    return #conf_heros.all_type
end
------------------------------------------------------------------------------
function conf_herosMgr:GetArmsData(id)
    -- 兵种配置表
    local conf_arms = require("config.heros.arms")

    local typeId = math.floor(id / 1000)
    local level = math.floor(id % 1000)
    return conf_arms.all_type[typeId][level]
end
------------------------------------------------------------------------------
function conf_herosMgr:GetArmsDataByHeorId(HeroId)
    local typeId = math.floor(HeroId / 1000)
    local quality = math.floor(HeroId % 1000)

    local hero = conf_heros.all_type[typeId][quality]
    -- 兵种配置表
    local arm = self:GetArmsData(hero.ArmId)
    return arm
end
------------------------------------------------------------------------------
function conf_herosMgr:GetHerosArt(id)
    -- 武将美术配置表
    local conf_herosArt = require("config.heros.herosArt")

    local typeId = math.floor(id / 1000)
    local level = math.floor(id % 1000)
    return conf_herosArt.all_type[typeId][level]
end
------------------------------------------------------------------------------
function conf_herosMgr:GetHerosArtById(heroid)
    local data = self:GetHeroDataById(heroid)
    return self:GetHerosArt(data.artId)
end
------------------------------------------------------------------------------
function conf_herosMgr:GetArmFlie(id,state,isEnemy)
    -- 武将美术配置表
    local conf_armArt = require("config.heros.armArt")

    local i = 1
    local armArt = conf_armArt.all_type[id]
    if state == "idle" then i = 1
    elseif state == "dead" then i = 2
    elseif state == "move" then i = 3
    elseif state == "attck" then i = 4
    elseif state == "beattck" then i = 5
    end

    if isEnemy then
        local prefix = ""
        if armArt[i].enemyPrefix then
            prefix = armArt[i].enemyPrefix
        end

        local suffix = ""
        if armArt[i].enemySuffix then
            suffix = armArt[i].enemySuffix
        end
        return prefix..armArt[i].file..suffix
    else
        return armArt[i].file
    end
end
------------------------------------------------------------------------------
function conf_herosMgr:GetArmArtById(ArmId,state,isEnemy)
    local arm = self:GetArmsData(ArmId)
    return self:GetArmFlie(arm.artId,state,isEnemy)
end
------------------------------------------------------------------------------
function conf_herosMgr:getHeroCountryName(id)
   local data =self:GetHeroDataById(id)
   return StringData[100000020+data.country]
end
------------------------------------------------------------------------------
function conf_herosMgr:getCountryName(id)
   return StringData[100000020+id]
end
------------------------------------------------------------------------------
function conf_herosMgr:getHeroSkills(skillRuleOfHero)
    local config_herosSkillRule = require("config.heros.herosSkillRule")
    return config_herosSkillRule.all_type[skillRuleOfHero]
end
------------------------------------------------------------------------------
function conf_herosMgr:getArmSkills(skillRuleOfArm)
    local config_armsSkillRule = require("config.heros.armsSkillRule")
    return config_armsSkillRule.all_type[skillRuleOfArm]
end
------------------------------------------------------------------------------
return conf_herosMgr
------------------------------------------------------------------------------