--
-- Author: wangshaopei
-- Date: 2014-10-21 14:36:19
--
local configMgr       = require("config.configMgr")         -- 配置
local OpCommand = import(".OpCommand")
local DelayCommand = class("DelayCommand",OpCommand)
function DelayCommand:ctor(rMe,endTimeInterval)
    DelayCommand.super.ctor(self,CommandType.Delay)
    self._params = rMe:getTargetAndDepleteParams()
    self.rMeView_=rMe:getView()
    self._endTimeInterval= endTimeInterval
    self._elapseTime=0
end
function DelayCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        self:setOpState(HeroOpState.Doing)

    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then
        self._elapseTime=math.floor(self._elapseTime+CCDirector:sharedDirector():getDeltaTime()*1000)

        if self._endTimeInterval <= self._elapseTime then
            --加入攻击效果
            self:setOpState(HeroOpState.End)
        end
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then
        self:setDone(true)
    end

end
return DelayCommand