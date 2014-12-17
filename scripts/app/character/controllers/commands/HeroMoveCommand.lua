--
-- Author: Your Name
-- Date: 2014-07-22 19:01:25
--
local OpCommand = import(".OpCommand")
local HeroMoveCommand = class("HeroMoveCommand",OpCommand)
--[[
    target_position_datas=
        {target_cell_position=cellPos,dir=dir}
]]
function HeroMoveCommand:ctor(opObj,mapEvent,target_position_datas)

    HeroMoveCommand.super.ctor(self,CommandType.HeroMove)
    --self.opState_=HeroOpState.Start
    self.mapEvent_=mapEvent
    self._rMe = opObj:GetModel()
    self.rMeView_=opObj
    self.dir_=dir
    self._target_position_datas =target_position_datas
end
function HeroMoveCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        -- local targetPosCell = self.rMeView_:getMap():getDMap():worldPosToCellPos(self.targetPosWorld_ )
        -- if self.rMeView_:getMap():getHeroByCellPos(targetPosCell)~=nil  then
        --     self:setOpState(HeroOpState.End)
        --     self:setDone(true)
        --     return
        -- end
        self:setOpState(HeroOpState.Doing)
       -- local targetPosWorld = MapManager:cellPosToWorldPos(targetPosCell)
         self._rMe:moveToPositions(self._target_position_datas)

         -- object:doMoveEvent(self._target_position_datas)
    end
    --操作执行进行中
    if self:getOpState() == HeroOpState.Doing then
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