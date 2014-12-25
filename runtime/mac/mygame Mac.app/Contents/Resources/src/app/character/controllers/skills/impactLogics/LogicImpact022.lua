--
-- Author: wangshaopei
-- Date: 2014-11-21 17:43:53
-- 回合开始阶段使用效果
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置
local SkillLogic       = require("app.character.controllers.skills.skillLogics.SkillLogic")

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact022 = class("LogicImpact022",ImpactLogic)
----------------------------------------------------------------
LogicImpact022.ID=SkillDefine.LogicImpact022
function LogicImpact022:ctor()
end
function LogicImpact022:initFromData(ownImpact,impactData)
    return true
end
-- 回合开始前执行
function LogicImpact022:onBeforeBout(sender_obj,ownImpact)
    local target_logic = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),1)
    local impact_id = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),2)-- 执行的效果ID
    local target_obj_views = {}
    -- 取得目标逻辑
    SkillLogic:getTarsByTarLogic(sender_obj,target_logic,1,target_obj_views)
    --
    for i=1,#target_obj_views do
        -- local new_impact = OwnImpact.new()
        local target_obj = target_obj_views[i]:GetModel()
        -- ImpactCore:initImpactFromData(sender_obj,impact_id,new_impact)
        -- local imapct_logic_id = Impact_GetLogicId(new_impact)
        -- if ImpactLogic003.ID == imapct_logic_id then
        --     local combat=CombatCore.new()
        --     --计算基本属性值＋身上impact附加的属性值，如物理攻击
        --     combat:getResultImpact(sender_obj, target_obj, new_impact)
        -- end
        -- self:registerImpactEvent(target_obj,sender_obj,new_impact,false)
        ImpactCore:sendImpactToUnit(target_obj, impact_id, sender_obj:getId())
    end
end
return LogicImpact022