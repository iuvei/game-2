--
-- Author: Your Name
-- Date: 2014-07-22 19:01:25
--
local OpCommand = import(".OpCommand")
local HeroMoveCommand = class("HeroMoveCommand",OpCommand)
function HeroMoveCommand:ctor(opObj,mapEvent,targetPosWorld,dir)

    HeroMoveCommand.super.ctor(self,CommandType.HeroMove)
    --self.opState_=HeroOpState.Start
    self.mapEvent_=mapEvent
    self._rMe = opObj:GetModel()
    self.rMeView_=opObj
    self.dir_=dir
    self.targetPosWorld_ =targetPosWorld
end
function HeroMoveCommand:execute()

    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        local targetPosCell = self.rMeView_:getMap():getDMap():worldPosToCellPos(self.targetPosWorld_ )
        if self.rMeView_:getMap():getHeroByCellPos(targetPosCell)~=nil  then
            self:setOpState(HeroOpState.End)
            self:setDone(true)
            return
        end
        self:setOpState(HeroOpState.Doing)
       -- local targetPosWorld = MapManager:cellPosToWorldPos(targetPosCell)
         self.rMeView_:GetModel():startMoving(self.rMeView_,self.targetPosWorld_.x,self.targetPosWorld_.y)
    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then
        -- if self.rMeView_:GetModel():getIsStop()==true then
        if self._rMe:isState("idle") == true then
           self:setOpState(HeroOpState.End)
        end
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then
        self:setDone(true)
    end
end
return HeroMoveCommand