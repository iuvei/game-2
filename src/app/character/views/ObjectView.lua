--
-- Author: Anthony
-- Date: 2014-08-05 10:30:43
--
------------------------------------------------------------------------------
local MapConstants  = require("app.ac.MapConstants")
local configMgr     = require("config.configMgr")         -- 配置
------------------------------------------------------------------------------
local ObjectView = class("ObjectView", function()
    return display.newNode()
end)
------------------------------------------------------------------------------
function ObjectView:ctor(model,params)
    -- 允许显示对象的事件
    self:setNodeEventEnabled(true)

    -- model里面也存视图数据
    model:setView(self)
    self.model_     = model
    self.sprite_    = nil
    self.impactSprite_={}               --保存效果显示的精灵用来删除
    self._pos_cell = nil
end
------------------------------------------------------------------------------
function ObjectView:init(model,params)
    -- 生成sprite
    if params.img then
        self.sprite_ = display.newSprite(params.img)
        self:GetBatch():addChild(self.sprite_,params.zorder or MapConstants.MAX_OBJECT_ZORDER)
    end

    -- 设置是否翻转
    if params.flipx ~= nil then self:flipX(params.flipx) end
    -- 设置坐标
    self:setPosition(cc.p(params.x,params.y))
    self:updataCellPos()
end
------------------------------------------------------------------------------
-- 退出
function ObjectView:onExit()
    self:removeView()
    -- self.model_:removeView()
    self.model_ = nil
end
------------------------------------------------------------------------------
--
function ObjectView:onEnter()

end
------------------------------------------------------------------------------
--
function ObjectView:removeView()
    if self.model_.hpOutlineSprite_ then
        self.model_.hpOutlineSprite_:removeSelf()
        self.model_.hpOutlineSprite_ = nil
    end
    if self.model_.hpSprite_ then
        self.model_.hpSprite_:removeSelf()
        self.model_.hpSprite_ = nil
    end

    if self.model_.RageLabel_ then
        -- print("···data",s)
        -- issue :删除报错
        -- self.model_.RageLabel_:removeSelf()
        self.model_.RageLabel_ = nil
    end
    -- print("···en")
end
------------------------------------------------------------------------------
--所在地图
function ObjectView:getMap()
    return self:GetModel():getMap()
end
------------------------------------------------------------------------------
-- 得到model
function ObjectView:GetModel()
    return self.model_
end
------------------------------------------------------------------------------
function ObjectView:GetSprite()
    return self.sprite_
end
------------------------------------------------------------------------------
-- 得到批量渲染
function ObjectView:GetBatch(classId)
    local model = self:GetModel()
    if classId == nil or classId == ""  then
        classId = model:getClassId()
    end

    return model:getMap():GetBatch(classId)
end
------------------------------------------------------------------------------
function ObjectView:flipX(flip)
    self.sprite_:flipX(flip)
    -- self:GetModel():setDir(flip)
    return self
end
------------------------------------------------------------------------------
function ObjectView:isFlipX()
    return self.sprite_:isFlippedX()
end
------------------------------------------------------------------------------
-- 更新
function ObjectView:updateView()
    local sprite = self.sprite_
    if sprite then
        -- sprite:setPosition(cc.p(self:getPosition()))
        sprite:setPosition(cc.p(self:getPosition()))
    end
    self:updataImpacts()
end
------------------------------------------------------------------------------
-- 快速更新
function ObjectView:fastUpdateView()
    self:updateView()
end
------------------------------------------------------------------------------
--效果特效更新
function ObjectView:updataImpacts()
    for k,v in pairs(self.impactSprite_) do
        local x,y = self:getPosition()
        v:setPosition(cc.p(x, y))
    end
end
function ObjectView:removeImpactsEffect()
    for k,v in pairs(self.impactSprite_) do
        self:removeImpactEffect(k)
    end
end
function ObjectView:removeImpactEffect(resEffectId)
    local c = self.impactSprite_[resEffectId]
    assert(c~=nil,string.format("removeEffect() - sprite is nil,resEffectId = %d", resEffectId))
    c:removeSelf()

    self.impactSprite_[resEffectId]=nil

end
------------------------------------------------------------------------------
--被攻击的效果特效
function ObjectView:createImpactEffect(resEffectId,isRepeatPlay,effectPoint)
    -- assert(resEffectId~=1)
    local resEffectData = configMgr:getConfig("skills"):GetSkillEffectByEffectId(resEffectId)
    assert(resEffectData~=nil,string.format("createBuffEff() - resEffectData is nil,resEffectId = %d",resEffectId))
    if self.impactSprite_[resEffectId] then
        return
    end
    --创建精灵
    local arrOffset = string.split(resEffectData.tarOffsetPos, MapConstants.SPLIT_SING)
    local scale_ = resEffectData.scale/100
    local x,y = self:getPosition()
    local sprite = display.newSprite()
    sprite:setPosition(cc.p(x+arrOffset[1],y+arrOffset[2]))
    sprite:setScale(scale_)
    if effectPoint==nil or effectPoint == 1 then -- 人物身上
        self:GetModel():getMap():addChild(sprite,MapConstants.MAP_Z_2_0)
    elseif effectPoint == 2 then -- 在地上
        self:GetModel():getMap():addChild(sprite,MapConstants.MAP_Z_0_0)
    end
    --创建动画
    local frameName = resEffectData.name
    local time = resEffectData.time/1000
    local frames  = display.newFrames(frameName, 1, resEffectData.amountFrames)
    local animation = display.newAnimation(frames, time/resEffectData.amountFrames)
    --播放动画
    if isRepeatPlay then
        transition.playAnimationForever(sprite, animation, 0)
        -- 一直存在就会放到数组里
        self.impactSprite_[resEffectId] = sprite
    else
        local onComplete = function()
        --print("move completed")
        end
        --播放完成精灵自动删除
        transition.playAnimationOnce(sprite,animation,true,onComplete)
    end
end
------------------------------------------------------------------------------
function ObjectView:getCellPos()
    return self._pos_cell
end
------------------------------------------------------------------------------
--
function ObjectView:updataCellPos()
    self._pos_cell = self:_getCellPos()
end
------------------------------------------------------------------------------
--取得自己的格子坐标
function ObjectView:_getCellPos()
    local x,y = self:getPosition()
    return self:getMap():getDMap():worldPosToCellPos(cc.p(x,y))
end
------------------------------------------------------------------------------
function ObjectView:createIdleAction()
end
------------------------------------------------------------------------------
function ObjectView:createBeAttackAction()
end
------------------------------------------------------------------------------
function ObjectView:createDeadAction()
end
------------------------------------------------------------------------------
return ObjectView
------------------------------------------------------------------------------
