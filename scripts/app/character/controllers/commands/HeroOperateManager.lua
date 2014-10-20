--
-- Author: Your Name
-- Date: 2014-07-22 18:25:11
--
HeroOpState ={}
HeroOpState.Start=1
HeroOpState.Doing=2
HeroOpState.End=3
local HeroOperateManager = {}
function HeroOperateManager:init()
    self.commandLst_={}
end
function HeroOperateManager:addCommand(command)
    if DEBUG_BATTLE.showCommandList then
        print("addCommand:","cmdType:",command:getType(),"opObjId:",command.rMeView_:GetModel():getId())
    end

    table.insert(self.commandLst_,command)
end
function HeroOperateManager:getCommand()
    if not self:isEmpty() then
        return self.commandLst_[1]
    end
    return nil
end
function HeroOperateManager:destroyCommand()
end
function HeroOperateManager:isEmpty()
    return table.nums(self.commandLst_) <= 0
end
function HeroOperateManager:updata()
    self:clearExpireCommands_()
    self:executeCommands_()
end
function HeroOperateManager:executeCommands_()
    local exelst={}
    if table.nums(self.commandLst_)>0 then
        local element = self.commandLst_[1]
        if element:getDone() == false then
           table.insert(exelst,element)
        end
    end
    for i,v in ipairs(exelst) do
        v:execute()
    end
end
function HeroOperateManager:clearExpireCommands_()
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
function HeroOperateManager:destroyAllCommands()
    self.commandLst_={}
end

return HeroOperateManager