--
-- Author: Anthony
-- Date: 2014-06-24 16:30:19
--
------------------------------------------------------------------------------
--[[--

“英雄”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]
------------------------------------------------------------------------------
local MapConstants      = require("app.ac.MapConstants")
local SkillDefine       = import("..controllers.skills.SkillDefine")
local DelayCommand = require("app.character.controllers.commands.DelayCommand")
local configMgr         = require("config.configMgr")         -- 配置
local EffectFadeInOut   = require("common.effect.FadeInOut")  -- 淡入淡出特效
local Formation         = import(".HeroFormation")  -- 方阵
local baseBullet        = import("..models.baseBullet")
------------------------------------------------------------------------------
local HeroView = class("HeroView", import(".ObjectView"))
------------------------------------------------------------------------------
function HeroView:ctor(model,params)
    local cls = model.class

    -- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    --
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    cc.EventProxy.new(model, self)
        :addEventListener(cls.CHANGE_STATE_EVENT, handler(self, self.onStateChange_))
        :addEventListener(cls.BEKILL_EVENT, handler(self, self.onBeKill_))
        :addEventListener(cls.HP_CHANGED_EVENT, handler(self, self.updateHP_))
        -- :addEventListener(cls.STOP_EVENT, handler(self,self.onStop_))
        :addEventListener(cls.READY_EVENT, handler(self,self.onMove_))
        -- :addEventListener(cls.ENTER_ATTACKING, handler(self, self.onEnterAttacking_))
        :addEventListener(cls.ATTACK_EVENT, handler(self, self.onAttack_))
        -- :addEventListener(cls.FINISH_EVENT, handler(self, self.onAtkFinish_))
        :addEventListener(cls.BEFORE_EVENT, handler(self, self.onBefore_))
        :addEventListener(cls.BEATTACK_EVENT, handler(self, self.onBeAttack_))
        -- :addEventListener(cls.BEATTACK_OVER_EVENT, handler(self, self.onBeAttackOver_))
    -- 图片资源
    params.img = "#"..configMgr:getConfig("heros"):GetArmArtById(model:getArmId(),"idle",model:isEnemy())
    -- 父类
    HeroView.super.ctor(self,model,params)
end
------------------------------------------------------------------------------
function HeroView:init(model,params)
    ----------------------------------------------------------
    HeroView.super.init(self,model,params)
    ----------------------------------------------------------
    -- 生成方阵
    Formation:handleFormation(self,"create",{ img = params.img })

    ----------------------------------------------------------
    -- 显示头像
    local headIcon = configMgr:getConfig("heros"):GetHerosArt(self:GetModel():getArtId()).headIcon
    self.headIcon_ = display.newSprite(headIcon):scale(0.4):addTo(self)
    -------------------------------------------------------
    -- 显示文字
    -- local color = display.COLOR_BLACK
    -- if self:GetModel():isEnemy() then
    --     color = display.COLOR_BLACK
    -- else
    --     color = display.COLOR_WHITE
    -- end

    -- self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
    --         text = string.format("%s", hero:getNickname()),
    --         size = 15,
    --         color = color,
    --     })
    --     :addTo(self)

    -- -- 位置
    self.headIcon_:setPosition(0,20)
    -- self.idLabel_:setPosition(12,25)
    -------------------------------------------------------
    --血条位置偏移
    self:GetModel().hpRadiusOffsetX, self:GetModel().hpRadiusOffsetY = 0,10
    -- 血条
    self:GetModel():createView(self:GetBatch())
    self:updateView()
    --
    self:updateSprite_(self:GetModel():getState())
    -- 更新hp
    self:updateHP_()
end
------------------------------------------------------------------------------
-- 退出
function HeroView:onExit()
    local headIcon = configMgr:getConfig("heros"):GetHerosArt(self:GetModel():getArtId()).headIcon
    display.removeSpriteFrameByImageName(headIcon)
    -- 最后删除
    HeroView.super.onExit(self)
end
------------------------------------------------------------------------------
--
function HeroView:onEnter()

