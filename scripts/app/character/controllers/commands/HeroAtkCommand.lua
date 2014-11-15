--
-- Author: Your Name
-- Date: 2014-07-22 19:01:06
--
local configMgr       = require("config.configMgr")         -- 配置
local BattleEffectCommand = import(".BattleEffectCommand")
local OpCommand = import(".OpCommand")
local HeroAtkCommand = class("HeroAtkCommand",OpCommand)

function HeroAtkCommand:ctor(rMe,startTime,endTime)
    HeroAtkCommand.super.ctor(self,CommandType.HeroAtk)
    self._rMe=rMe
    self.params_ = rMe:getTargetAndDepleteParams()
    self.rMeView_=rMe:getView()
    --self.rTgtView_=params.targets[1]
    --self.map_=rMe:getMap()
    self.dir_=self.params_.atkDir
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(self.params_.skillId)
    self.endTimeInterval_= skillTemp.actTime
    self.elapseTime_=0
    --self.flip_=params.flip
    -- self.startTime_=startTime
    -- self.endTime_=endTime
end
function HeroAtkCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        self:setOpState(HeroOpState.Doing)

        self.rMeView_:GetModel():setDir(self.dir_)
        local tx, ty = self.rMeView_:getPosition()
        self.rMeView_:GetModel():doAttack(self.endTimeInterval_)

    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then
        self.elapseTime_=math.floor(self.elapseTime_+CCDirector:sharedDirector():getDeltaTime()*1000)
        if  self.elapseTime_ >= self.endTimeInterval_ then
            --加入攻击效果
            --HeroOperateManager:addCommand(BattleEffectCommand.new(self.rMeView_:GetModel()))
            self._rMe:doStopEvent()
            HeroOperateManager:addCommand(BattleEffectCommand.new(self.rMeView_:GetModel()),HeroOperateManager.CmdCocurrent)
            self:setOpState(HeroOpState.End)
        end
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then
        self:setDone(true)
    end

end
function HeroAtkCommand:getStartTime()
    return self.startTime_
end
function HeroAtkCommand:getEndTime()
    return self.endTime_
end
return HeroAtkCommand