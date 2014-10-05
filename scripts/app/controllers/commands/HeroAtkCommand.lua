--
-- Author: Your Name
-- Date: 2014-07-22 19:01:06
--
local OpCommand = import(".OpCommand")
local HeroAtkCommand = class("HeroAtkCommand",OpCommand)

function HeroAtkCommand:ctor(rMe,startTime,endTime)
    HeroAtkCommand.super.ctor(self,CommandType.HeroAtk)
    local params = rMe:getTargetAndDepleteParams()
    self.rMeView_=rMe:getView()
    --self.rTgtView_=params.targets[1]
    self.map_=rMe:getMap()
    self.dir_=params.atkDir
    --self.flip_=params.flip
    self.startTime_=startTime
    self.endTime_=endTime
end
function HeroAtkCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        self:setOpState(HeroOpState.Doing)
        --self.rMeView_:flipX(self.flip_)
        self.rMeView_:GetModel():setDir(self.dir_)
        local tx, ty = self.rMeView_:getPosition()
        --local posX,posY = self.rTgtView_:getPosition()
        self.rMeView_:GetModel():doAttack()
        --if self.rMeView_:GetModel():getType()=="gongbing" then
        --    baseBullet.new( self.map_:GetBatch(), ccp(tx,ty),ccp(posX,posY)):addTo(self.map_)
        --end

    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then
        --print("···",CCDirector:sharedDirector():getDeltaTime())
        --self.rMeView_:GetModel():updataHits(CCDirector:sharedDirector():getDeltaTime())
        if self.rMeView_:GetModel():getIsStop()==true then
           self:setOpState(HeroOpState.End)
        end
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then

        self:setDone(true)
    end

end
function HeroAtkCommand:executing()
    -- body
end
function HeroAtkCommand:executeEnd()

end
function HeroAtkCommand:checkEndCondition()
    return true
end
function HeroAtkCommand:getStartTime()
    return self.startTime_
end
function HeroAtkCommand:getEndTime()
    return self.endTime_
end
return HeroAtkCommand