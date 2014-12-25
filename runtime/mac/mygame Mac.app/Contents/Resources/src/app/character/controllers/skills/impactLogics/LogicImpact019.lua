--
-- Author: wangshaopei
-- Date: 2014-11-14 18:21:49
-- node : 增加一个护盾，抵挡一定次数的，物理伤害，战法伤害，计策伤害，和直接减少固定伤害
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr    = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact019 = class("LogicImpact019",ImpactLogic)
----------------------------------------------------------------
LogicImpact019.ID=SkillDefine.LogicImpact019
function LogicImpact019:ctor()
end
function LogicImpact019:initFromData(ownImpact,impactData)
    local damage = 0
    -- 抵挡物理攻击次数
    damage=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),1)
    ownImpact:setParameterByIndex(1,damage)
    -- 抵挡战法攻击次数
    damage=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),2)
    ownImpact:setParameterByIndex(2,damage)
    -- 抵挡计策攻击次数
    damage=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),3)
    ownImpact:setParameterByIndex(3,damage)
    return true
end
function LogicImpact019:onDamage(rMe,attacker,ownImpact,outData,skillId)
    if ownImpact:isFadeOut() then
        return
    end
    outData.damage = outData.damage - ownImpact:getParameterByIndex(4)
    rMe:Impact_OnImpactFadeOut(ownImpact)
end
function LogicImpact019:onDamages(rMe,attacker,ownImpact,outData,skillId)
    local b = false
    local timers = ownImpact:getParameterByIndex(1)
    if timers > 0 then
        ownImpact:setParameterByIndex(1,timers-1)
        outData.damages[SkillDefine.ImpactParamL003_DamagePhy]=0
        b = true
    end
    timers = ownImpact:getParameterByIndex(2)
    if timers > 0 then
        ownImpact:setParameterByIndex(2,timers-1)
        outData.damages[SkillDefine.ImpactParamL003_DamageZhanFa]=0
        b = true
    end
    timers = ownImpact:getParameterByIndex(3)
    if timers > 0 then
        ownImpact:setParameterByIndex(3,timers-1)
        outData.damages[SkillDefine.ImpactParamL003_DamageJiCe]=0
        b = true
    end
    if b then
        rMe:getView():createImpactEffect(100004,false)
    end
    if ownImpact:getParameterByIndex(1) + ownImpact:getParameterByIndex(2) + ownImpact:getParameterByIndex(3) <=0 then
        rMe:Impact_OnImpactFadeOut(ownImpact)
    end
end
return LogicImpact019
