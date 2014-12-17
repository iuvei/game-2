--
-- Author: Anthony
-- Date: 2014-07-03 15:07:49
-- 状态机行为
------------------------------------------------------------------------------
local BehaviorBase = import(".BehaviorBase")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
------------------------------------------------------------------------------
local StateMachineBehavior = class("StateMachineBehavior", BehaviorBase)
------------------------------------------------------------------------------
function StateMachineBehavior:ctor()
    StateMachineBehavior.super.ctor(self, "StateMachineBehavior", nil, 1)
end
------------------------------------------------------------------------------
function StateMachineBehavior:log(fmt, ...)
    if DEBUG_BATTLE.showFSMLog then
        printf(fmt,...)
    end
end
------------------------------------------------------------------------------
function StateMachineBehavior:bind(object)
    --
    self.object__ = object
    --------------------------------------
    -- 绑定函数
    --------------------------------------
    self:bindMethods(object)

    ----------------------------------------
    -- 创建状态机
    ----------------------------------------
    -- 因为角色存在不同状态，所以这里为 Object 绑定了状态机组件
    object:addComponent("components.behavior.StateMachine")
    -- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
    object.fsm__ = object:getComponent("components.behavior.StateMachine")

    -- 设定状态机的默认事件
    local defaultEvents = {
        {name = "start",        from = "none",              to = "idle" },      -- 初始化后，角色处于 idle 状态
        {name = "attack",       from = "idle",              to = "attacking"},  -- 攻击
        -- {name = "atkfinish",    from = "attacking",         to = "idle"},       -- 完成
        {name = "beattack",     from = "*",     to = "beattacking"},  -- 被攻击
        -- {name = "beattackOver", from = "beattacking",       to = "idle"},       -- 被攻击冷却
        {name = "move",         from = "idle",              to = "moving"},     -- 移动
        -- {name = "finish",       from = "*",                 to = "finished"},       -- 完成
        {name = "stop",         from = "*",                 to = "idle"},       -- 停止
        {name = "bekill",       from = "*",                 to = "dead"},       -- 被杀死
        {name = "relive",       from = "dead",              to = "idle"},       -- 复活

    }
    -- 如果继承类提供了其他事件，则合并
    table.insertto(defaultEvents, checktable(events))
--[[
    onbeforexxx: 执行xxx事件前的响应函数；
    onxxx或者onafterxxx: 执行xxx事件完成的响应函数；
    onenterxxx或者onxxx: 进入xxx状态时的响应函数；
    onleavexxx: 离开xxx状态时的响应函数；
    onbeforeevent: 执行所有事件之前会执行该响应函数，事件信息以参数形式下发；
    onafterevent或者onevent: 执行所有事件完成之后执行该响应函数，事件信息以参数形式下发；
    onchangestate: 改变状态时的响应函数，事件信息会以参数的形式下发；
    onenterstate: 进入状态时的响应函数，事件信息会以参数形式下发：
    onleavestate: 离开状态时的响应函数，事件信息会以参数形式下发。
]]
    -- 设定状态机的默认回调
    local defaultCallbacks = {
        onchangestate       = handler(self, self.onChangeState_),
        onstart             = handler(self, self.onStart_),

        onattack            = handler(self, self.onAttack_),
        -- onleaveattacking    = handler(self, self.onLeaveAttacking_),

        -- onatkfinish         = handler(self, self.onAtkFinish_),
        --onready             = handler(self, self.onReady_),
        onmove              = handler(self, self.onMove_),
        -- onfinish            = handler(self, self.onFinished_),
        onstop              = handler(self, self.onStop_),
        onbekill            = handler(self, self.onBeKill_),
        onrelive            = handler(self, self.onRelive_),
        onbeattack          = handler(self, self.onBeAttack_),
        -- onleavebeattacking  = handler(self, self.onLeaveBeAttacking_),
        -- onbeattackOver      = handler(self, self.onBeAttackOver_),
        onbeforeevent       = handler(self, self.onBeforeEvent_)
    }
    -- 如果继承类提供了其他回调，则合并
    table.merge(defaultCallbacks, checktable(callbacks))

    object.fsm__:setupState({
        events = defaultEvents,
        callbacks = defaultCallbacks
    })

    self:log("----------")
    object.fsm__:doEvent("start") -- 启动状态机

    self:reset(object)
