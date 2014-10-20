--
-- Author: Anthony
-- Date: 2014-07-03 15:06:05
-- BehaviorFactory
------------------------------------------------------------------------------
local behaviorsClass = {
    StateMachineBehavior    = import(".StateMachineBehavior"),
    DestroyedBehavior       = import(".DestroyedBehavior"),
    MovableBehavior         = import(".MovableBehavior"),
    SkillBehavior           = import(".SkillBehavior"),
    CampBehavior            = import(".CampBehavior"),
    AICharacterBehavior     = import(".AICharacterBehavior"),
}
------------------------------------------------------------------------------
local BehaviorFactory = {}
------------------------------------------------------------------------------
function BehaviorFactory.createBehavior(behaviorName)
    local class = behaviorsClass[behaviorName]
    assert(class ~= nil, string.format("BehaviorFactory.createBehavior() - Invalid behavior name \"%s\"", tostring(behaviorName)))
    return class.new()
end
------------------------------------------------------------------------------
local allStaticObjectBehaviors = {
    StateMachineBehavior  = true,
    DestroyedBehavior     = true,
    MovableBehavior       = true,
    SkillBehavior         = true,
    CampBehavior          = true,
    AICharacterBehavior   = true,
}
------------------------------------------------------------------------------
function BehaviorFactory.getAllStaticObjectBehaviorsName()
    return table.keys(allStaticObjectBehaviors)
end
------------------------------------------------------------------------------
function BehaviorFactory.isStaticObjectBehavior(behaviorName)
    return allStaticObjectBehaviors[behaviorName]
end
------------------------------------------------------------------------------
return BehaviorFactory
------------------------------------------------------------------------------