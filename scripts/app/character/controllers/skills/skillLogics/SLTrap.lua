--
-- Author: wangshaopei
-- Date: 2014-11-05 17:14:44
--
local configMgr       = require("config.configMgr")         -- 配置
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local SkillLogic = import(".SkillLogic")
local CombatCore= require("app.character.controllers.skills.CombatCore")
local OwnImpact = import("app.character.controllers.skills.OwnImpact")
local CommonDefine = require("app.ac.CommonDefine")
local LogicImpact018 = import("app.character.controllers.skills.impactLogics.LogicImpact018")

local SLTrap = class("SLTrap",SkillLogic)
SLTrap.ID=SkillDefine.LogicSkill_Trap
function SLTrap:ctor()

end
function SLTrap:effectOnUnitOnce(rMe,rTar,bCritcalHit)
    local params = rMe:getTargetAndDepleteParams()
    local skill_params=configMgr:getConfig("skills"):GetSkillAppendImpacParams(params.skillId)
    local params_ = skill_params[1]
    -- 陷阱数据
    local  trap_data_id =params_[2]
    local  trap_impact_type_id = params_[1]
    -- 效果数据
    local conf_impact=configMgr:getConfig("impacts"):GetImpact(trap_impact_type_id)
    local special_trap_data=configMgr:getConfig("impacts"):GetSpecialObjData(trap_data_id)
    local x_,y_=rTar:getView():getPosition()
    local viewParams = {
            x = x_,
            y = y_,
            res_effect_id = special_trap_data.resEffectId,
            effectPoint = conf_impact.effectPoint
        }
    special_trap_data.owner=rMe
    special_trap_data.campId=rMe:getCampId()
    special_trap_data.skillId=params.skillId
    local specail_obj_view = rMe:getMap():getObjectManager():newObject(rMe:getMap(), "special_obj",special_trap_data,viewParams)
    local specail_obj = specail_obj_view:GetModel()
    -- 陷阱逻辑
    local trap_impact_logic = LogicImpact018

    local own_impact = rMe:getImpactByTypeId(trap_impact_type_id)
    if own_impact then
        trap_impact_logic:AddNewTrap(own_impact,rMe,specail_obj:getId())
    else
        local new_impact = OwnImpact.new()
        -- 添加记录陷阱效果
        ImpactCore:initImpactFromData(rMe,trap_impact_type_id,new_impact)
        trap_impact_logic:AddNewTrap(new_impact,rMe,specail_obj:getId())
        self:registerImpactEvent(rMe,rMe,new_impact,false)
    end

end
return SLTrap