--
-- Author: wangshaopei
-- Date: 2014-09-02 17:52:46
--
local Command = import(".Command")
local SkillDefine=import("..skills.SkillDefine")
local HeroInSceneCommand = class("HeroInSceneCommand",Command)
function HeroInSceneCommand:ctor(opObj,map,mapEvent)
    HeroInSceneCommand.super.ctor(self)
    self.opObjId_=opObj:GetModel():getId()
    self.rMeView_=opObj
    self.map_=map
    self.mapEvent_=mapEvent
end
function HeroInSceneCommand:execute()
    HeroInSceneCommand.super:execute(self)
    local objectView=self.map_:getObject(self.opObjId_)
    if objectView ~= nil then
        local object = objectView:GetModel()
        if not object:isDead() then
            if object:getClassId() == "hero" then
                local cmd = HeroOperateManager:getFrontCommand(HeroOperateManager.CmdSequence)
                --队列为空，才添加命令
                if HeroOperateManager:isEmpty()  then
                    local skills = object:getSkills()
                    if skills then
                        for k,v in pairs(skills) do
                            if object:getCDs():isCooldownedById(v.id)
                                and object:checkCondition(v.id)
                                and object:isInSceneSkill(v.id)
                            then
                                object:UseSkill(v.id)
                            end
                        end
                    end
                end
                --执行列表的命令
                HeroOperateManager:updata()
                --没有玩家操作命令
                if HeroOperateManager:isEmpty() then
                    --if self:doDoneBefore(object:GetModel()) then
                        --完成此次步骤
                        self:doDone(object)
                    --end
                end
            end
        end
    else
        --对象为空说明这个对象已被删除
        self:doDone()
    end
end
--------------------------------------------------------
function HeroInSceneCommand:doDone(rMe)
    if rMe then
        rMe:updataBout()
    end
    self:setDone(true)
    HeroOperateManager:destroyAllCommands()
end

--------------------------------------------------------
return HeroInSceneCommand

--------------------------------------------------------