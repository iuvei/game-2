--
-- Author: wangshaopei
-- Date: 2014-09-04 00:36:21
--
local GameTimer = class("GameTimer")
function GameTimer:ctor()
    self.timeCounter=0
end
function GameTimer:resetTime()
    self.timeCounter=0
end
function GameTimer:getNewTime()
    return self.timeCounter
end
function GameTimer:update(deltaTime)
    self.timeCounter = self.timeCounter + deltaTime
end
return GameTimer