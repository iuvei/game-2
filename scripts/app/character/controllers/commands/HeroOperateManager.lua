--
-- Author: Your Name
-- Date: 2014-07-22 18:25:11
--
HeroOpState ={}
HeroOpState.Start=1
HeroOpState.Doing=2
HeroOpState.End=3
local HeroOperateManager = {}
HeroOperateManager.CmdSequence=1
HeroOperateManager.CmdCocurrent=2
function HeroOperateManager:init()
    self.commandLst_={}
    self.commandCocurrentLst_={}
end
function HeroOperateManager:addCommand(command,asyType)
    asyType = asyType or HeroOperateManager.CmdSequence
    if DEBUG_BATTLE.showCommandList then
        print("addCommand:","cmdType:",command:getType(),"asyType:",asyType,"opObjId:",command.rMeView_:GetModel():getId())
    end
    if asyType == HeroOperateManager.CmdSequence then
        table.insert(self.commandLst_,command)
    else
        table.insert(self.commandCocurrentLst_,command)
    end

end
function HeroOperateManager:getFrontCommand(asyType)
    if self:isEmptyByType(asyType) then
        return nil
    end
    if HeroOperateManager.CmdSequence==asyType then
        return self.commandLst_[1]
    else
        return self.commandCocurrentLst_[1]
    end
end
function HeroOperateManager:destroyCommand()
end
function HeroOperateManager:isEmptyByType(asyType)
    if asyType == HeroOperateManager.CmdSequence then
        return table.nums(self.commandLst_) <= 0
    else
        return table.nums(self.commandCocurrentLst_) <= 0
    end
end
function HeroOperateManager:isEmpty()
    if table.nums(self.commandLst_) +  table.nums(self.commandCocurrentLst_) == 0 then
        return true
    end
    return false
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
    --
    for k,v in pairs(self.commandCocurrentLst_) do
        if v:getDone() == false then
            v:execute()
        end
    end
end
function HeroOperateManager:clearExpireCommands_()
    for i=#self.commandLst_,1,-1 do
        local cmd= self.commandLst_[i]
        if cmd:getDone() then
            if DEBUG_BATTLE.showCommandList then
                print("delCommand:","cmdType:",cmd:getType(),"opObjId:",cmd.rMeView_:GetModel():getId())
            end
            table.remove(self.commandLst_,i)
        end
    end

    for i=#self.commandCocurrentLst_,1,-1 do
        local cmd= self.commandCocurrentLst_[i]
        if cmd:getDone() then
            if DEBUG_BATTLE.showCommandList then
                print("delCommand:","cmdType:",cmd:getType(),"opObjId:",cmd.rMeView_:GetModel():getId())
            end

            table.remove(self.commandCocurrentLst_,i)
        end
    end
end
function HeroOperateManager:destroyAllCommands()
    self.commandLst_={}
    self.commandCocurrentLst_={}
end

return HeroOperateManager