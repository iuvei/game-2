--
-- Author: wangshaopei
-- Date: 2014-11-20 11:41:05
--
-- 功能说明：无法恢复hp，rage
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr    = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact016 = class("LogicImpact016",ImpactLogic)
----------------------------------------------------------------
LogicImpact016.ID=SkillDefine.LogicImpact016
function LogicImpact016:ctor()
end
function LogicImpact016:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact016:isOverTimed()
    return true
end

function LogicImpact016:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact016:getBoolAttrRefix(ownImpact,rMe,roleAttrType,out_data)
    local result = false
   if roleAttrType == CommonDefine.RoleAttrRefix_CanRegainHpFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),1) -- 是否可恢复hp
        result = true
    elseif roleAttrType == CommonDefine.RoleAttrRefix_CanRegainRageFlag then
        out_data.value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),2) -- 是否可恢复rage
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
function LogicImpact016:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact016
----------------------------------------------------------------