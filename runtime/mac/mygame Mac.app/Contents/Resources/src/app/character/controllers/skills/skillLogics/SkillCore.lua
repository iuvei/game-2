--
-- Author: Your Name
-- Date: 2014-08-06 17:51:02
--
local MapConstants  = require("app.ac.MapConstants")
local SkillDefine   =require("app.character.controllers.skills.SkillDefine")
local configMgr     = require("config.configMgr")         -- 配置
---------------------------------------------------------
local SkillCore = class("SkillCore")
---------------------------------------------------------
function Skill_GetLogicId(skillId)
    local skillData = configMgr:getConfig("skills"):GetSkillData(skillId)
    return skillData.logicId
end
function Skill_GetLogic(obj,logicId)
    local skillLogic = obj:getSkillLogicByLogicId(logicId)
    assert(skillLogic~=nil,string.format("Skill_GetLogic() - logic is nil , logicId = %d",logicId))
    return skillLogic
end
---------------------------------------------------------
--
function SkillCore:preocessSkillRequest(rMe,skillId,target_views)
    local rMeView =rMe:getView()
    local params = rMe:getTargetAndDepleteParams()
    params:init()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(skillId)
    local rTarView=nil
    assert(skillId,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))
    -- assert(skillTemp,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))
    assert(skillIns~=0,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))
    local skill_logic = Skill_GetLogic(rMe,Skill_GetLogicId(skillId))
    -- 技能效果范围内的对象
    if not skill_logic:calcSkillEffectTargets(rMe,skillId,target_views) then
         return false
     end
    -- print("------------------skillIns for info:")
    --     table.walk(skillIns, function( v,k)
    --         print(k,v)
    --     end)
    params.skillId = skillIns.id

    --设置参数
    params.targets=target_views
    params.target_type=skillTemp.useTarget_type
    params.skillLev=skillIns.lev

    return  true
end
---------------------------------------------------------
function SkillCore:activeSkillNew(rMe)
    local conf_skills = configMgr:getConfig("skills")
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = conf_skills:GetSkillTemplate(params.skillId)
    local skillIns = conf_skills:GetSkillInstanceBySkillId(params.skillId)
    local skillInfo = rMe:getSkillInfo()
    skillInfo:init()
    -- 暴击系数
    skillInfo.crt_factor = conf_skills:GetInitDataByType(3)
    -- 抗暴击系数
    skillInfo.crtdef_factor = conf_skills:GetInitDataByType(4)

    if self:instanceSkill(skillInfo,rMe) then
     end
     rMe:refixSkill(skillInfo)
     local logicId = skillInfo:getLogicId()
     --取得对应的技能ID
     local skillLogic = Skill_GetLogic(rMe,logicId)
     if skillLogic==nil then return false end
     --前面已检测
     -- if skillLogic:isPassive() then
     --     return false
     -- end
     --skillLogic:getSkillType()
     return skillLogic:startLaunching(rMe)
    --return true
end
function SkillCore:activateSkill(rMe)
    local logicId = rMe:getSkillInfo():getLogicId()
    local skillLogic = Skill_GetLogic(rMe,logicId)
    skillLogic:activate(rMe)
end
---------------------------------------------------------
function SkillCore:instanceSkill(skillInfo,rMe)
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    skillInfo:copy(skillIns)
    skillInfo:copySkillTemp(skillTemp)
    local skillData = configMgr:getConfig("skills"):GetSkillData(params.skillId)
    skillInfo:setLogicId(skillData.logicId)
    return true
end
---------------------------------------------------------
return SkillCore
---------------------------------------------------------