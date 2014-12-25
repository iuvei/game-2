--
-- Author: Anthony
-- Date: 2014-07-09 15:59:56
-- hero的配置管理器
local pairs = pairs
local math = math
------------------------------------------------------------------------------
local StringData    = require("config.zhString")
local game_attr = require("app.ac.game_attr")
-- 武将配置表
local conf_heros    = require("config.heros.heros")
------------------------------------------------------------------------------
local conf_mgr_heros = {}
------------------------------------------------------------------------------
function conf_mgr_heros:GetHeroData(typeId,quality)

    local hero = conf_heros[typeId][quality]
    if hero == nil then
        print("conf_mgr_heros:GetHeroData error! typeId",typeId," quality",quality)
        return nil
    end
    -- 兵种配置表
    local arm_ = self:GetArmsData(hero.ArmId)

    local skills = {}
    -- 初始装备
    local conf_data = conf_mgr_heros:getHeroSkills(hero.SkillRule)
    if conf_data then
        for k,v in pairs(conf_data) do
            skills[k] = { templateId = v.skillTempId ,level = v.skllLevel}
        end
    end

    -- 属性
    return {
        -- typename    = arm_.TypeName,
        nickname    = hero.nickname,
        level       = hero.Level,
        -- speed       = arm.Speed,
        hit         = hero.Hit,
        -- MovDis      = arm.MovDis,
        attack      = hero.PhysicsAtk,
        defense     = hero.PhysicsDef,
        maxHp       = hero.MaxHP,
        quality     = hero.Quality,
        artId       = hero.Artid,
        formationId = hero.FormationId,
        ArmId       = hero.ArmId,
        SkillRule   = hero.SkillRule,
        country     = hero.country,
        Desc        = hero.Desc,
        arm         = arm_,
        skills      = skills,
        attr         = game_attr.gen_hero_attr(hero),
        skills      = skills,
        require_equip  = conf_mgr_heros:get_equip_rule(hero.equip_rule), --初始绑定装备
    }
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetHeroDataById(id)
    return self:GetHeroData(math.floor(id / 1000),math.floor(id % 1000))
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetConfHerosData(id)
    local typeId = math.floor(id / 1000)
    local quality = math.floor(id % 1000)
    local hero = conf_heros[typeId][quality]
    if hero == nil then
        print("conf_mgr_heros:GetHeroData error! typeId",typeId," quality",quality)
        return nil
    end
    return hero
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetHeroById(id)
    return conf_heros[math.floor(id / 1000)][math.floor(id % 1000)]
end
-- ------------------------------------------------------------------------------
-- function conf_mgr_heros:GetHeroTypeCount()
--     return #conf_heros
-- end
------------------------------------------------------------------------------
function conf_mgr_heros:GetArmsData(id)
    -- 兵种配置表
    local conf_arms = require("config.heros.arms")

    return conf_arms[math.floor(id / 1000)][math.floor(id % 1000)]
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetArmsDataByHeorId(HeroId)

    local hero = conf_heros[math.floor(HeroId / 1000)][math.floor(HeroId % 1000)]
    -- 兵种配置表
    local arm = self:GetArmsData(hero.ArmId)
    return arm
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetHerosArt(id)
    -- 武将美术配置表
    local conf_herosArt = require("config.heros.herosArt")

    return conf_herosArt[math.floor(id / 1000)][math.floor(id % 1000)]
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetHerosArtById(heroid)
    local data = self:GetHeroDataById(heroid)
    return self:GetHerosArt(data.artId)
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetArmFlie(id,state,isEnemy)
    -- 武将美术配置表
    local conf_armArt = require("config.heros.armArt")

    local i = 1
    local armArt = conf_armArt[id]
    if state == "idle" then i = 1
    elseif state == "dead" then i = 2
    elseif state == "move" then i = 3
    elseif state == "attck" then i = 4
    elseif state == "beattck" then i = 5
    end

    if isEnemy then
        local prefix = ""
        if armArt[1].epf then
            prefix = armArt[1].epf
        end

        local suffix = ""
        if armArt[1].esf then
            suffix = armArt[1].esf
        end
        -- print("···",prefix..armArt[i].file..suffix)
        return prefix..armArt[i].file..suffix
    else
        return armArt[i].file
    end
end
------------------------------------------------------------------------------
function conf_mgr_heros:GetArmArtById(ArmId,state,isEnemy)
    local arm = self:GetArmsData(ArmId)
    return self:GetArmFlie(arm.artId,state,isEnemy)
end
------------------------------------------------------------------------------
function conf_mgr_heros:getHeroCountryName(id)
   local data =self:GetHeroDataById(id)
   return StringData[100000020+data.country]
end
------------------------------------------------------------------------------
function conf_mgr_heros:getCountryName(id)
   return StringData[100000020+id]
end
------------------------------------------------------------------------------
function conf_mgr_heros:getHeroSkills(skillRuleOfHero)
    local config_herosSkillRule = require("config.heros.herosSkillRule")
    return config_herosSkillRule[skillRuleOfHero]
end
------------------------------------------------------------------------------
function conf_mgr_heros:getArmSkills(skillRuleOfArm)
    local config_armsSkillRule = require("config.heros.armsSkillRule")
    return config_armsSkillRule[skillRuleOfArm]
end
------------------------------------------------------------------------------
function conf_mgr_heros:get_equip_rule(ruleId)
    local config_data = require("config.heros.equip_rule")
    return config_data[ruleId]
end
------------------------------------------------------------------------------
return conf_mgr_heros
------------------------------------------------------------------------------