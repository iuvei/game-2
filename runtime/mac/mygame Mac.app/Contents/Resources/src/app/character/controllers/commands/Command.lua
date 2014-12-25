--
-- Author: Your Name
-- Date: 2014-07-21 16:19:54
--
local Command = class("Command")
function Command:ctor(cmdType)
    self.isDone_=false
    self.cmdType_= cmdType or CommandType.none
    end
function Command:getDone()
    return self.isDone_
end
function Command:setDone(isDone)
    self.isDone_=isDone
end
function Command:getType()
    return self.cmdType_
end
function Command:execute()

end
return Command