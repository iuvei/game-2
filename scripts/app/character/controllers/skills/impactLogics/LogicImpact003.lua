--
-- Author: wangshaopei
-- Date: 2014-08-25 10:56:17
-- 效果：分类型的一次性伤害
local configMgr       = require("config.configMgr")         -- 配置
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("common.CommonDefine")
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic003 = class("ImpactLogic003",ImpactLogic)
ImpactLogic003.ID=SkillDefine.LogicImpact003
function ImpactLogic003:ctor()
end
function ImpactLogic003:initFromData(ownImpact,impactData)
    --local v = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamType_Damage)
    local v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamagePhy)
    self:setDamagePhy(ownImpact,v)
    local r = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamagePhyRate)
    self:setDamagePhyRate(ownImpact,r)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("ImpactLogic003:initFromData() - two phy value don't same,impactId = %d,v = %d, r = %d",
            ownImpact:getImpactTypeId(),v,r))
    end
    v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageZhanFa)
     self:setDamageZhanFa(ownImpact,v)
    r=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageZhanFaRate)
    self:setDamageZhanFaRate(ownImpact,r)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("ImpactLogic003:initFromData() - two zhanfa value don't same,impactId = %d,v = %d, r = %d",
            ownImpact:getImpactTypeId(),v,r) )
    end
    v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageJiCe)
    self:setDamageJiCe(ownImpact,v)
    r=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageJiCeRate)
    self:setDamageJiCeRate(ownImpact,r)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("ImpactLogic003:initFromData() - two JiCe value don't same,impactId = %d,v = %d, r = %d",
            ownImpact:getImpactTypeId(),v,r) )
    end
    return true
end
---------------------------------------------------------------------------------
--物理攻击值
function ImpactLogic003:getDamagePhy(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamagePhy)
end
function ImpactLogic003:setDamagePhy(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamagePhy,damageVal)
end
--物理攻击百分比
function ImpactLogic003:getDamagePhyRate(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamagePhyRate)
end
function ImpactLogic003:setDamagePhyRate(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamagePhyRate,damageVal)
end
--计策攻击值
function ImpactLogic003:getDamageJiCe(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCe)
end
function ImpactLogic003:setDamageJiCe(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCe,damageVal)
end
--计策攻击百分比
function ImpactLogic003:getDamageJiCeRate(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCeRate)
end
function ImpactLogic003:setDamageJiCeRate(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCeRate,damageVal)
end
--战法攻击值
function ImpactLogic003:getDamageZhanFa(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFa)
end
function ImpactLogic003:setDamageZhanFa(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFa,damageVal)
end
--战法攻击百分比
function ImpactLogic003:getDamageZhanFaRate(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFaRate)
end

function ImpactLogic003:setDamageZhanFaRate(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFaRate,damageVal)
end
---------------------------------------------------------------------------------
--
function ImpactLogic003:onActive(rMe,ownImpact)
    local damageArr ={}
    --计算伤害
    --物理
    damageArr[SkillDefine.ImpactParamL003_DamagePhy]=0
    local damage = self:getDamagePhy(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamagePhy]=damage
    end
    damageArr[SkillDefine.ImpactParamL003_DamagePhyRate]=0
    damage = self:getDamagePhyRate(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damage = math.floor(rMe:getBaseAttackPhysics()*damage/CommonDefine.RATE_LIMITE)
        damageArr[SkillDefine.ImpactParamL003_DamagePhyRate]=damage
    end
    --战法
    damageArr[SkillDefine.ImpactParamL003_DamageZhanFa]=0
    local damage = self:getDamageZhanFa(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamageZhanFa]=damage
    end
    damageArr[SkillDefine.ImpactParamL003_DamageZhanFaRate]=0
    damage = self:getDamageZhanFaRate(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damage = math.floor(rMe:getBaseAttackZhanFa()*damage/CommonDefine.RATE_LIMITE)
        damageArr[SkillDefine.ImpactParamL003_DamageZhanFaRate]=damage
    end
    --计策
    damageArr[SkillDefine.ImpactParamL003_DamageJiCe]=0
    local damage = self:getDamageJiCe(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamageJiCe]=damage
    end
    damageArr[SkillDefine.ImpactParamL003_DamageJiCeRate]=0
    damage = self:getDamageJiCeRate(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damage = math.floor(rMe:getBaseAttackJiCe()*damage/CommonDefine.RATE_LIMITE)
        damageArr[SkillDefine.ImpactParamL003_DamageJiCeRate]=damage
    end

    -- print("···",damageArr[SkillDefine.ImpactParamL003_DamagePhy],damageArr[SkillDefine.ImpactParamL003_DamagePhyRate],
    --     damageArr[SkillDefine.ImpactParamL003_DamageZhanFa],damageArr[SkillDefine.ImpactParamL003_DamageZhanFaRate],
    --     damageArr[SkillDefine.ImpactParamL003_DamageJiCe],damageArr[SkillDefine.ImpactParamL003_DamageJiCeRate])

    rMe:onDamages(damageArr,ownImpact:getCasterObjId(),ownImpact:getSkillId())
end
---------------------------------------------------------------------------------
return ImpactLogic003
---------------------------------------------------------------------------------