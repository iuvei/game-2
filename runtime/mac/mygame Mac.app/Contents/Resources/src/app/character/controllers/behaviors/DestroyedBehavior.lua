--
-- Author: Anthony
-- Date: 2014-07-04 17:59:04
-- 破坏行为：HP的增减
------------------------------------------------------------------------------
local MapConstants    = require("app.ac.MapConstants")
local BehaviorBase = import(".BehaviorBase")
local EffectChangeHP = require("common.effect.ChangeHP")
local configMgr       = require("config.configMgr")
local CommonDefine = require("app.ac.CommonDefine")
------------------------------------------------------------------------------
local DestroyedBehavior = class("DestroyedBehavior", BehaviorBase)
------------------------------------------------------------------------------
function DestroyedBehavior:ctor()
    DestroyedBehavior.super.ctor(self, "DestroyedBehavior", {"CampBehavior"}, 1)
end
------------------------------------------------------------------------------
function DestroyedBehavior:bind(object)
    self:bindMethods(object)

    object.hp__       = nil
    object.destroyed_ = false
    object.intAttrDirtyFlags_={}
    object.intAttrRefixDirtyFlags_={}
    --self:reset(object)
end
------------------------------------------------------------------------------
function DestroyedBehavior:unbind(object)
    -- object:setMaxHp(nil)
    object.destroyed_  = nil
    object.hp_         = nil
    object.isStop_     = false

    self:unbindMethods(object)
end
------------------------------------------------------------------------------
function DestroyedBehavior:reset(object)
    object.hp__       = nil
    object.destroyed_ = false
    object.intAttrDirtyFlags_={}
    object.intAttrRefixDirtyFlags_={}
    --if object:getMaxHp() < 1 then object:setMaxHp(1) end
    -- object.hp_        = object:getMaxHp()
    -- object.rage_      = configMgr:getConfig("skills"):GetInitDataByType(CommonDefine.InitRageValType)--object.maxRage_
    -- object.destroyed_ = object.hp_ <= 0
    -- object.hp__       = nil
    -- object.intAttrDirtyFlags_={}
    -- object.intAttrRefixDirtyFlags_={}
