--
-- Author: Your Name
-- Date: 2014-07-23 07:52:08
--
local Command = import(".Command")
local OpCommand = class("OpCommand",Command)
function OpCommand:ctor(cmdType)
    OpCommand.super.ctor(self,cmdType)
    self.opState_=HeroOpState.Start
    end
function OpCommand:getOpState()
    return self.opState_
end
function OpCommand:setOpState(state)
    self.opState_=state
end
function OpCommand:execute()

end
return OpCommand