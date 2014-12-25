--
-- Author: wangshaopei
-- Date: 2014-09-01 18:22:42
-- 功能说明：一定时间内修改 物理防御，攻击
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact014 = class("LogicImpact014",ImpactLogic)
----------------------------------------------------------------
LogicImpact014.ID=SkillDefine.LogicImpact014
function LogicImpact014:ctor()
end
function LogicImpact014:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact014:isOverTimed()
    return true
end

function LogicImpact014:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact014:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
    -- local b = false
     local value=0
    if role_attr_refix == CommonDefine.RoleAttrRefix_PhysicsAtk then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL014_DamagePhyAtk)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL014_DamagePhyAtkRate)
        if rate~=-1 then
            value = math.round(rMe:getBaseAttack()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
        -- b=true
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_PhysicsDef then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL014_DamagePhyDefence)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL014_DamagePhyDefenceRate)
        if rate~=-1 then
            value = math.round(rMe:getBaseDefensePhysics()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
        -- b=true
    end
    -- return b,value
end
function LogicImpact014:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact014
----------------------------------------------------------------