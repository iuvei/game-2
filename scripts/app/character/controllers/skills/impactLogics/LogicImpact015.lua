--
-- Author: wangshaopei
-- Date: 2014-09-03 20:17:21
-- 功能说明：效果 － 昏迷，定身，无敌状态，混乱
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr    = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact015 = class("LogicImpact015",ImpactLogic)
----------------------------------------------------------------
LogicImpact015.ID=SkillDefine.LogicImpact015
function LogicImpact015:ctor()
end
function LogicImpact015:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact015:isOverTimed()
    return true
end

function LogicImpact015:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact015:getBoolAttrRefix(ownImpact,rMe,roleAttrType,out_data)
    local result = false
   if roleAttrType == CommonDefine.RoleAttrRefix_MoveFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_MoveFlag)
        result = true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_UnbreakableFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_UnbreakableFlag)
        result = true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_AktFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_AktFlag)
        result = true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_ChaosFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),4)
        result = true
    end
    if out_data.value == 0 then
        out_data.value = false
    elseif out_data.value == 1 then
        out_data.value = true
    elseif out_data.value == CommonDefine.INVALID_ID then -- 值为－1 不处理
       result = false
    end

    return result
end
function LogicImpact015:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact015
----------------------------------------------------------------