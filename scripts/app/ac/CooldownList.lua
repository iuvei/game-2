--
-- Author: wangshaopei
-- Date: 2014-08-14 17:11:07
--
local Cooldown = import(".Cooldown")
-----------------------------------------------------------
local CooldownList = class("CooldownList")
-----------------------------------------------------------
function CooldownList:ctor()
    self.cooldownList_={}
end
-----------------------------------------------------------
function CooldownList:reset()
    self.cooldownList_={}
end
-----------------------------------------------------------
function CooldownList:clear()
    self:reset()
end
-----------------------------------------------------------
function CooldownList:getSize()
    return table.nums(self.cooldownList_)
end
-----------------------------------------------------------
function CooldownList:updata(delta)
    for k,v in pairs(self.cooldownList_) do
        v:updata(delta)
    end
end
-----------------------------------------------------------
function CooldownList:isCooldownedById(cooldownId)
    if self.cooldownList_[cooldownId] == nil then
        return true
    end
    return self.cooldownList_[cooldownId]:isCooldowned()
end
-----------------------------------------------------------
function CooldownList:getCDById(cooldownId)
    return self.cooldownList_[cooldownId]
end
-----------------------------------------------------------
function CooldownList:registerCooldown(cooldownId,cooldownVal)
    if cooldownId < 0 then return end
    local cd = Cooldown.new(cooldownVal,cooldownId)
    self.cooldownList_[cooldownId]=cd
end
-----------------------------------------------------------
return CooldownList
-----------------------------------------------------------