end
------------------------------------------------------------------------------
-- 更新
function HeroView:updateView()
    HeroView.super.updateView(self)
    -- 方阵
    Formation:handleFormation(self,"update",{
        contentSize = self:GetSprite():getContentSize(),
        x           = self:getPositionX(),
        y           = self:getPositionY(),
        isFlipX     = self:isFlipX()
    })
    -- self:GetModel():updataHits()
    --self:updataImpacts()
end
-- function HeroView:updataImpacts()
--     for k,v in pairs(self.impactSprite_) do
--         local x,y = self:getPosition()
--         v:setPosition(cc.p(x, y))
--     end
-- end

------------------------------------------------------------------------------
-- 快速更新
function HeroView:fastUpdateView()
    HeroView.super.fastUpdateView(self)
end
------------------------------------------------------------------------------
function HeroView:flipX(flip)
    HeroView.super.flipX(self,flip)

    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:flipX(flip)
    end})
    return self
end
------------------------------------------------------------------------------
-- 监听事件
------------------------------------------------------------------------------
-- 每个事件开始前调用
function HeroView:onBefore_(event)

end
------------------------------------------------------------------------------
function HeroView:onStateChange_(event)
-- <<<<<<< HEAD
    self:_updataState(self:GetModel():getState(),event)
-- =======
    -- self:_updateSprite(self:GetModel():getState())
-- end
------------------------------------------------------------------------------
-- function HeroView:_updateSprite(state)
--     if      state == "idle"          then
--         self:createIdleAction()
--     elseif  state == "attacking"     then
--         self:createAttackAction()
--     elseif  state == "moving"        then
--         self:createWalkAction()
--     elseif  state == "beattacking"   then
--         self:createBeAttackAction()
--     end
-- >>>>>>> game_fight_ai
end
------------------------------------------------------------------------------
function HeroView:onBeKill_(event)
    self:removeImpactsEffect()
    self:createDeadAction()
end
function HeroView:onBeAttack_(event)
    self:createBeAttackAction()
    local options = event.options
    if CommandManager:getFrontCommand().opObjId_ == options.rece_obj:getId() then
        HeroOperateManager:addCommand(DelayCommand.new(options.rece_obj,options.cooldown),HeroOperateManager.CmdSequence)
    else
        HeroOperateManager:addCommand(DelayCommand.new(options.rece_obj,options.cooldown),HeroOperateManager.CmdCocurrent)
    end
end
-- function HeroView:onBeAttackOver_(event)
--     -- self:GetModel():setIsStop(true)
-- end
------------------------------------------------------------------------------
function HeroView:onStop_(event)
    -- self:GetModel():stop()
end
------------------------------------------------------------------------------
function HeroView:onMove_(event)
    -- 移动到指定位置，默认为格子位置
    -- self.model_:moveToPositions(self,event.options)
end
-- function HeroView:onAtkFinish_( event )
--     self:GetModel():stop()
-- end
------------------------------------------------------------------------------
-- function HeroView:onEnterAttacking_()
-- end
------------------------------------------------------------------------------
--
-- <<<<<<< HEAD
function HeroView:onAttack_(event)
    local options = event.options
    self:createAttackAction(options.cooldown)
end
-- =======
-- function HeroView:onAttack_()
--     self:createAttackAction()
-- end
-- >>>>>>> game_fight_ai
------------------------------------------------------------------------------
function HeroView:updateHP_()
    self:GetModel():updateView(self)

    -- 处理方阵
    Formation:handleFormation(self,"dead",{
        callback = function ( _sprite,_callback )
            --- 播放死亡动画
            self:createDeadActionOne( _sprite, _callback)
    end})
end
-- <<<<<<< HEAD

------------------------------------------------------------------------------
function HeroView:updateSprite_(state,event)
    if      state == "idle"          then self:createIdleAction()
    --elseif  state == "attacking"     then self:createAttackAction()
    elseif  state == "moving"        then self:createWalkAction()
    elseif  state == "beattacking"   then
        -- self:createBeAttackAction()
    end
