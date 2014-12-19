--
-- Author: wangshaopei
-- Date: 2014-11-10 18:28:51
--
local Command = import(".Command")
local SkillDefine=import("..skills.SkillDefine")
local HeroBoutUseSkillCommand = class("HeroBoutUseSkillCommand",Command)
function HeroBoutUseSkillCommand:ctor(opObj,map,skill_id)
    HeroBoutUseSkillCommand.super.ctor(self)
    self.opObjId_=opObj:GetModel():getId()
    self.rMeView_=opObj
    self.map_=map
    -- self.mapEvent_=mapEvent
    self._use_skill_id = skill_id
end
function HeroBoutUseSkillCommand:execute()
    HeroBoutUseSkillCommand.super:execute(self)
    local objectView=self.map_:getObject(self.opObjId_)
    if objectView ~= nil then
        local object = objectView:GetModel()
        if not object:isDead() then
            if object:getClassId() == "hero" then
                local cmd = HeroOperateManager:getFrontCommand(HeroOperateManager.CmdSequence)
                if HeroOperateManager:isEmpty()  then
                    local skill_logic = Skill_GetLogic(object,Skill_GetLogicId(self._use_skill_id))
                    local out_target_views = {}
                    -- 技能作用距离内,满足目标逻辑的对象
                    if skill_logic:calcSkillTargets(object,self._use_skill_id,out_target_views) then
                         object:UseSkill(self._use_skill_id,out_target_views)
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
function HeroBoutUseSkillCommand:doDone(rMe)

    self:setDone(true)
    HeroOperateManager:destroyAllCommands()
end

--------------------------------------------------------
return HeroBoutUseSkillCommand

--------------------------------------------------------