--
-- Author: wangshaopei
-- Date: 2014-09-16 10:19:42
--
--
-- Author: wangshaopei
-- Date: 2014-09-01 18:22:42
-- 功能说明：一定时间内修改 maxrage,maxhp
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact011 = class("LogicImpact011",ImpactLogic)
----------------------------------------------------------------
LogicImpact011.ID=SkillDefine.LogicImpact011
function LogicImpact011:ctor()
end
function LogicImpact011:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact011:isOverTimed()
    return true
end

function LogicImpact011:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact011:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
    -- local b = false
    local value=0
    if role_attr_refix == CommonDefine.RoleAttrRefix_MaxRage then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL011_MaxRage)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL011_MaxRageRate)
        if rate~=-1 then
            value = math.round(rMe:getBaseMaxRage()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
        -- b=true
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_MaxHP then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL011_MaxHp)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL011_MaxHpRate)
        if rate~=-1 then
            value = math.round(rMe:getBaseMaxHp()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
        -- b=true
    end
    -- return b,value
end
function LogicImpact011:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact011
----------------------------------------------------------------