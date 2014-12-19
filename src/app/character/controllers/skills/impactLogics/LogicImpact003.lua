--
-- Author: wangshaopei
-- Date: 2014-08-25 10:56:17
-- 效果：分类型的一次性伤害
local configMgr       = require("config.configMgr")         -- 配置
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic003 = class("ImpactLogic003",ImpactLogic)
ImpactLogic003.ID=SkillDefine.LogicImpact003
function ImpactLogic003:ctor()
end
function ImpactLogic003:initFromData(ownImpact,impactData)
    local v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamagePhy)
    self:setDamagePhy(ownImpact,v)
    -- local r = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamagePhyRate)
    -- self:setDamagePhyRate(ownImpact,r)
    -- if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
    --     assert(false,string.format("ImpactLogic003:initFromData() - two phy value don't same,impactId = %d,v = %d, r = %d",
    --         ownImpact:getImpactTypeId(),v,r))
    -- end
    local v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageZhanFa)
     self:setDamageMagic(ownImpact,v)
    -- r=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageZhanFaRate)
    -- self:setDamageZhanFaRate(ownImpact,r)
    -- if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
    --     assert(false,string.format("ImpactLogic003:initFromData() - two zhanfa value don't same,impactId = %d,v = %d, r = %d",
    --         ownImpact:getImpactTypeId(),v,r) )
    -- end
    v=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageJiCe)
    self:setDamageTactics(ownImpact,v)
    -- r=Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL003_DamageJiCeRate)
    -- self:setDamageJiCeRate(ownImpact,r)
    -- if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
    --     assert(false,string.format("ImpactLogic003:initFromData() - two JiCe value don't same,impactId = %d,v = %d, r = %d",
    --         ownImpact:getImpactTypeId(),v,r) )
    -- end
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
--计策攻击值
function ImpactLogic003:getDamageTactics(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCe)
end
function ImpactLogic003:setDamageTactics(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageJiCe,damageVal)
end
--战法攻击值
function ImpactLogic003:getDamageMagic(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFa)
end
function ImpactLogic003:setDamageMagic(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL003_DamageZhanFa,damageVal)
end
---------------------------------------------------------------------------------
--
function ImpactLogic003:crtRefix(ownImpact)
    self:setDamagePhy(ownImpact,math.round(self:getDamagePhy(ownImpact)*1.5))
    self:setDamageMagic(ownImpact,math.round(self:getDamageMagic(ownImpact)*1.5))
    self:setDamageTactics(ownImpact,math.round(self:getDamageTactics(ownImpact)*1.5))
end
---------------------------------------------------------------------------------
--
function ImpactLogic003:onActive(rMe,ownImpact)
    local damageArr ={nil,nil,nil}
    --计算伤害
    --物理
    damageArr[SkillDefine.ImpactParamL003_DamagePhy]=0
    local damage = self:getDamagePhy(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamagePhy]=damage
    end
    --战法
    damageArr[SkillDefine.ImpactParamL003_DamageZhanFa]=0
    local damage = self:getDamageMagic(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamageZhanFa]=damage
    end
    --计策
    damageArr[SkillDefine.ImpactParamL003_DamageJiCe]=0
    local damage = self:getDamageTactics(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damageArr[SkillDefine.ImpactParamL003_DamageJiCe]=damage
    end

    -- print("···",damageArr[SkillDefine.ImpactParamL003_DamagePhy],damageArr[SkillDefine.ImpactParamL003_DamagePhyRate],
    --     damageArr[SkillDefine.ImpactParamL003_DamageZhanFa],damageArr[SkillDefine.ImpactParamL003_DamageZhanFaRate],
    --     damageArr[SkillDefine.ImpactParamL003_DamageJiCe],damageArr[SkillDefine.ImpactParamL003_DamageJiCeRate])

    rMe:onDamages(damageArr,ownImpact:getCasterObjId(),ownImpact:getSkillId(),ownImpact.is_crt)
end
---------------------------------------------------------------------------------
return ImpactLogic003
---------------------------------------------------------------------------------