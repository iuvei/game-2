--
-- Author: Your Name
-- Date: 2014-07-21 16:37:32
--
CommandType= {}
CommandType.None="none"
CommandType.HeroOp="HeroOp"
CommandType.HeroAtk="HeroAtk"
CommandType.HeroMove="HeroMove"

local CommandManager = {}
function CommandManager:init()
    self.commandLst_={}
end
function CommandManager:addCommand(command)

    table.insert(self.commandLst_,command)
end
function CommandManager:destroyCommand()
end
function CommandManager:isEmpty()
    return table.nums(self.commandLst_) <= 0
end
function CommandManager:updata()
    self:clearExpireCommands_()
    self:executeCommands_()
end
function CommandManager:executeCommands_()
    local exelst={}
    if table.nums(self.commandLst_)>0 then
        local element = self.commandLst_[1]
        if element:getDone() == false then
           table.insert(exelst,element)
        end
    end
    for i,v in ipairs(exelst) do
        v:execute()
        --v:setDone(true)
    end
end
function CommandManager:clearExpireCommands_()
    local delIndexLst = {}
    for i,v in ipairs(self.commandLst_) do
        if v:getDone() then
            table.insert(delIndexLst,i)
        end
    end
    for i,v in ipairs(delIndexLst) do
        table.remove(self.commandLst_,v)
    end
end
function CommandManager:destroyAllCommands()
    self.commandLst_={}
end

return CommandManager