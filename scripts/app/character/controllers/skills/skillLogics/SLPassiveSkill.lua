--
-- Author: wangshaopei
-- Date: 2014-09-16 18:40:31
--
-- desc: 取得被动技能影响属性的效果(maxHp,MaxRate)
local configMgr     = require("config.configMgr")         -- 配置
local SkillDefine   = import("..SkillDefine")
local SkillLogic = import(".SkillLogic")
local CombatCore= import("..CombatCore")
local OwnImpact = import("..OwnImpact")
local CommonDefine = require("app.ac.CommonDefine")
--local ImpactLogic003 = import("..impactLogics.LogicImpact003")

local SLPassiveSkill = class("SLPassiveSkill",SkillLogic)
SLPassiveSkill.ID=SkillDefine.LogicSkill_PassiveSkill
function SLPassiveSkill:ctor()

end
function SLPassiveSkill:refix_SkillEffect(rMe,skill,role_attr_type,out_attr)
    -- params of impacts
    local impacts_params=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skill.id)
    for i=1,#impacts_params do
        local params = impacts_params[i]
        local impactTypeId = params[SkillDefine.SkillParamL_PassiveSkill_ImpID]
        local value = 0
        if role_attr_type == CommonDefine.RoleAttr_MaxHP  then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxHp)
            if value ~= CommonDefine.INVALID_ID then
                out_attr.value = out_attr.value + value
            end
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxHpRate)
            if value ~= CommonDefine.INVALID_ID then
                local value_=math.floor(rMe:getBaseMaxHp()*value/CommonDefine.RATE_LIMITE)
                out_attr.value = out_attr.value + value_
            end
            return true
        elseif role_attr_type==CommonDefine.RoleAttr_MaxRage then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxRage)
            if value ~= CommonDefine.INVALID_ID then
                out_attr.value = out_attr.value + value
            end
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxRageRate)
            if value ~= CommonDefine.INVALID_ID then
                local value_=math.floor(rMe:getBaseMaxRage()*value/CommonDefine.RATE_LIMITE)
                out_attr.value = out_attr.value + value_
            end
            return true
        end
    end
end

-------------------------------------------------------------------
return SLPassiveSkill
-------------------------------------------------------------------