--
-- Author: wangshaopei
-- Date: 2014-08-22 16:24:16
-- 效果：无类型一次性伤害
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置
local ImpactLogic = import(".ImpactLogic")
local LogicImpact001 = class("LogicImpact001",ImpactLogic)
LogicImpact001.ID=SkillDefine.LogicImpact001
function LogicImpact001:ctor()

end
function LogicImpact001:initFromData(ownImpact,impactData)
    local v = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL001_Damage)
    local r = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL001_DamageRate)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("LogicImpact001:initFromData() - two value don't same,impactId = %d",
            ownImpact:getImpactTypeId()) )
    end

    self:setDamage(ownImpact,v)
    self:setDamageRate(ownImpact,r)
    return true
end
function LogicImpact001:setDamage(ownImpact,damageVal)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL001_Damage,damageVal)
end
function LogicImpact001:getDamage(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL001_Damage)
end
function LogicImpact001:setDamageRate(ownImpact,damageRate)
    ownImpact:setParameterByIndex(SkillDefine.ImpactParamL001_DamageRate,damageRate)
end
function LogicImpact001:getDamageRate(ownImpact)
    return ownImpact:getParameterByIndex(SkillDefine.ImpactParamL001_DamageRate)
end
function LogicImpact001:onActive(rMe,ownImpact)

    local damage = self:getDamage(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        rMe:onDamage(damage,ownImpact:getCasterObjId(),ownImpact:getSkillId(),ownImpact.is_crt)
    end
    damage = self:getDamageRate(ownImpact)
    if damage~= CommonDefine.INVALID_ID then
        damage = math.floor(rMe:getBaseMaxHp()*damage/CommonDefine.RATE_LIMITE)
        rMe:onDamage(damage,ownImpact:getCasterObjId(),ownImpact:getSkillId(),ownImpact.is_crt)
    end

end
return LogicImpact001