--
-- Author: wangshaopei
-- Date: 2014-11-14 10:49:45
-- note: 一定时间内修改策攻，策防
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact013 = class("LogicImpact013",ImpactLogic)
----------------------------------------------------------------
LogicImpact013.ID=SkillDefine.LogicImpact013
function LogicImpact013:ctor()
end
function LogicImpact013:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact013:isOverTimed()
    return true
end

function LogicImpact013:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact013:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
     local value=0
    if role_attr_refix == CommonDefine.RoleAttrRefix_TacticsAtk then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL013_DamageTacticsAtk)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL013_DamageTacticsAtkRate)
        if rate~=-1 then
            -- issue:可能导致循环
            value = math.round(rMe:getAttackTactics()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_TacticsDef then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL013_DamageTacticsDef)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL013_DamageTacticsDefRate)
        if rate~=-1 then
            value = math.round(rMe:getDefenseTactics()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
    end
end
function LogicImpact013:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact013
----------------------------------------------------------------