end
------------------------------------------------------------------------------
function StateMachineBehavior:unbind(object)

    self:unbindMethods(object)

    object.fsm__  = nil
    self.object__ = nil
end
------------------------------------------------------------------------------
function StateMachineBehavior:reset(object)

end
------------------------------------------------------------------------------
function StateMachineBehavior:bindMethods(object)
    ----------------------------------------
    -- 得到状态机
    local function getFSM(object)
        return object.fsm__
    end
    self:bindMethod(object,"getFSM", getFSM)
    ----------------------------------------
    -- 得到当前状态-
    local function getState(object)
        return object.fsm__:getState()
    end
    self:bindMethod(object,"getState", getState)
    ----------------------------------------
    --
    local function isDead(object)
        return object.fsm__:getState() == "dead"
    end
    self:bindMethod(object,"isDead", isDead)
    ----------------------------------------
    --
    local function isFrozen(object)
        return object.fsm__:getState() == "frozen"
    end
    self:bindMethod(object,"isFrozen", isFrozen)
    ----------------------------------------
    --
    local function isMoving(object)
        return object.fsm__:getState() == "moving"
        -- return not object:canDoEvent("move")
    end
    self:bindMethod(object,"isMoving", isMoving)
    --------------------------------------
    --
    local function isState(object,state)
        return object.fsm__:getState() == state
    end
    self:bindMethod(object,"isState", isState)
    ----------------------------------------
    --
    local function canDoEvent(object,eventname)
        return object.fsm__:canDoEvent(eventname)
    end
    self:bindMethod(object,"canDoEvent", canDoEvent)
    ----------------------------------------
    -- 执行攻击事件
    local function doAttackEvent(object,options)
        -- print("doAttackEvent")
        if object.fsm__:canDoEvent("attack") then
            self:log("----------")
            -- idle      ->     attacking
            object.fsm__:doEvent("attack",options)
            -- attacking      ->     idle
            -- object.fsm__:doEvent("atkfinish", attackTime)
            return true
        else
            return false
        end
    end
    self:bindMethod(object,"doAttackEvent", doAttackEvent)
    ----------------------------------------
    -- 执行准备事件
    local function doReadyEvent(object,cooldown)
        -- print("doAttackEvent")
        if object.fsm__:canDoEvent("ready") then
            self:log("----------")
            -- attacking      ->     idle
            object.fsm__:doEvent("ready", cooldown)

            return true
        else
            return false
        end
    end
    self:bindMethod(object,"doReadyEvent", doReadyEvent)
    ----------------------------------------
    --
    local function doBeAttackEvent(object,options) -- options ={cooldown,rece_obj}
        --if object.fsm__:canDoEvent("beattack") then
            self:log("----------")
            -- object.fsm__:doEventForce("beattack",_callback)
            -- object.fsm__:doEvent("beattackOver", cooldown)
            object.fsm__:doEvent("beattack",options)
            --return true
        --else
        --    return false
        --end
    end
    self:bindMethod(object,"doBeAttackEvent", doBeAttackEvent)
    ----------------------------------------
    -- 被杀事件
    local function doBeKillEvent(object)
        -- if object.fsm__:canDoEvent("bekill") then
           object.fsm__:doEventForce("bekill")
        -- end
    end
    self:bindMethod(object,"doBeKillEvent", doBeKillEvent)
    ----------------------------------------
    -- 移动事件
    local function doMoveEvent(object,options)
        if object:canDoEvent("move") then
            object.fsm__:doEvent("move",options)
        end
    end
    self:bindMethod(object,"doMoveEvent", doMoveEvent)
    ----------------------------------------
    -- 停止事件
    local function doStopEvent(object)
            self:log("doStopEvent")
            object.fsm__:doEvent("stop")
    end
    self:bindMethod(object,"doStopEvent", doStopEvent)
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function StateMachineBehavior:unbindMethods(object)
    self:unbindMethod(object,"getFSM")
    self:unbindMethod(object,"getState")
    self:unbindMethod(object,"isDead")
    self:unbindMethod(object,"isFrozen")
    self:unbindMethod(object,"isMoving")
    self:unbindMethod(object,"isState")
    self:unbindMethod(object,"canDoEvent")
    self:unbindMethod(object,"doAttackEvent")
    self:unbindMethod(object,"doBeAttackEvent")
    self:unbindMethod(object,"onBeKillEvent")
    self:unbindMethod(object,"doMoveEvent")
    self:unbindMethod(object,"doStopEvent")
    self:unbindMethod(object,"doReadyEvent")
