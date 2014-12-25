--
-- Author: Your Name
-- Date: 2014-07-22 19:01:06
--
local configMgr       = require("config.configMgr")         -- 配置
local BattleEffectCommand = import(".BattleEffectCommand")
local OpCommand = import(".OpCommand")
local HeroAtkCommand = class("HeroAtkCommand",OpCommand)

function HeroAtkCommand:ctor(rMe,aspeed,startTime,endTime)
    HeroAtkCommand.super.ctor(self,CommandType.HeroAtk)
    self._rMe=rMe
    self.params_ = rMe:getTargetAndDepleteParams()
    self.rMeView_=rMe:getView()
    -- 方向
    self.dir_=self.params_.atkDir
    -- 加速度
    local aspeed_ = aspeed or 1
    -- 攻击时间
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(self.params_.skillId)
    self.endTimeInterval_= skillTemp.actTime/aspeed_
    self.elapseTime_=0
    -- 攻击次数
    if skillTemp.atkOrGatherTims == -1 then
        skillTemp.atkOrGatherTims=1
    end
    self._times_atk = skillTemp.atkOrGatherTims
    self._times_count=0
    -- 延迟时间

end
function HeroAtkCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        if self._rMe:isDead() then
            self:setDone(true)
            return
        end
        self.elapseTime_=0

        self:setOpState(HeroOpState.Doing)

        self.rMeView_:GetModel():setDir(self.dir_)

        local options = {
            cooldown = self.endTimeInterval_,
        }
        self.rMeView_:GetModel():doAttack(options)
        -- 激活技能
        SkillCore:activeSkillNew(self._rMe)
        -- 攻击次数
        -- local skillLogic = Skill_GetLogic(rMe,rMe:getSkillInfo():getLogicId())
        -- self._times_atk = skillLogic:getTimesAtk()
    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then
        local time_interval = cc.Director:getInstance():getDeltaTime()*1000
        self.elapseTime_=math.floor(self.elapseTime_+time_interval)
        if  self.elapseTime_ >= self.endTimeInterval_ then
            self._rMe:doStopEvent()
            -- 计数
            self._times_count = self._times_count + 1
            -- 多次攻击会回调
            local FuncAktCmdAgain = nil
            if self._times_count < self._times_atk then
                self:setOpState(HeroOpState.None)
                 FuncAktCmdAgain = function ()
                    if #self._rMe.targetAndDepleteParams_.targets > 0 then
                        self:setOpState(HeroOpState.Start)
                    else
                        self:setOpState(HeroOpState.End)
                    end

                end
            end
            --加入攻击效果
            HeroOperateManager:addCommand(BattleEffectCommand.new(self._rMe,FuncAktCmdAgain),HeroOperateManager.CmdCocurrent)
            --完成
            if not FuncAktCmdAgain then
                self:setOpState(HeroOpState.End)
            end
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