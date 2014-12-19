--
-- Author: Anthony
-- Date: 2014-07-07 12:06:43
-- 移动行为
------------------------------------------------------------------------------
local MapConstants = require("app.ac.MapConstants")
local math2d       = require("common.math2d")

local BehaviorBase = import(".BehaviorBase")
local MovableBehavior = class("MovableBehavior", BehaviorBase)
------------------------------------------------------------------------------
MovableBehavior.MOVING_STATE_STOPPED   = 0
MovableBehavior.MOVING_STATE_SPEEDUP   = 1
MovableBehavior.MOVING_STATE_SPEEDDOWN = 2
MovableBehavior.MOVING_STATE_FULLSPEED = 3
------------------------------------------------------------------------------
MovableBehavior.SPEED_SCALE = 1.0 / 300
------------------------------------------------------------------------------
function MovableBehavior:ctor()
    MovableBehavior.super.ctor(self, "MovableBehavior", nil, 1)
end

------------------------------------------------------------------------------
function MovableBehavior:bind(object)
    self._target_postions = {}
    self:bindMethods(object)

    self:reset(object)
    object:setSpeed(checknumber(object.arm_.Speed))
end
------------------------------------------------------------------------------
function MovableBehavior:unbind(object)

    self:unbindMethods(object)
end
------------------------------------------------------------------------------
function MovableBehavior:reset(object)
    -- object:setSpeed(checknumber(object.arm_.Speed))
    object.currentSpeed_ = 0
    object.movingState_  = MovableBehavior.MOVING_STATE_STOPPED
end
------------------------------------------------------------------------------
function MovableBehavior:bindMethods(object)

    ----------------------------------------
    --
    local function getSpeed(object)
        return object.arm_.Speed
    end
    self:bindMethod(object, "getSpeed", getSpeed)
    ----------------------------------------
    --
    local function setSpeed(object, maxSpeed)
        object.speed_ = checknumber(maxSpeed)
        if object.speed_ < 0 then object.speed_ = 0 end
    end
    self:bindMethod(object, "setSpeed", setSpeed)
    ----------------------------------------
    --_callback 为移动结束时回调函数
    -- local function startMoving(object,objectView,moveX,moveY, _callback)

    --     if object.movingState_ == MovableBehavior.MOVING_STATE_STOPPED
    --             or object.movingState_ == MovableBehavior.MOVING_STATE_SPEEDDOWN then

    --         local state = object.movingState_
    --         if state == MovableBehavior.MOVING_STATE_STOPPED then
    --             self.targetPos = { x = math.floor(moveX) , y = math.floor(moveY), callback = _callback }
    --         end

    --         object.movingState_ = MovableBehavior.MOVING_STATE_SPEEDUP

    --         -- 执行Move事件
    --         object:doMoveEvent(0,options)
    --         -- self:setNextPosition(object,objectView)
    --     end
    -- end
    self:bindMethod(object, "startMoving", startMoving)
    local function moveToPositions(object,target_position_infos)
        if object.movingState_ == MovableBehavior.MOVING_STATE_STOPPED
            or object.movingState_ == MovableBehavior.MOVING_STATE_SPEEDDOWN then

            local state = object.movingState_
            if state == MovableBehavior.MOVING_STATE_STOPPED then
                self._target_postions={}
                -- 保存为世界坐标
                local dmap=object:getView():getMap():getDMap()
                local count = #target_position_infos
                for i=1,count do
                    self._target_postions[#self._target_postions+1] = dmap:cellPosToWorldPos(target_position_infos[i].target_cell_position)
                    -- table.insert(self._target_postions, dmap:cellPosToWorldPos(target_position_infos[i].target_cell_position))
                end
            end

            object.movingState_ = MovableBehavior.MOVING_STATE_SPEEDUP

            -- 执行Move事件
            object:doMoveEvent(options)
            -- self:setNextPosition(object,objectView)
        end
    end
    self:bindMethod(object, "moveToPositions", moveToPositions)
    ----------------------------------------
    --
    -- local function isMoving(object)
    --     return object.movingState_ == MovableBehavior.MOVING_STATE_FULLSPEED
    --             or object.movingState_ == MovableBehavior.MOVING_STATE_SPEEDUP
    -- end
    -- self:bindMethod(object, "isMoving", isMoving)
    ----------------------------------------
    --
    local function tick(object, dt, map)
        local state = object.movingState_
        if state == MovableBehavior.MOVING_STATE_STOPPED then return end

        local target_pos = self._target_postions[1]
        if target_pos == nil then

            return
        end

        -- 如果定时超过一定则不处理，处理暂停
        if dt > 0.02 then
            return
        end

        local moveDis = math.floor(object:getSpeed()*MapConstants.SPEED_FACTOR*dt)

        local x, y = object.view_:getPosition()
        x = math.floor(x)
        y = math.floor(y)

        -- 处理x轴
        if x < target_pos.x then
            x = x + moveDis
            -- print("···1",x,y,dt,moveDis)
            if x > target_pos.x then
                x = target_pos.x
            end
        elseif x > target_pos.x then
            x = x - moveDis
           -- print("···2",x,y,dt,moveDis)
            if x < target_pos.x then
                x = target_pos.x
            end
        end

        -- 处理y轴
        if y < target_pos.y then
            y = y + moveDis
            if y > target_pos.y then
                y = target_pos.y
            end
        elseif y > target_pos.y then
            y = y - moveDis
            if y < target_pos.y then
                y = target_pos.y
            end
        end

        -- TODO 需判断地图边界，且需要判断目标地址是否是可行走区域

        -- 朝向
        if x < object.view_:getPositionX() then
            object.view_:flipX(false)
        elseif x > object.view_:getPositionX() then
            object.view_:flipX(true)
        end

        -- 设置新位置
        object.view_:setPosition(x,y)

        -- 到达目标，停止
        if x == target_pos.x and y == target_pos.y then
            -- object:doStopEvent()
            -- print("end",object:getId(),object:getNickname())
            -- 设置为停止状态
            object:stopMovingNow()
            return
        end

    end
    self:bindMethod(object, "tick", tick)
    ----------------------------------------
    --
    local function stopMovingNow(object)
        -- 更新人物地图格子位置
        object:getView():updataCellPos()

        -- table.remove(self._target_postions,1)
        -- if object:isState("idle") then
        --     print("···2222")
        --     self._target_postions={}
        -- end
        -- if #self._target_postions == 0 then
            object.movingState_ = MovableBehavior.MOVING_STATE_STOPPED
            object.currentSpeed_ = 0
            object:doStopEvent()
        -- end
    end
    self:bindMethod(object, "stopMovingNow", stopMovingNow)
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function MovableBehavior:unbindMethods(object)
    self:unbindMethod(object, "getSpeed")
    self:unbindMethod(object, "setSpeed")
    self:unbindMethod(object, "startMoving")
    self:unbindMethod(object, "stopMovingNow")
    -- self:unbindMethod(object, "isMoving")
    self:unbindMethod(object, "tick")
end
------------------------------------------------------------------------------
return MovableBehavior
------------------------------------------------------------------------------