end
function HeroView:_updataState(state,event)
    self:updateSprite_(state,event)
    if      state == "idle"          then
    elseif  state == "attacking"     then
    elseif  state == "moving"        then
    elseif  state == "beattacking"   then
        -- local options = event.options
        -- if CommandManager:getFrontCommand().opObjId_ == options.rece_obj:getId() then
        --     print("···lllll",options.cooldown)
        --     HeroOperateManager:addCommand(DelayCommand.new(options.rece_obj,options.cooldown),HeroOperateManager.CmdSequence)
        -- else
        --     print("···rrrr",options.cooldown)
        --     HeroOperateManager:addCommand(DelayCommand.new(options.rece_obj,options.cooldown),HeroOperateManager.CmdCocurrent)
        -- end
    end
end
-- =======
-- >>>>>>> game_fight_ai
------------------------------------------------------------------------------
function HeroView:createIdleAction()
    local frameName =configMgr:getConfig("heros")
                        :GetArmArtById(self:GetModel():getArmId(),"idle",self:GetModel():isEnemy())
    local frame = display.newSpriteFrame(frameName)

    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:stopAllActions()
            sprite:setSpriteFrame(frame)
    end})
end
------------------------------------------------------------------------------
function HeroView:createAttackAction(cooldown)
    --local cls = self:GetModel().class
    local params = self:GetModel():getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    -- local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)

    local actTime = cooldown/1000
    local frameName = configMgr:getConfig("heros")
                        :GetArmArtById(self:GetModel():getArmId(),"attck",self:GetModel():isEnemy())
    local frames    = display.newFrames(frameName, 1, 4)
    local animation = display.newAnimation(frames,  actTime/#frames)--cls.ATTACK_COOLDOWN

    --技能名称
    self:createSkillNameEff(skillTemp.nickname)

    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:stopAllActions()
            transition.playAnimationOnce(sprite,animation)
    end})
end
------------------------------------------------------------------------------
function HeroView:createMiss()
    local x,y = self:getPosition()
    local label = cc.ui.UILabel.newTTFLabel_({
                            text = "Miss",
                            size = 20,
                            color = display.COLOR_RED,
                        })
                        :pos(x,y)
                        :addTo(self:GetModel():getMap(),MapConstants.MAP_Z_1_0)
    transition.execute(label, CCMoveTo:create(1,cc.p(x,y+50)), {
    easing = "backout",
    onComplete = function()
        label:removeSelf()
    end,
    })
end
function HeroView:createSkillNameEff(name)
    local x,y = self:getPosition()
    local label = cc.ui.UILabel.newTTFLabel_({
                            text = name,
                            size = 30,
                            color = display.COLOR_BLACK,
                        })
                        :pos(x,y)
                        :addTo(self:GetModel():getMap(),MapConstants.MAP_Z_1_0)
    transition.execute(label, CCMoveTo:create(1, cc.p(x,y+50)), {
    easing = "backout",
    onComplete = function()
        label:removeSelf()
    end,
    })
end
function HeroView:createAttackEff()
    local params = self:GetModel():getTargetAndDepleteParams()
    local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(params.skillId)
    if skillEffData == nil then return false end
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local frameName = skillEffData.name
    local x,y=0,0
    local tx,ty=0,0
    local scale_ = skillEffData.scale/100
    local arrOffset = string.split(skillEffData.tarOffsetPos, MapConstants.SPLIT_SING)
    local sprite =nil
    -- if skillEffData.effMoveType == SkillDefine.EffType_Origin then
    --     x,y = self:getPosition()
    --     sprite:setPosition(cc.p(x,y))
    --     local onComplete = function()
    --         --print("move completed")
    --     end
    --     --播放完成精灵自动删除
    --     transition.playAnimationOnce(sprite,animation,true,onComplete)
    -- end
    for i=1,#params.targets do
        local rTarView=params.targets[i]
        if skillEffData.effMoveType == SkillDefine.EffType_FakeFly then
            -- table.walk(skillEffData, function(v,k)
            --     print(k,v)
            -- end)
            local frames  = display.newFrames(frameName, 1, skillEffData.amountFrames)
            local time = skillEffData.time/1000

            local animation = display.newAnimation(frames, time/skillEffData.amountFrames)
            local sprite = display.newSprite():addTo(self:GetModel():getMap(),MapConstants.MAP_Z_2_0)
            tx,ty = rTarView:getPosition()

            sprite:setPosition(cc.p(tx+arrOffset[1],ty+arrOffset[2]))
            local onComplete = function()
                --print("move completed")
            end
            --播放完成精灵自动删除
            transition.playAnimationOnce(sprite,animation,true,onComplete)
        elseif skillEffData.effMoveType == SkillDefine.EffType_Parabolic then
            tx,ty = rTarView:getPosition()
            x,y= self:getPosition()
            local map = self:GetModel():getMap()
            baseBullet.new(self:GetModel(), cc.p(x,y),cc.p(tx+arrOffset[1],ty+arrOffset[2]),frameName,scale_):addTo(map,MapConstants.MAP_Z_2_0)
        end
    end

