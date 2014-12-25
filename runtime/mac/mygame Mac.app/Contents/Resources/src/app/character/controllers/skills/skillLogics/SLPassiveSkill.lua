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
        local value = 0
        local conf_index = 0
        -- 取得技能效果列表
        local params = impacts_params[i]
        -- 效果ID
        local impactTypeId = params[1]
        -- 效果逻辑ID
        local logic_id = configMgr:getConfig("impacts"):GetImpact(impactTypeId).logicId
        if logic_id == 7 then -- 增加血量，怒气效果
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
        elseif logic_id == 6 then -- 被动技能影响闪避，命中，暴击，格挡，破防伤害，破防防御,速度
            if role_attr_type == CommonDefine.RoleAttr_Hit then  -- 命中
                conf_index = 1
            elseif role_attr_type == CommonDefine.RoleAttr_Evd then -- 闪避
                conf_index = 2
            elseif role_attr_type == CommonDefine.RoleAttr_Crt then -- 暴击
                conf_index = 3
            elseif role_attr_type == CommonDefine.RoleAttr_Crtdef then -- 抗暴击
                conf_index = 4
            elseif role_attr_type == CommonDefine.RoleAttr_DecDef then -- 破防伤害值
                conf_index = 5
            elseif role_attr_type == CommonDefine.RoleAttr_DecDefRed then -- 破防伤害减免值
                conf_index = 6
            elseif role_attr_type == CommonDefine.RoleAttr_Speed then -- 速度
                conf_index = 7

            end
            if conf_index == 0 then return false end
            value = Impact_GetImpactParamVal(impactTypeId,conf_index)
            if value ~= CommonDefine.INVALID_ID then
                out_attr.value = out_attr.value + value
                return true
            end
        elseif logic_id == 5 then -- 被动技能影响物攻，物防，战攻，战防，策攻，策防
            if role_attr_type == CommonDefine.RoleAttr_PhysicsAtk then  -- 物攻固定值
                conf_index = 1
            elseif role_attr_type == CommonDefine.RoleAttr_PhysicsDef then -- 物防固定值
                conf_index = 2
            elseif role_attr_type == CommonDefine.RoleAttr_MagicAtk then -- 战法攻击固定值
                conf_index = 3
            elseif role_attr_type == CommonDefine.RoleAttr_MagicDef then -- 战法防御固定值
                conf_index = 4
            elseif role_attr_type == CommonDefine.RoleAttr_TacticsAtk then -- 计策攻击固定值
                conf_index = 5
            elseif role_attr_type == CommonDefine.RoleAttr_TacticsDef then -- 计策防御固定值
                conf_index = 6
            end
            if conf_index == 0 then return false end
            value = Impact_GetImpactParamVal(impactTypeId,conf_index)
            if value ~= CommonDefine.INVALID_ID then
                out_attr.value = out_attr.value + value
                return true
            end

        end

    end
end

-------------------------------------------------------------------
return SLPassiveSkill
-------------------------------------------------------------------