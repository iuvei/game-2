--
-- Author: wangshaopei
-- Date: 2014-08-22 16:24:16
-- 效果：直接修改值，血量，怒气
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置
local ImpactLogic = import(".ImpactLogic")
local LogicImpact004 = class("LogicImpact004",ImpactLogic)
LogicImpact004.ID=SkillDefine.LogicImpact004
function LogicImpact004:ctor()

end
function LogicImpact004:initFromData(ownImpact,impactData)
    --hp
    local v = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL004_Hp)
    local r = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL004_HpRate)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("LogicImpact004:initFromData() - two value don't same,impactId = %d,v = %d, r = %d",
            ownImpact:getImpactTypeId(),v,r))
    end
   ownImpact:setParameterByIndex(SkillDefine.ImpactParamL004_Hp,v)
   ownImpact:setParameterByIndex(SkillDefine.ImpactParamL004_HpRate,r)

   --rage
   local v = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL004_Rage)
    local r = configMgr:getConfig("impacts"):GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL004_RageRate)
    if v~=CommonDefine.INVALID_ID  and r~=CommonDefine.INVALID_ID then
        assert(false,string.format("LogicImpact004:initFromData() - two value don't same,impactId = %d,v = %d, r = %d",
            ownImpact:getImpactTypeId(),v,r))
    end
   ownImpact:setParameterByIndex(SkillDefine.ImpactParamL004_Rage,v)
   ownImpact:setParameterByIndex(SkillDefine.ImpactParamL004_RageRate,r)
    return true
end

function LogicImpact004:onActive(rMe,ownImpact)
    local hp = ownImpact:getParameterByIndex(SkillDefine.ImpactParamL004_Hp)
    if hp~=CommonDefine.INVALID_ID then
        rMe:increaseHp(hp)
    end
    local hpRate = ownImpact:getParameterByIndex(SkillDefine.ImpactParamL004_HpRate)
    if hpRate~=CommonDefine.INVALID_ID then
        hp = math.floor(rMe:getHp()*hpRate/CommonDefine.RATE_LIMITE)
        rMe:increaseHp(hp)
    end

    local rage = ownImpact:getParameterByIndex(SkillDefine.ImpactParamL004_Rage)
    if rage~=CommonDefine.INVALID_ID then
        rMe:increaseRage(rage)
    end
    local rageRate = ownImpact:getParameterByIndex(SkillDefine.ImpactParamL004_RageRate)
    if rageRate~=CommonDefine.INVALID_ID then
        rage = math.floor(rMe:getRage()*rageRate/CommonDefine.RATE_LIMITE)
        rMe:increaseRage(rage)
    end
end
-------------------------------------------------------------------------------
return LogicImpact004
-------------------------------------------------------------------------------