end
------------------------------------------------------------------------------
---- state callbacks
------------------------------------------------------------------------------
function StateMachineBehavior:onChangeState_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s state change from %s to %s", object:getId(), object.nickname_, event.from, event.to)
    event = {name = object.CHANGE_STATE_EVENT, from = event.from, to = event.to}
    object:dispatchEvent(event)
end
------------------------------------------------------------------------------
-- 启动状态机时，设定角色默认 Hp
function StateMachineBehavior:onStart_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s start", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.START_EVENT})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onReady_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s ready", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.READY_EVENT})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onMove_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s Move", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.MOVE_EVENT,options=event.args[1]})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onStop_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s Stop", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.STOP_EVENT})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onBeKill_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s dead", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.BEKILL_EVENT,callback = event.args[1]})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onRelive_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s relive", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.RELIVE_EVENT})
end
------------------------------------------------------------------------------
--进入attacking状态时的响应函数
-- function StateMachineBehavior:onEnterAttacking_(event)
--     local object  = self.object__
--     self:log("StateMachineBehavior %s:%s EnterAttacking state", object:getId(), object.nickname_)
--     object:dispatchEvent({name = object.ENTER_ATTACKING})
-- end
------------------------------------------------------------------------------
--执行attack事件完成的响应函数
function StateMachineBehavior:onAttack_(event)
    local object  = self.object__

    self:log("StateMachineBehavior %s:%s afterAttackEvent", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.ATTACK_EVENT,options = event.args[1]})
end
------------------------------------------------------------------------------
--离开attacking状态时的响应函数
function StateMachineBehavior:onLeaveAttacking_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s leaveAttacking", object:getId(), object.nickname_)
   return self:delayToCall(object,event)
end
------------------------------------------------------------------------------
--
function StateMachineBehavior:onAtkFinish_( event )
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s leaveAtkFinish", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.FINISH_EVENT})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onBeAttack_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s BeAttack", object:getId(), object.nickname_)
    -- dump(event.args)
    object:dispatchEvent({name = object.BEATTACK_EVENT,options = event.args[1]})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onBeAttackOver_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s BeAttackOver", object:getId(), object.nickname_)
    object:dispatchEvent({name = object.BEATTACK_OVER_EVENT})
end
------------------------------------------------------------------------------
function StateMachineBehavior:onLeaveBeAttacking_(event)
    local object  = self.object__
    self:log("StateMachineBehavior %s:%s LeaveBeAttacking", object:getId(), object.nickname_)
    return self:delayToCall(object,event)
end
------------------------------------------------------------------------------
function StateMachineBehavior:onBeforeEvent_(event)
    local object  = self.object__
    --self:log("StateMachineBehavior %s:%s LeaveBeAttacking", object:getId(), object.nickname_)
    return object:dispatchEvent({name = object.BEFORE_EVENT})
end

------------------------------------------------------------------------------
-- 状态延迟处理
function StateMachineBehavior:delayToCall(object,event)
    local cooldown = checknumber(event.args[1])
    self:log("delayToCall began:%d",cooldown)
    if cooldown > 0 then
        -- 如果攻击后的冷却时间大于 0，则需要等待
        scheduler.performWithDelayGlobal(function()
            event.transition()

            local call = event.args[2]
            if call and type(call) == "function"  then
                call()
            end
            self:log("delayToCall Over:%d",cooldown)
        end, cooldown)
        return "async"
    end
end
------------------------------------------------------------------------------
return StateMachineBehavior
------------------------------------------------------------------------------