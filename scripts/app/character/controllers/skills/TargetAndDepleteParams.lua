--
-- Author: wangshaopei
-- Date: 2014-08-08 12:06:35
--
local TargetAndDepleteParams = class("TargetAndDepleteParams")
function TargetAndDepleteParams:ctor()
    self:init()
end
function TargetAndDepleteParams:init()
    self.skillId=0
    self.skillLev=0
    self.targets={}
    self.targetId=0
    self.flip=false
    self.nextHitTime=-1                         --特效下次的击中时间
    self.hitTimeCounter=0                       --特效击中时间计数
    self.skillExeTimesCounter=1                 --特效击中次数计数
    self.atkAomuntTime=1000                     --攻击总时间（秒为单位）
    self.hitTimeArr=nil
end
return TargetAndDepleteParams