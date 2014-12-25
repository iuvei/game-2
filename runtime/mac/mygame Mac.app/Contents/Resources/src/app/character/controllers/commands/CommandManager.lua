--
-- Author: Your Name
-- Date: 2014-07-21 16:37:32
--
CommandType= {}
CommandType.None="none"
CommandType.HeroOp="HeroOp"
CommandType.HeroAtk="HeroAtk"
CommandType.HeroMove="HeroMove"
CommandType.BattleEffect="BattleEffect"
CommandType.Delay="Delay"
CommandType.CG="CG"

local CommandManager = {}
function CommandManager:init()
    self.commandLst_={}
end
function CommandManager:addCommand(command)
    table.insert(self.commandLst_,command)
end
function CommandManager:destroyCommand()
end
function CommandManager:getFrontCommand()
    return self.commandLst_[1]
end
function CommandManager:getCmds()
    return self.commandLst_
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
    for i=#self.commandLst_,1,-1 do
        local cmd= self.commandLst_[i]
        if cmd:getDone() then
            -- if DEBUG_BATTLE.showCommandList then
            --     print("delCommand:","cmdType:",cmd:getType(),"opObjId:",cmd.rMeView_:GetModel():getId())
            -- end
            table.remove(self.commandLst_,i)
        end
    end
end
function CommandManager:destroyAllCommands()
    self.commandLst_={}
end

return CommandManager