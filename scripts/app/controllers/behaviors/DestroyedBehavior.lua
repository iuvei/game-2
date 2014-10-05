--
-- Author: Anthony
-- Date: 2014-07-04 17:59:04
-- 破坏行为：HP的增减
------------------------------------------------------------------------------
local MapConstants = require("app.controllers.MapConstants")
local BehaviorBase = require("app.controllers.behaviors.BehaviorBase")
local EffectChangeHP = require("common.effect.ChangeHP")
local configMgr       = require("config.configMgr")
local CommonDefine = require("common.CommonDefine")
------------------------------------------------------------------------------
local DestroyedBehavior = class("DestroyedBehavior", BehaviorBase)
------------------------------------------------------------------------------
function DestroyedBehavior:ctor()
    DestroyedBehavior.super.ctor(self, "DestroyedBehavior", {"CampBehavior"}, 1)
end
------------------------------------------------------------------------------
function DestroyedBehavior:bind(object)

    self:bindMethods(object)

    self:reset(object)
end
------------------------------------------------------------------------------
function DestroyedBehavior:unbind(object)
    object.maxHp_      = nil
    object.destroyed_  = nil
    object.hp_         = nil
    object.isStop_     = false

    self:unbindMethods(object)
end
------------------------------------------------------------------------------
function DestroyedBehavior:reset(object)

    if object.maxHp_ < 1 then object.maxHp_ = 1 end
    object.hp_        = object.maxHp_
    object.rage_      = configMgr:getConfig("skills"):GetInitDataByType(CommonDefine.InitRageValType)--object.maxRage_
    object.destroyed_ = object.hp_ <= 0
    object.hp__       = nil
    object.intAttrDirtyFlags_={}
    object.intAttrRefixDirtyFlags_={}