end
------------------------------------------------------------------------------
function HeroView:createBeAttackAction()
    -- local params = self:GetModel():getTargetAndDepleteParams()
    -- local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(params.skillId)
    -- print("skillEffData.hitTime",skillEffData.hitTime)

    local cls = self:GetModel().class
    local frameName = configMgr:getConfig("heros")
                        :GetArmArtById(self:GetModel():getArmId(),"beattck",self:GetModel():isEnemy())
    local frame     = display.newSpriteFrame(frameName)

    local moveby_ = 10
    if self:isFlipX() then moveby_ = -10 end

    -- heroview后移
    -- local sequence = transition.sequence({
    --     transition.spawn({
    --         CCDelayTime:create(0.4),
    --         CCMoveBy:create(0.2, cc.p(moveby_,0)),
    --     }),
    --     CCMoveBy:create(0.2, cc.p(-moveby_,0))
    -- })
    -- transition.execute(self,sequence)

    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:stopAllActions()
            sprite:setSpriteFrame(frame)

            -- 变红 移动
            -- local sequence = transition.sequence({
            --     transition.spawn({
            --         CCTintBy:create(0.4, 0, 255, 255),
            --         CCMoveBy:create(0.2, cc.p(moveby_,0)),
            --     }),
            --     CCMoveBy:create(0.2, cc.p(-moveby_,0))
            -- })
            -- transition.execute(sprite,sequence)
            -- transition.execute(sprite)
    end})
    --一般攻击效果
    -- self:createImpactEffect(1,false)
end
------------------------------------------------------------------------------
function HeroView:createWalkAction()
    local frameName = configMgr:getConfig("heros")
                        :GetArmArtById(self:GetModel():getArmId(),"move",self:GetModel():isEnemy())
    local frames    = display.newFrames(frameName, 1, 2)
    local animation = display.newAnimation(frames, 0.5 / 3)

    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:stopAllActions()
            transition.playAnimationForever(sprite,animation)
    end})
end
------------------------------------------------------------------------------
function HeroView:createDeadFrame()
    -- 死亡动作
    local frameName = configMgr:getConfig("heros")
                        :GetArmArtById(self:GetModel():getArmId(),"dead",self:GetModel():isEnemy())
    return display.newSpriteFrame(frameName)
end
------------------------------------------------------------------------------
function HeroView:createDeadAction()
    -- 方阵
    Formation:handleFormation(self,"callback",{
        callback = function ( sprite )
            sprite:stopAllActions()
            sprite:setSpriteFrame(self:createDeadFrame())
            local params={
                time1 = 0.4,
            }
            EffectFadeInOut:run(sprite)
    end})
end
------------------------------------------------------------------------------
function HeroView:createDeadActionOne(sprtie,_callback)
    if sprtie then
        sprtie:stopAllActions()
        sprtie:setSpriteFrame(self:createDeadFrame())
        EffectFadeInOut:run(sprtie,{onComplete = _callback})
    end

end
------------------------------------------------------------------------------
return HeroView
------------------------------------------------------------------------------