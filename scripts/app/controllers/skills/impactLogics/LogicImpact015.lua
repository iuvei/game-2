--
-- Author: wangshaopei
-- Date: 2014-09-03 20:17:21
--功能说明：效果 － 昏迷，定身，无敌状态
local SkillDefine=require("app.controllers.skills.SkillDefine")
local CommonDefine = require("common.CommonDefine")
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
function LogicImpact015:getBoolAttrRefix(ownImpact,rMe,roleAttrType)
    local value=CommonDefine.INVALID_ID
    local b = false
   if roleAttrType == CommonDefine.RoleAttrRefix_MoveFlag then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_MoveFlag)
        b=true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_UnbreakableFlag then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_UnbreakableFlag)
        b=true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_AktFlag then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL015_AktFlag)
        b=true
    end
    return b,value
end
function LogicImpact015:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact015
----------------------------------------------------------------