end
------------------------------------------------------------------------------
function DestroyedBehavior:bindMethods(object)
    -- 初始化摧毁行为
    function initDestroyedBeh(object)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MaxHP)
        if object:getMaxHp() < 1 then object:setMaxHp(1) end
        object.hp_        = object:getMaxHp()
        object.rage_      = configMgr:getConfig("skills"):GetInitDataByType(CommonDefine.InitRageValType)--object.maxRage_
    end
    self:bindMethod(object,"initDestroyedBeh", initDestroyedBeh)
    ----------------------------------------
    --
    local function isUnbreakable(object)
        return false
    end
    self:bindMethod(object,"isUnbreakable", isUnbreakable)

    ----------------------------------------
    --
    local function isDestroyed(object)
        return object.destroyed_
    end
    self:bindMethod(object,"isDestroyed", isDestroyed)
    ----------------------------------------
    --属性更新标识
    local function MarkAttrDirtyFlag(object,role_attr_type)
        object.intAttrDirtyFlags_[role_attr_type]=true
    end
    self:bindMethod(object,"MarkAttrDirtyFlag", MarkAttrDirtyFlag)
    local function GetAttrDirtyFlag(object,role_attr_type)
        local flag = object.intAttrDirtyFlags_[role_attr_type]
        if flag ~= nil then
            return flag
        end
        return false
    end
    self:bindMethod(object,"GetAttrDirtyFlag", GetAttrDirtyFlag)
    local function ClearAttrDirtyFlag(object,role_attr_type)
        object.intAttrDirtyFlags_[role_attr_type]=nil
    end
    self:bindMethod(object,"ClearAttrDirtyFlag", ClearAttrDirtyFlag)
    local function MarkAllAttrDirtyFlag(object)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MaxHP)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsAtk)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsDef)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MaxRage)        -- 最大怒气
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MaxMP)        -- 最大mp
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Hit )          -- 命中率
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Evd )          -- 闪避率
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Crt)           -- 暴击率
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Crtdef)       -- 抗暴击率
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Block)       -- 格挡率
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MagicAtk)     -- 魔法攻击力
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_MagicDef)      -- 魔法防御力
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_TacticsAtk)  -- 战法攻击力
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_TacticsDef)
        object:MarkAttrDirtyFlag(CommonDefine.RoleAttr_Speed)

    end
    self:bindMethod(object,"MarkAllAttrDirtyFlag", MarkAllAttrDirtyFlag)
    ----------------------------------------
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
            -- 是否可恢复怒气
            if object:getBoolAttRefix(CommonDefine.RoleAttrRefix_CanRegainRageFlag) == false then
                return false
            end
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
    local function increaseHp(object, increaseVal,is_crt)
        amount = checknumber(increaseVal)
        assert(not object:isDead(), string.format("Object %s:%s is dead, can't change Hp", object:getId(), object:getNickname()))

        local newhp = object.hp_ + increaseVal
        if increaseVal >= 0 then
            -- 是否可恢复血量
            if object:getBoolAttRefix(CommonDefine.RoleAttrRefix_CanRegainHpFlag) == false then
                return false
            end
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
                local options = {
                                    rece_obj = object,
                                    cooldown = object.ATTACK_COOLDOWN*1000/2
                                }
                object:doBeAttackEvent(options)
                -- if CommandManager:getFrontCommand().opObjId_ == object:getId() then
                --     HeroOperateManager:addCommand(DelayCommand.new(object,object.ATTACK_COOLDOWN*1000),HeroOperateManager.CmdSequence)
                -- else
                --     HeroOperateManager:addCommand(DelayCommand.new(object,object.ATTACK_COOLDOWN*1000),HeroOperateManager.CmdCocurrent)
                -- end

            end
            if oldhp>0 and object:getHp()<=0 then
                --die
                object.destroyed_ = true
            end
        end
        -- 飘血
        EffectChangeHP:run(object.view_,increaseVal,{zorder=MapConstants.MAP_Z_2_0,is_crt=is_crt})
    end
    self:bindMethod(object,"increaseHp", increaseHp)
    ----------------------------------------
    --
    local function createView(object, batch)
        self.batch_ = batch

        object.hpOutlineSprite_ = display.newSprite(string.format("#right-angry.png"))
        --缩放
        object.hpOutlineSprite_:setScaleX(MapConstants.RADIUS_SCALE_X)
        -- 加入批量渲染
        batch:addChild(object.hpOutlineSprite_, MapConstants.HP_BAR_ZORDER)

        object.hpSprite_ = display.newSprite("#right-Blood.png")
        object.hpSprite_:align(display.LEFT_CENTER, 0, 0)
        --缩放
        object.hpSprite_:setScaleX(MapConstants.RADIUS_SCALE_X)
        -- 加入批量渲染
        batch:addChild(object.hpSprite_, MapConstants.HP_BAR_ZORDER + 1)

        object.RageLabel_=cc.ui.UILabel.newTTFLabel_({
                            text = string.format("rage:%d/%d",object:getRage(),object:getMaxRage()),
                            size = 15,
                            color = display.COLOR_GREEN,
                        })
                        :addTo(object:getMap(),MapConstants.MAP_Z_1_0,86)
        -- object.Rage_ = cc.ui.UILabel.new({
        --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        --     text = string.format("rage:%d/%d",object:getRage(),object:getMaxRage()),
        --     size = 15,
        --     color = display.COLOR_GREEN,
        -- })
        -- :pos(0,0)
        -- :addTo(object:getMap(),MapConstants.MAP_Z_1_0)

    end
    self:bindMethod(object,"createView", createView)
    ----------------------------------------
    --
    -- local function removeView(object)
    --     if object.hpOutlineSprite_ then
    --         object.hpOutlineSprite_:removeSelf()
    --         object.hpOutlineSprite_ = nil
    --     end
    --     if object.hpSprite_ then
    --         object.hpSprite_:removeSelf()
    --         object.hpSprite_ = nil
    --     end

    --     if object.Rage_ then
    --         print("···9999999")
    --         object.Rage_:removeSelf()
    --         object.Rage_ = nil
    --     end

    -- end
    -- self:bindMethod(object,"removeView", removeView, true)
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

            local y2 = y2+15
            object.RageLabel_:setString(string.format("  rage:%d/%d\n  hp:%d/%d",object:getRage(),object:getMaxRage()
                ,object:getHp(),object:getMaxHp()))
            object.RageLabel_:setPosition(cc.p(x2,y2))
        else
            object.hpSprite_:setVisible(false)
            object.hpOutlineSprite_:setVisible(false)
            object.RageLabel_:setVisible(false)
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
    -- self:unbindMethod(object,"removeView")
    self:unbindMethod(object,"updateView")
    self:unbindMethod(object,"fastUpdateView")
    self:unbindMethod(object,"isUnbreakable")
    -- self:unbindMethods(object,"getMaxRageRefix")
    -- self:unbindMethods(object,"getMaxHpRefix")
end
------------------------------------------------------------------------------
return DestroyedBehavior
------------------------------------------------------------------------------