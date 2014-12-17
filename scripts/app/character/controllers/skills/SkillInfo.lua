--
-- Author: wangshaopei
-- Date: 2014-08-21 11:51:52
--
local SkillInfo = class("SkillInfo")
-----------------------------------------------------
function SkillInfo:ctor()
    self.skillId_=0
    self.logicId_=0
    --self.instanceId_=0
    self.powerRefixByVal_=0                      --值修正
    self.powerRefixByRate_=0                     --%修正
    self.activateTimes_=0
    self.accuracyRate_=-1
end
function SkillInfo:init()
    self:setPowerRefixByVal(0)
    self:setPowerRefixByRate(0)
end
function SkillInfo:getPowerRefixByVal()
    return self.powerRefixByVal_
end
function SkillInfo:getPowerRefixByRate()
    return self.powerRefixByRate_
end
function SkillInfo:setPowerRefixByVal(val)
    self.powerRefixByVal_=val
end
function SkillInfo:setPowerRefixByRate(rate)
    self.powerRefixByRate_=rate
end
function SkillInfo:getSkillId()
    return self.skillId_
end
function SkillInfo:setSkillId(id)
    assert(id~=nil,"setSkillId() - id is nil")
    self.skillId_=id
end
function SkillInfo:getLogicId()
    return self.logicId_
end
function SkillInfo:setLogicId(logicId)
    assert(logicId~=nil,"setLogicId() - logicId is nil")
    self.logicId_=logicId
end

function SkillInfo:copy(skillIntance)
    self:setSkillId(skillIntance.id)
    --self:setLogicId(skillIntance.logicId)
end
function SkillInfo:copySkillTemp(skillTemp)
    self:setAccuracyRate(skillTemp.accuracyRate)
end
function SkillInfo:getActivateTimes()
    return self.activateTimes_
end
function SkillInfo:setAccuracyRate(accuracyRate)
    self.accuracyRate_=accuracyRate
end
function SkillInfo:getAccuracy()
    return -1
    -- return self.accuracyRate_
end
-----------------------------------------------------
return SkillInfo
-----------------------------------------------------