--
-- Author: wangshaopei
-- Date: 2014-08-14 17:10:40
--
local Cooldown = class("Cooldown")
----------------------------------------
function Cooldown:ctor(cooldownVal,cooldownId)
    self.id_=cooldownId or 0
    self.cooldownAmountVal_=cooldownVal        --冷却总值
    self.cooldownElapsedVal_=0                  --冷却流逝值
end
----------------------------------------
function Cooldown:updata(delta)
    if self.cooldownAmountVal_ == -1  then
        return
    end
    if  self.id_<0 then return end
    if  self.cooldownElapsedVal_ >= self.cooldownAmountVal_ then return end
    self.cooldownElapsedVal_=self.cooldownElapsedVal_+delta

    if self.cooldownElapsedVal_ > self.cooldownAmountVal_ then
        self.cooldownElapsedVal_=self.cooldownAmountVal_
    end

end
----------------------------------------
function Cooldown:isCooldowned()
    if self.cooldownAmountVal_ == -1  then
        return false
    end
    return self.cooldownElapsedVal_ >= self.cooldownAmountVal_
end
----------------------------------------
function Cooldown:getRemainVal()
    return self.cooldownAmountVal_ - self.cooldownElapsedVal_
end
----------------------------------------
function Cooldown:getId()
    return self.id_
end
----------------------------------------
function Cooldown:setId(cooldownId)
    self.id_=cooldownId
end
----------------------------------------
function Cooldown:getCooldownAmountVal()
    return self.cooldownAmountVal_
end
----------------------------------------
function Cooldown:setCooldownAmountVal(val)
    self.cooldownAmountVal_=val
end
----------------------------------------
function Cooldown:getCooldownElapsedVal()
    return self.cooldownElapsedVal_
end
----------------------------------------
function Cooldown:setCooldownElapsedVal(val)
    self.cooldownElapsedVal_=val
end
----------------------------------------
return Cooldown
----------------------------------------