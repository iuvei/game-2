--
-- Author: wangshaopei
-- Date: 2014-11-14 10:47:13
-- note: 一定时间内修改战攻，战防
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact012 = class("LogicImpact012",ImpactLogic)
----------------------------------------------------------------
LogicImpact012.ID=SkillDefine.LogicImpact012
function LogicImpact012:ctor()
end
function LogicImpact012:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact012:isOverTimed()
    return true
end

function LogicImpact012:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact012:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
     local value=0
    if role_attr_refix == CommonDefine.RoleAttrRefix_MagicAtk then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL012_DamageMagicAtk)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL012_DamageMagicAtkRate)
        if rate~=-1 then
            -- issue:可能导致循环
            value = math.round(rMe:getAttackMagic()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_MagicDef then
        value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL012_DamageMagicDef)

        local rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL012_DamageMagicDefRate)
        if rate~=-1 then
            value = math.round(rMe:getDefenseMagic()*rate/CommonDefine.RATE_LIMITE)
        end
        out_data.value = out_data.value + value
    end
end
function LogicImpact012:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact012
----------------------------------------------------------------