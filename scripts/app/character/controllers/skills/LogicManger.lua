--
-- Author: wangshaopei
-- Date: 2014-08-22 15:47:47
--
local SkillDefine=import(".SkillDefine")
local SLImpactsToTarget = import(".skillLogics.SLImpactsToTarget")
local SLPassiveSkill = import(".skillLogics.SLPassiveSkill")
local LogicImpact001 = import(".impactLogics.LogicImpact001")
local LogicImpact003 = import(".impactLogics.LogicImpact003")
local LogicImpact004 = import(".impactLogics.LogicImpact004")
local LogicImpact010 = import(".impactLogics.LogicImpact010")
local LogicImpact011 = import(".impactLogics.LogicImpact011")
local LogicImpact014 = import(".impactLogics.LogicImpact014")
local LogicImpact015 = import(".impactLogics.LogicImpact015")
local LogicManger = class("LogicManager")

function LogicManger:ctor(logicType)
    self.logics_={}
    if logicType == SkillDefine.LogicType_Impact then
        self:register(LogicImpact001.new())
        self:register(LogicImpact003.new())
        self:register(LogicImpact004.new())
        self:register(LogicImpact010.new())
        self:register(LogicImpact011.new())
        self:register(LogicImpact014.new())
        self:register(LogicImpact015.new())
    elseif logicType == SkillDefine.LogicType_Skill then
        self:register(SLImpactsToTarget.new())
        self:register(SLPassiveSkill.new())
    end
end
function LogicManger:getLogicByLogicId(logicId)
    return self.logics_[logicId]
end
function LogicManger:register(logic)
    --print("LogicManger:register()",logic.ID)
    self.logics_[logic.ID]=logic
end
return LogicManger