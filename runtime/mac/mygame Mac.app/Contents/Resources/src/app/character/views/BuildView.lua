--
-- Author: Your Name
-- Date: 2014-08-04 16:35:42
--
------------------------------------------------------------------------------
local EffectFadeInOut = require("common.effect.FadeInOut")
------------------------------------------------------------------------------
local BuildView = class("BuildView", import(".ObjectView"))
------------------------------------------------------------------------------
function BuildView:ctor(model,params)

    local cls = model.class

    cc.EventProxy.new(model, self)
        :addEventListener(cls.CHANGE_STATE_EVENT, handler(self, self.onStateChange_))
        :addEventListener(cls.BEKILL_EVENT, handler(self, self.onBeKill_))
        :addEventListener(cls.HP_CHANGED_EVENT, handler(self, self.updateHP_))
        --:addEventListener(cls.STOP_EVENT, handler(self,self.onStop_))
        --:addEventListener(cls.READY_EVENT, handler(self,self.onReady_))

    -- 图片资源
    if model:isEnemy() then
        params.img = "#scene_battle_flagsEnemy.png"
    else
        params.img = "#scene_battle_flagsSelf.png"
    end
    -- 父类
    BuildView.super.ctor(self,model,params)
end
------------------------------------------------------------------------------
function BuildView:init(model,params)
    BuildView.super.init(self,model,params)

    self:GetSprite():setScale(0.2)
    --血条位置偏移
    self:GetModel().hpRadiusOffsetX, self:GetModel().hpRadiusOffsetY = 0,10
    -- 血条
    self:GetModel():createView(self:GetBatch("hero"))

    self:updateView()
    -- 更新hp
    self:updateSprite_(self:GetModel():getState())
    self:updateHP_()
end
------------------------------------------------------------------------------
function BuildView:createIdleAction()
    self:GetSprite():stopAllActions()
    --self:GetSprite():setDisplayFrame(frame)
end
------------------------------------------------------------------------------
function BuildView:createBeAttackAction()
    local cls = self:GetModel().class

    self:GetSprite():stopAllActions()
    -- self:GetSprite():setDisplayFrame(frame)

    local moveby_ = 10
    if self:isFlipX() then moveby_ = -10 end

    -- 变红 移动
    local sequence = transition.sequence({
        transition.spawn({
            CCTintBy:create(0.4, 0, 255, 255),
            CCMoveBy:create(0.2, cc.p(moveby_,0)),
        }),
        CCMoveBy:create(0.2, cc.p(-moveby_,0))
    })
    transition.execute( self:GetSprite(),sequence)
end
------------------------------------------------------------------------------
function BuildView:createDeadAction()
    -- 死亡动作
    self:GetSprite():stopAllActions()
   -- self:GetSprite():setDisplayFrame(frame)
    EffectFadeInOut:run(self:GetSprite())
end
------------------------------------------------------------------------------
-- 监听事件
------------------------------------------------------------------------------
function BuildView:onStateChange_(event)
    self:updateSprite_(self:GetModel():getState())
end
------------------------------------------------------------------------------
function BuildView:updateSprite_(state)
    if      state == "idle"         then self:createIdleAction()
    elseif  state == "beattacking"  then self:createBeAttackAction()
    end
end
------------------------------------------------------------------------------
function BuildView:onBeKill_(event)
    self:createDeadAction()
end
------------------------------------------------------------------------------
function BuildView:updateHP_()
    self:GetModel():updateView(self)
end
------------------------------------------------------------------------------
return BuildView
------------------------------------------------------------------------------