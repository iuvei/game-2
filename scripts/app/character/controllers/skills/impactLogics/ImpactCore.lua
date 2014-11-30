--
-- Author: wangshaopei
-- Date: 2014-08-21 15:36:20
--
local CombatCore= import("..CombatCore")
local OwnImpact = import("app.character.controllers.skills.OwnImpact")
local configMgr       = require("config.configMgr")         -- 配置
local ImpactLogic003 = import("..impactLogics.LogicImpact003")
-----------------------------------------------------------------------------------------------------
local ImpactCore = class("ImpactCore")
-----------------------------------------------------------------------------------------------------
function Impact_GetLogicId(ownImpact)
    return configMgr:getConfig("impacts"):GetImpact(ownImpact:getImpactTypeId()).logicId
end
function Impact_GetLogic(obj,ownImpact)
    local logicId = Impact_GetLogicId(ownImpact)
    local impLogic = obj:getImpactLogicByLogicId(logicId)
    assert(impLogic~=nil,string.format("Impact_GetLogic() - logic is nil , logicId = %d",logicId))
    return impLogic
end
function Impact_GetImpactParamVal(ImpactTypeId,ImpactParamType)
    return configMgr:getConfig("impacts"):GetImpactParamVal(ImpactTypeId,ImpactParamType)
end
-----------------------------------------------------------------------------------------------------
function ImpactCore:ctor()

end
function ImpactCore:initImpactFromData(obj,impactTypeIdOrVal,ownImpact)
    ownImpact:reset()
    local conf_impact = configMgr:getConfig("impacts"):GetImpact(impactTypeIdOrVal)
    --ownImpact:setIndexOrVal(impactTypeIdOrVal)
    if conf_impact ~= nil then
        ownImpact:setImpactTypeId(impactTypeIdOrVal)
        ownImpact:setKeepBoutNum(conf_impact.keepBoutNum)
        ownImpact:setResEffecId(conf_impact.effectId)
        local impLogic = Impact_GetLogic(obj,ownImpact)--rMe:getImpactLogicByLogicId(impactData.logicId)
        ownImpact.logicId = impLogic.ID
        if impLogic~=nil then
            impLogic:initFromData(ownImpact, conf_impact)
            return true
        end
    end
    return false
end
function ImpactCore:sendImpactToUnit(rTar,impactTypeId,senderId,bCriticalFag,refixRate)
    local ownImpact = OwnImpact.new()
    if self:initImpactFromData(rTar,impactTypeId,ownImpact) then
        local rAttacker = rTar:getMap():getObjectReal(senderId)
        local imapct_logic_id = Impact_GetLogicId(ownImpact)
        if ImpactLogic003.ID == imapct_logic_id then
            local combat=CombatCore.new()
            --计算基本属性值＋身上impact附加的属性值，如物理攻击
            combat:getResultImpact(rAttacker, rTar, ownImpact)
        end
        rTar:getMap():registerImpactEvent(rTar, rAttacker, ownImpact)
    end
end
function ImpactCore:sendImpactToUnit_(target_obj,impactTypeId,sender_obj,bCriticalFag,refixRate)
    local ownImpact = OwnImpact.new()
    if self:initImpactFromData(target_obj,impactTypeId,ownImpact) then
        -- local rAttacker = target_obj:getMap():getObjectReal(senderId)
        local imapct_logic_id = Impact_GetLogicId(ownImpact)
        if ImpactLogic003.ID == imapct_logic_id then
            local combat=CombatCore.new()
            --计算基本属性值＋身上impact附加的属性值，如物理攻击
            combat:getResultImpact(sender_obj, target_obj, ownImpact)
        end
        target_obj:getMap():registerImpactEvent(target_obj, sender_obj, ownImpact)
    end
end
-----------------------------------------------------------------------------------------------------
return ImpactCore
-----------------------------------------------------------------------------------------------------