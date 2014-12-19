--
-- Author: wangshaopei
-- Date: 2014-08-21 15:10:18
--
local Cooldown = import("app.ac.Cooldown")
local OwnImpact = class("OwnImpact")
function OwnImpact:ctor()
    -- self.cd_=Cooldown.new(0,0)              --buffCD
    -- self.cdInterval_=Cooldown.new(0,0)      --buff驻留CD
    self:reset()
end
function OwnImpact:reset()
    self.skillId_=0
    self.params_={}                         --类型对应的参数值，如：攻击值等
    self.keepBoutNum_=0
    self.indexOrVal_=0                       --standardImpact的Typeid或基础值，如被动技能基础值
    self.typeId_=0
    self.casterObjId_=0                      --投手ID
    self.resEffectId_=0
    self.cd_=Cooldown.new(0,0)              --buffCD
    self.cdInterval_=Cooldown.new(0,0)      --buff驻留CD
    self.isFadeOut_=false
    self.logicId = 0                        -- 逻辑ID
    self.is_crt = false -- 是否暴击
end
function OwnImpact:setImpactTypeId(typeId)
    self.typeId_=typeId
end
--就是效果ID
function OwnImpact:getImpactTypeId()
    return self.typeId_
end
function OwnImpact:setIndexOrVal(indexOrVal)
    self.indexOrVal_=indexOrVal
end
function OwnImpact:getIndexOrVal()
    return self.indexOrVal_
end
function OwnImpact:getSkillId()
    return self.skillId_
end
function OwnImpact:setSkillId(skillId)
    self.skillId_=skillId
end
function OwnImpact:getCasterObjId()
    return self.casterObjId_
end
function OwnImpact:setCasterObjId(objId)
    self.casterObjId_=objId
end
--精灵的tagId为删除显示效果时用
function OwnImpact:getImpactSpriteTagId()
    return self:getResEffectId()
end
-------------------------------------------------------------------
--效果cd相关
function OwnImpact:getCDInterval()
    return self.cdInterval_
end
function OwnImpact:getCD()
    return self.cd_
end
function OwnImpact:setKeepBoutNum(num)
    self:getCD():setCooldownAmountVal(num)
end
-------------------------------------------------------------------
function OwnImpact:setResEffecId(resEffectId)
    self.resEffectId_=resEffectId
end
function OwnImpact:getResEffectId()
    return self.resEffectId_
end
function OwnImpact:isFadeOut()
    return self.isFadeOut_
    --return self:getCD():isCooldowned()
end
function OwnImpact:markFadeOut()
    -- self:getCD():setCooldownAmountVal(0)
    -- self:getCD():setCooldownElapsedVal(0)
    self.isFadeOut_=true
end
function OwnImpact:ResetFadeOut()
    self.isFadeOut_=false
end
-------------------------------------------------------------------
--
function OwnImpact:setParameterByIndex(paramTypeIndex,parameter)
    self.params_[paramTypeIndex]=parameter
end
function OwnImpact:getParameterByIndex(paramTypeIndex)
    local v = self.params_[paramTypeIndex] or nil
    return v
end
function OwnImpact:getParamAmount()
    return #self.params_
end
-------------------------------------------------------------------
return OwnImpact
-------------------------------------------------------------------