--
-- Author: wangshaopei
-- Date: 2014-08-21 15:36:20
--
local OwnImpact = import("app.controllers.skills.OwnImpact")
local configMgr       = require("config.configMgr")         -- 配置
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
    local impactData = configMgr:getConfig("impacts"):GetImpact(impactTypeIdOrVal)
    --ownImpact:setIndexOrVal(impactTypeIdOrVal)
    if impactData ~= nil then
        ownImpact:setImpactTypeId(impactData.TypeId)
        ownImpact:setKeepBoutNum(impactData.keepBoutNum)
        ownImpact:setResEffecId(impactData.effectId)
        local impLogic = Impact_GetLogic(obj,ownImpact)--rMe:getImpactLogicByLogicId(impactData.logicId)
        if impLogic~=nil then
            impLogic:initFromData(ownImpact, impactData)
            return true
        end
    end
    return false
end
function ImpactCore:sendImpactToUnit(rTar,impactTypeId,senderId,bCriticalFag,refixRate)
    local ownImpact = OwnImpact.new()
    if self:initImpactFromData(rTar,impactTypeId,ownImpact) then
        local rAttacker = rTar:getMap():getObjectReal(senderId)
        rTar:getMap():registerImpactEvent(rTar, rAttacker, ownImpact)
    end
end
-----------------------------------------------------------------------------------------------------
return ImpactCore
-----------------------------------------------------------------------------------------------------