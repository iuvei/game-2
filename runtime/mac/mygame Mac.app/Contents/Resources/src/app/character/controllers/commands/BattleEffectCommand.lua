--
-- Author: wangshaopei
-- Date: 2014-10-06 22:39:01
--
local configMgr       = require("config.configMgr")         -- 配置
local MapConstants = require("app.ac.MapConstants")
local OpCommand = import(".OpCommand")
local BattleEffectCommand = class("BattleEffectCommand",OpCommand)
function BattleEffectCommand:ctor(rMe,FuncAktCmdAgain)
    BattleEffectCommand.super.ctor(self,CommandType.BattleEffect)
    self.params_ = rMe:getTargetAndDepleteParams()
    self.rMe_=rMe
    self.rMeView_=rMe:getView()
    self.elapseTime_=0
    self.arrHitTime={}
    -- 效果结束后回调
    self._FuncAktCmdAgain=FuncAktCmdAgain
    self.arrHitTime[1]=0
    self.endTimeInterval_=self.arrHitTime[1]
    --效果攻击时间
    local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(self.params_.skillId)
    if skillEffData then
       --设置击中时间
     self.arrHitTime = string.split(skillEffData.hitTime, MapConstants.SPLIT_SING)
     self.endTimeInterval_=skillEffData.time
    end
end
function BattleEffectCommand:execute()
    --操作开始执行
    if self:getOpState() == HeroOpState.Start then
        --加入技能效果
        self.rMe_:getView():createAttackEff()
        self:setOpState(HeroOpState.Doing)
        self.skillExeTimesCounter=1
    --操作执行进行中
    elseif self:getOpState() == HeroOpState.Doing then

        self.elapseTime_=math.floor(self.elapseTime_+cc.Director:getInstance():getDeltaTime()*1000)
        if self.skillExeTimesCounter <= #self.arrHitTime then
            if self.elapseTime_ >= tonumber(self.arrHitTime[self.skillExeTimesCounter])   then
                --执行攻击效果
                SkillCore:activateSkill(self.rMe_)
                --暂时只执行一次
                self.skillExeTimesCounter = self.skillExeTimesCounter+1
            end
        end
        if self.elapseTime_ >= self.endTimeInterval_ then
            if self._FuncAktCmdAgain then
                 self._FuncAktCmdAgain()
             end
            self:setOpState(HeroOpState.End)
        end
        --print("···",cc.Director:getInstance():getDeltaTime())
        --self.rMeView_:GetModel():updataHits(cc.Director:getInstance():getDeltaTime())
        -- if self.rMeView_:GetModel():getIsStop()==true then
        --    self:setOpState(HeroOpState.End)
        -- end
    end
    --操作执行结束
    if self:getOpState() == HeroOpState.End then

        self:setDone(true)
    end

end
return BattleEffectCommand