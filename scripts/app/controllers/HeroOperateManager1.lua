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
    local startTime = command:getStartTime()
    local lst=self.commandLst_[startTime]
    if lst==nil then
        self.commandLst_[startTime]={}
        table.insert(self.commandLst_[startTime],command)
    else
        table.insert(lst,command)
    end
    return true
end
-- function HeroOperateManager:getCommand()
--     if not self:isEmpty() then
--         return self.commandLst_[1]
--     end
--     return nil
-- end
function HeroOperateManager:destroyCommand()
end
function HeroOperateManager:isEmpty()
    return table.nums(self.commandLst_) <= 0
end
function HeroOperateManager:updata()
    self:clearExpireCommands_()
    local nowTime = GameTimer:getNewTime()*1000
    self:executeCommands_(nowTime)
end
function HeroOperateManager:executeCommands_(nowTime)
    local exelst={}
    -- if table.nums(self.commandLst_)>0 then
    --     local element = self.commandLst_[1]
    --     if element:getDone() == false then
    --        table.insert(exelst,element)
    --     end
    -- end
    for k,cmdLst in pairs(self.commandLst_) do
        if nowTime>=k then
            for i=1,#cmdLst do
                local cmd=cmdLst[i]
                if cmd:getOpState()~=HeroOpState.End then
                    table.insert(exelst,cmd)
                end
            end
        end
    end
    for i=1,#exelst do
        local c=exelst[i]
        if c:getOpState() == HeroOpState.Start then
            c:execute()
            c:setOpState(HeroOpState.Doing)
            c:executing()
        elseif c:getOpState()==HeroOpState.Doing then
            if nowTime>=c:getEndTime() and c:checkEndCondition() then
                c:executeEnd()
                c:setOpState(HeroOpState.End)
            else
                c:executing()
            end
        end
    end

end
function HeroOperateManager:clearExpireCommands_()
    local delIndexLst = {}
    for k,cmdLst in pairs(self.commandLst_) do
        for i=1,#cmdLst do
            local cmd=cmdLst[i]
            if cmd:getOpState()==HeroOpState.End then
                table.insert(delIndexLst,{key=k,index=i})
            end
        end
    end
    for i,del in ipairs(self.delIndexLst) do
        table.remove(self.commandLst_[del.key],del.index)
        if #self.commandLst_[del.key]==0 then
            self.commandLst_[del.key]=nil
        end
    end
end
function HeroOperateManager:destroyAllCommands()
    self.commandLst_={}
end

return HeroOperateManager