--
-- Author: Anthony
-- Date: 2014-07-03 15:04:59
--
------------------------------------------------------------------------------
local BehaviorBase = class("BehaviorBase")
------------------------------------------------------------------------------
function BehaviorBase:ctor(behaviorName, depends, priority, conflictions)
    self.name_         = behaviorName
    self.depends_      = checktable(depends)
    self.priority_     = checkint(priority) -- 行为集合初始化时的优先级，越大越先初始化
    self.conflictions_ = checktable(conflictions)
end
------------------------------------------------------------------------------
function BehaviorBase:getName()
    return self.name_
end
------------------------------------------------------------------------------
function BehaviorBase:getDepends()
    return self.depends_
end
------------------------------------------------------------------------------
function BehaviorBase:getPriority()
    return self.priority_
end
------------------------------------------------------------------------------
function BehaviorBase:getConflictions()
    return self.conflictions_
end
------------------------------------------------------------------------------
function BehaviorBase:bind(object)
end
------------------------------------------------------------------------------
function BehaviorBase:unbind(object)
end
------------------------------------------------------------------------------
function BehaviorBase:reset(object)
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function BehaviorBase:bindMethod(object,methodName,method, callOriginMethodLast)
    BehaviorsManager:bindMethod( object, self, methodName, method, callOriginMethodLast)
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function BehaviorBase:unbindMethod(object,methodName)
    BehaviorsManager:unbindMethod( object, self, methodName)
end
------------------------------------------------------------------------------
return BehaviorBase