end
------------------------------------------------------------------------------
function DestroyedBehavior:bindMethods(object)
    function getHit(object)
        return CommonDefine.RATE_LIMITE
    end
    self:bindMethod(object,"getHit", getHit)
    function getMiss(object)
        return 0
    end
    self:bindMethod(object,"getMiss", getMiss)
    ----------------------------------------
    --
    local function isUnbreakable(object)
        return false
    end
    self:bindMethod(object,"isUnbreakable", isUnbreakable)
    local function getIsStop(object)
        return object.isStop_
    end
    self:bindMethod(object,"getIsStop", getIsStop)
    ----------------------------------------
    --
    local function setIsStop(object,isStop)
         object.isStop_=isStop
    end
    self:bindMethod(object,"setIsStop", setIsStop)
    ----------------------------------------
    --
    local function isDestroyed(object)
        return object.destroyed_
    end
    self:bindMethod(object,"isDestroyed", isDestroyed)
    ----------------------------------------
    --属性更新标识
    local function markMaxHpDirtyFlag(object)
        object.intAttrDirtyFlags_[CommonDefine.RoleAttr_Max_Hp]=true
    end
    self:bindMethod(object,"markMaxHpDirtyFlag", markMaxHpDirtyFlag)
    local function getMaxHpDirtyFlag(object)
        local flag = object.intAttrDirtyFlags_[CommonDefine.RoleAttr_Max_Hp]
        if not flag then
            return false
        end
        return flag
    end
    self:bindMethod(object,"getMaxHpDirtyFlag", getMaxHpDirtyFlag)
    local function clearMaxHpDirtyFlag(object)
        object.intAttrDirtyFlags_[CommonDefine.RoleAttr_Max_Hp]=nil
    end
    self:bindMethod(object,"clearMaxHpDirtyFlag", clearMaxHpDirtyFlag)
    ----------------------------------------
    -- ----------------------------------------
    -- --
    -- local function getMaxHp(object)
    --     local value = object:getBaseMaxHp() + object:getMaxHpRefix()
    --     return value
    -- end
    -- self:bindMethod(object,"getMaxHp", getMaxHp)
    -- ----------------------------------------
    -- --
    -- local function setMaxHp(object, maxHp)
    --     maxHp = checkint(maxHp)
    --     assert(maxHp > 0, string.format("DestroyedBehavior.setMaxHp() - invalid maxHp %s", tostring(maxHp)))
    --     object.maxHp_ = maxHp
    -- end
    -- self:bindMethod(object,"setMaxHp", setMaxHp)
    -- ----------------------------------------
    -- --
    -- local function getHp(object)
    --     return object.hp_
    -- end
    -- self:bindMethod(object,"getHp", getHp)
    -- ----------------------------------------
    -- --
    -- local function setHp(object, hp)
    --     hp = checknumber(hp)
    --     assert(hp >= 0 and hp <= object.maxHp_,
    --            string.format("DestroyedBehavior.setHp() - invalid hp %s", tostring(hp)))
    --     object.hp_ = hp
    --     object:dispatchEvent({name = object.HP_CHANGED_EVENT})
    --     object.hp__ = nil
    -- end
    -- self:bindMethod(object,"setHp", setHp)
    -- ----------------------------------------
    -- --
    -- local function getMaxRage(object)
    --     local value = object:getBaseMaxRage() + object:getMaxRageRefix()
    --     return value
    -- end
    -- self:bindMethod(object,"getMaxRage", getMaxRage)
    -- ----------------------------------------
    -- --
    -- local function setMaxRage(object, maxRage)
    --     maxRage = checkint(maxRage)
    --     assert(maxRage > 0, string.format("DestroyedBehavior.setMaxRage() - invalid maxRage %s", tostring(maxRage)))
    --     object.maxRage_ = maxRage
    -- end
    -- self:bindMethod(object,"setMaxRage", setMaxRage)
    -- ----------------------------------------
    -- --
    -- local function getRage(object)
    --     return object.rage_
    -- end
    -- self:bindMethod(object,"getRage", getRage)
    -- ----------------------------------------
    -- --
    -- local function setRage(object, rage)
    --     rage = checknumber(rage)
    --     assert(rage >= 0 and rage <= object.maxRage_,
    --            string.format("DestroyedBehavior.setrage() - invalid rage %s", tostring(rage)))
    --     object.rage_ = rage
    -- end
    -- self:bindMethod(object,"setRage", setRage)
    -- ----------------------------------------
    -- --修改的属性相关
    -- local function getMaxRageRefix(object)
    --     local b,value = object:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Max_Rage)

    --     return value
    -- end
    -- self:bindMethod(object,"getMaxRageRefix", getMaxRageRefix)
    -- local function getMaxHpRefix(object)
    --     local b,value = object:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Max_Hp)
    --     return value
    -- end
    -- self:bindMethod(object,"getMaxHpRefix", getMaxHpRefix)
    ----------------------------------------
    --怒气值
    local function increaseRage(object, delta)
        delta = checknumber(delta)
        assert(not object:isDead(), string.format("Object %s:%s is dead, can't change rage", object:getId(), object:getNickname()))

        local newVal = object.rage_ + delta
        if delta >= 0 then
            if newVal > object:getMaxRage() then
                newVal = object:getMaxRage()
            end
            local oldRage = object:getRage()
            object:setRage(newVal)
            if oldRage<=0 and object:getRage()>0 then
                --onRelive
            end
        else
            if 0>newVal then
                newVal=0
            end
             local oldRage = object:getRage()
            object:setRage(newVal)

            if oldRage>0 and object:getRage()<=0 then
                --die
            end
        end
    end
    self:bindMethod(object,"increaseRage", increaseRage)
    ----------------------------------------
    --
    local function increaseHp(object, increaseVal)
        amount = checknumber(increaseVal)
        assert(not object:isDead(), string.format("Object %s:%s is dead, can't change Hp", object:getId(), object:getNickname()))

        local newhp = object.hp_ + increaseVal
        if increaseVal >= 0 then
            if newhp > object:getMaxHp() then
                newhp = object:getMaxHp()
            end
            local oldhp = object:getHp()
            object:setHp(newhp)
            if oldhp<=0 and object:getHp()>0 then
                --onRelive
            end
        else
            local oldhp = object:getHp()
            if 0>newhp then
                newhp=0
            end
            object:setHp(newhp)
            if newhp == 0 then
                object:doBeKillEvent()
            else
                object:doBeAttackEvent(object.ATTACK_COOLDOWN)--object.ATTACK_COOLDOWN
            end
            if oldhp>0 and object:getHp()<=0 then
                --die
                object.destroyed_ = true
            end
        end
        -- 飘血
        EffectChangeHP:run(object.view_,increaseVal)
    end
    self:bindMethod(object,"increaseHp", increaseHp)
    ----------------------------------------
    --
    local function createView(object, batch)
        self.batch_ = batch

        object.hpOutlineSprite_ = display.newSprite(string.format("#right-angry.png"))
        --缩放
        object.hpOutlineSprite_:setScaleX(MapConstants.RADIUS_SCALE_X)
        -- object.hpOutlineSprite_:setScaleY(MapConstants.RADIUS_SCALE_Y)
        -- 加入批量渲染
        batch:addChild(object.hpOutlineSprite_, MapConstants.HP_BAR_ZORDER)

        object.hpSprite_ = display.newSprite("#right-Blood.png")
        object.hpSprite_:align(display.LEFT_CENTER, 0, 0)
        --缩放
        object.hpSprite_:setScaleX(MapConstants.RADIUS_SCALE_X)
        -- object.hpSprite_:setScaleY(MapConstants.RADIUS_SCALE_Y)
        -- 加入批量渲染
        batch:addChild(object.hpSprite_, MapConstants.HP_BAR_ZORDER + 1)

        object.Rage_=ui.newTTFLabel({
                            text = string.format("rage:%d/%d",object:getRage(),object:getMaxRage()),
                            size = 15,
                            color = display.COLOR_GREEN,
                        })
                        :pos(ccp(0,0))
                        :addTo(object:getMap())

    end
    self:bindMethod(object,"createView", createView)
    ----------------------------------------
    --
    local function removeView(object)
        object.hpOutlineSprite_:removeSelf()
        object.hpOutlineSprite_ = nil
        object.hpSprite_:removeSelf()
        object.hpSprite_ = nil
        object.Rage_:removeSelf()
    end
    self:bindMethod(object,"removeView", removeView, true)
    ----------------------------------------
    --
    local function updateView(object)
        object.hp__ = object:getHp()
        if object:getHp() > 0 then
            local x, y = object:getView():getPosition()

            local x2 = x + object.hpRadiusOffsetX - (object.hpSprite_:getContentSize().width / 2)*MapConstants.RADIUS_SCALE_X
            local y2 = y + object.hpRadiusOffsetY + MapConstants.HP_BAR_OFFSET_Y
            object.hpSprite_:setPosition(x2, y2)
            object.hpSprite_:setScaleX( (object:getHp() / object:getMaxHp()) * 0.4 )
            object.hpSprite_:setVisible(true)
            object.hpOutlineSprite_:setPosition(x + object.hpRadiusOffsetX, y2)
            object.hpOutlineSprite_:setVisible(true)

            -- self.batch_:reorderChild(object.hpSprite_, MapConstants.HP_BAR_ZORDER+1)
            -- self.batch_:reorderChild(object.hpOutlineSprite_, MapConstants.HP_BAR_ZORDER)
            local y2 = y2+15
            object.Rage_:setString(string.format("  rage:%d/%d\n  hp:%d/%d",object:getRage(),object:getMaxRage()
                ,object:getHp(),object:getMaxHp()))
            object.Rage_:setPosition(ccp(x2,y2))
        else
            object.hpSprite_:setVisible(false)
            object.hpOutlineSprite_:setVisible(false)
            object.Rage_:setVisible(false)
        end
    end
    self:bindMethod(object,"updateView", updateView)
    ----------------------------------------
    -- 设定为object:fastUpdateView执行完后才执行
    local function fastUpdateView(object)
        -- if not object.updated__ and object.hp__ == object.hp_ then return end
        updateView(object)
    end
    self:bindMethod(object,"fastUpdateView", fastUpdateView)
    ----------------------------------------
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function DestroyedBehavior:unbindMethods(object)
    self:unbindMethod(object,"isDestroyed")
    self:unbindMethod(object,"setDestroyed")
    -- self:unbindMethod(object,"getMaxHp")
    -- self:unbindMethod(object,"setMaxHp")
    -- self:unbindMethod(object,"getHp")
    -- self:unbindMethod(object,"setHp")
    -- self:unbindMethod(object,"getMaxRage")
    -- self:unbindMethod(object,"setMaxRage")
    -- self:unbindMethod(object,"getRage")
    -- self:unbindMethod(object,"setRage")
    self:unbindMethod(object,"increaseHp")
    self:unbindMethod(object,"decreaseRage")
    self:unbindMethod(object,"increaseRage")
    self:unbindMethod(object,"createView")
    self:unbindMethod(object,"removeView")
    self:unbindMethod(object,"updateView")
    self:unbindMethod(object,"fastUpdateView")
    self:unbindMethod(object,"isUnbreakable")
    self:unbindMethod(object,"getHit")
    self:unbindMethod(object,"getMiss")
    -- self:unbindMethods(object,"getMaxRageRefix")
    -- self:unbindMethods(object,"getMaxHpRefix")
end
------------------------------------------------------------------------------
return DestroyedBehavior
------------------------------------------------------------------------------