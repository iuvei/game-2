--
-- Author: wangshaopei
-- Date: 2014-08-27 19:54:01
-- 效果：间隔发作的驻留效果
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")

----------------------------------------------------------------
local LogicImpact010 = class("LogicImpact010",ImpactLogic)
----------------------------------------------------------------
LogicImpact010.ID=SkillDefine.LogicImpact010
function LogicImpact010:ctor()

end
function LogicImpact010:initFromData(ownImpact,impactData)

    return true
end
function LogicImpact010:isInvervaled()
    return true
end
function LogicImpact010:isOverTimed()
    return true
end
function LogicImpact010:onIntervalOver(rMe,ownImpact)
    local subImpactId = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL010_ImpactId)
    local refixRate = 0
    assert(subImpactId~=nil,string.format("Impact_GetImpactParamVal() - value for subImpactId is nil , ImpactTypeId = %d"
        ,ownImpact:getImpactTypeId()))
    --assert(false,"44444444444")
    ImpactCore:sendImpactToUnit(rMe, subImpactId, ownImpact:getCasterObjId(), false, refixRate)
end
function LogicImpact010:refixPowerByRate(ownImpact,rate)
    -- body
end

----------------------------------------------------------------
return LogicImpact010
----------------------------------------------------------------