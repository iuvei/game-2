--
-- Author: wangshaopei
-- Date: 2014-08-12 19:07:38
--
local MapConstants    = require("app.ac.MapConstants")
local OpCommand = import(".OpCommand")
local HeroCGCommand = class("HeroCGCommand",OpCommand)
function HeroCGCommand:ctor(rMe)

    HeroCGCommand.super.ctor(self,CommandType.CG)
    self.rMe_=rMe
    self.rMeView_=rMe:getView()
end
function HeroCGCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        self:setOpState(HeroOpState.Doing)
        local x,y = 0,0
        local tx,ty = 0,0
        local sprite = display.newSprite("effect/bigHead.png",x,y):addTo(self.rMe_:getMap(),MapConstants.MAP_Z_3_0)
        if self.rMe_:isEnemy() then
            x,y=display.width+sprite:getContentSize().width/2,display.cy
            tx,ty = display.width-sprite:getContentSize().width/2,display.cy
        else
            x,y=-sprite:getContentSize().width/2,display.cy
            tx,ty = sprite:getContentSize().width/2,display.cy
            sprite:setFlipX(true)
        end
        sprite:setPosition(cc.p(x,y))

        local sequence = transition.sequence({
            CCMoveTo:create(0.3, cc.p(tx,ty)),
            CCDelayTime:create(0.2),
            CCEaseExponentialIn:create(CCFadeOut:create(0.5)),
            CCDelayTime:create(0.5),
        })

        transition.execute(sprite, sequence, {
        onComplete = function()
            self:setOpState(HeroOpState.End)
            sprite:removeSelf()
        end,
    })
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then
        self:setDone(true)
    end
end

-------------------------------------------------------------------------------
return HeroCGCommand
-------------------------------------------------------------------------------