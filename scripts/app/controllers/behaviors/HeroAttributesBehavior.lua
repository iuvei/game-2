--
-- Author: wangshaopei
-- Date: 2014-09-16 15:58:33
--
------------------------------------------------------------------------------
local MapConstants = require("app.controllers.MapConstants")
------------------------------------------------------------------------------
local BehaviorBase = require("app.controllers.behaviors.BehaviorBase")
local HeroAttributesBehavior = class("HeroAttributesBehavior", BehaviorBase)
------------------------------------------------------------------------------
function HeroAttributesBehavior:ctor()
    HeroAttributesBehavior.super.ctor(self, "HeroAttributesBehavior", nil, 1)
end

------------------------------------------------------------------------------
function HeroAttributesBehavior:bind(object)
    self:bindMethods(object)
end
------------------------------------------------------------------------------
function HeroAttributesBehavior:unbind(object)
    slef:unbindMethods(object)
end
------------------------------------------------------------------------------
function HeroAttributesBehavior:bindMethods(object)



end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function HeroAttributesBehavior:unbindMethods(object)
    self:unbindMethod(object,"getCampId")

end
------------------------------------------------------------------------------
return CampBehavior