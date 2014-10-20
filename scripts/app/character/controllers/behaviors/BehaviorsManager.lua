--
-- Author: Anthony
-- Date: 2014-07-04 10:42:19
--
------------------------------------------------------------------------------
local BehaviorFactory = import(".BehaviorFactory")
------------------------------------------------------------------------------
local BehaviorsManager = {}
------------------------------------------------------------------------------
function BehaviorsManager:initBehaviors(Object)
    if not Object.behaviors_ then return end

    local behaviors
    if type(Object.behaviors_) == "string" then
        behaviors = string.split(Object.behaviors_, ",")
    else
        behaviors = Object.behaviors_
    end

    for i, behaviorName in ipairs(behaviors) do
        behaviorName = string.trim(behaviorName)
        if behaviorName ~= "" then self:bindBehavior(Object,behaviorName) end
    end
end
------------------------------------------------------------------------------
function BehaviorsManager:hasBehavior(Object,behaviorName)
    return Object.behaviorObjects_ and Object.behaviorObjects_[behaviorName] ~= nil
end
------------------------------------------------------------------------------
-- 绑定行为
function BehaviorsManager:bindBehavior(Object,behaviorName)
    -- print("bindBehavior")
    if not Object.behaviorObjects_ then Object.behaviorObjects_ = {} end
    if Object.behaviorObjects_[behaviorName] then return end

    local behavior = BehaviorFactory.createBehavior(behaviorName)
    for i, dependBehaviorName in pairs(behavior:getDepends()) do
        self:bindBehavior(Object,dependBehaviorName)

        if not Object.behaviorDepends_ then
            Object.behaviorDepends_ = {}
        end
        if not Object.behaviorDepends_[dependBehaviorName] then
            Object.behaviorDepends_[dependBehaviorName] = {}
        end
        table.insert(Object.behaviorDepends_[dependBehaviorName], behaviorName)
    end

    behavior:bind(Object)
    Object.behaviorObjects_[behaviorName] = behavior
    self:resetAllBehaviors(Object)
end
------------------------------------------------------------------------------
-- 解绑行为
function BehaviorsManager:unbindBehavior(Object,behaviorName)
    assert(Object.behaviorObjects_ and Object.behaviorObjects_[behaviorName] ~= nil,
           string.format("Object:unbindBehavior() - behavior %s not binding", behaviorName))
    assert(not Object.behaviorDepends_ or not Object.behaviorDepends_[behaviorName],
           string.format("Object:unbindBehavior() - behavior %s depends by other binding", behaviorName))

    local behavior = Object.behaviorObjects_[behaviorName]
    for i, dependBehaviorName in pairs(behavior:getDepends()) do
        for j, name in ipairs(Object.behaviorDepends_[dependBehaviorName]) do
            if name == behaviorName then
                table.remove(Object.behaviorDepends_[dependBehaviorName], j)
                if #Object.behaviorDepends_[dependBehaviorName] < 1 then
                    Object.behaviorDepends_[dependBehaviorName] = nil
                end
                break
            end
        end
    end

    behavior:unbind(Object)
    Object.behaviorObjects_[behaviorName] = nil
end
------------------------------------------------------------------------------
function BehaviorsManager:resetAllBehaviors(Object)
    if not Object.behaviorObjects_ then return end

    local behaviors = {}
    for i, behavior in pairs(Object.behaviorObjects_) do
        behaviors[#behaviors + 1] = behavior
    end
    table.sort(behaviors, function(a, b)
        return a:getPriority() > b:getPriority()
    end)
    for i, behavior in ipairs(behaviors) do
        behavior:reset(Object)
    end
end
------------------------------------------------------------------------------
-- 绑定函数，如果有相同函数，则会按照绑定顺序一起执行
function BehaviorsManager:bindMethod(Object,behavior, methodName, method, callOriginMethodLast)

    local originMethod = Object[methodName]
    if not originMethod then
        Object[methodName] = method
        return
    end

    if not Object.bindingMethods_ then Object.bindingMethods_ = {} end
    if not Object.bindingMethods_[methodName] then Object.bindingMethods_[methodName] = {} end

    local chain = {behavior, originMethod}
    local newMethod
    if callOriginMethodLast then
        newMethod = function(...)
            method(...)
            chain[2](...)
        end
    else
        newMethod = function(...)
            local ret = chain[2](...)
            if ret then
                local args = {...}
                args[#args + 1] = ret
                return method(unpack(args))
            else
                return method(...)
            end
        end
    end

    Object[methodName] = newMethod
    chain[3] = newMethod
    table.insert(Object.bindingMethods_[methodName], chain)

    -- print(string.format("[%s]:bindMethod(%s, %s)", tostring(Object), behavior:getName(), methodName))
    -- for i, chain in ipairs(Object.bindingMethods_[methodName]) do
    --     print(string.format("  index: %d, origin: %s, new: %s", i, tostring(chain[2]), tostring(chain[3])))
    -- end
    -- print(string.format("  current: %s", tostring(Object[methodName])))
end
------------------------------------------------------------------------------
--解绑函数
function BehaviorsManager:unbindMethod(Object,behavior, methodName)
    if not Object.bindingMethods_ or not Object.bindingMethods_[methodName] then
        Object[methodName] = nil
        return
    end

    local methods = Object.bindingMethods_[methodName]
    local count = #methods
    for i = count, 1, -1 do
        local chain = methods[i]

        if chain[1] == behavior then
            -- print(string.format("[%s]:unbindMethod(%s, %s)", tostring(Object), behavior:getName(), methodName))
            if i < count then
                -- 如果移除了中间的节点，则将后一个节点的 origin 指向前一个节点的 origin
                -- 并且对象的方法引用的函数不变
                -- print(string.format("  remove method from index %d", i))
                methods[i + 1][2] = chain[2]
            elseif count > 1 then
                -- 如果移除尾部的节点，则对象的方法引用的函数指向前一个节点的 new
                Object[methodName] = methods[i - 1][3]
            elseif count == 1 then
                -- 如果移除了最后一个节点，则将对象的方法指向节点的 origin
                Object[methodName] = chain[2]
                Object.bindingMethods_[methodName] = nil
            end

            -- 移除节点
            table.remove(methods, i)

            -- if Object.bindingMethods_[methodName] then
            --     for i, chain in ipairs(Object.bindingMethods_[methodName]) do
            --         print(string.format("  index: %d, origin: %s, new: %s", i, tostring(chain[2]), tostring(chain[3])))
            --     end
            -- end
            -- print(string.format("  current: %s", tostring(Object[methodName])))

            break
        end
    end
end
------------------------------------------------------------------------------
return BehaviorsManager
------------------------------------------------------------------------------