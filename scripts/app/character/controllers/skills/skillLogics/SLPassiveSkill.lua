--
-- Author: wangshaopei
-- Date: 2014-09-16 18:40:31
--
-- 取得被动技能影响属性的效果
local configMgr     = require("config.configMgr")         -- 配置
local SkillDefine   = import("..SkillDefine")
local SkillLogic = import(".SkillLogic")
local CombatCore= import("..CombatCore")
local OwnImpact = import("..OwnImpact")
local CommonDefine = require("common.CommonDefine")
--local ImpactLogic003 = import("..impactLogics.LogicImpact003")

local SLPassiveSkill = class("SLPassiveSkill",SkillLogic)
SLPassiveSkill.ID=SkillDefine.LogicSkill_PassiveSkill
function SLPassiveSkill:ctor()

end
function SLPassiveSkill:refix_SkillEffect(skill,attrType,outAttr)
    local paramsLst=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skill.id)
    for i=1,#paramsLst do
        local params = paramsLst[i]
        local impactTypeId = params[SkillDefine.SkillParamL_PassiveSkill_ImpID]
        local value = 0
        if attrType==CommonDefine.ItemAttrType_Point_MaxHp then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxHp)
        elseif attrType==CommonDefine.ItemAttrType_Point_MaxHpRate then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxHpRate)
        elseif attrType==CommonDefine.ItemAttrType_Point_MaxRage then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxRage)
        elseif attrType==CommonDefine.ItemAttrType_Rate_MaxRageRate then
            value=Impact_GetImpactParamVal(impactTypeId,SkillDefine.ImpactParamPassvieSkill_MaxRageRate)
        end
        outAttr.value = outAttr.value + value
    end
end

-------------------------------------------------------------------
return SLPassiveSkill
-------------------------------------------------------------------