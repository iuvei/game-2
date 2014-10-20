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
function SkillCore:preocessSkillRequest(rMe,skillId)
    local rMeView =rMe:getView()
    local params = rMe:getTargetAndDepleteParams()
    params:init()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(skillId)
    local rTarView=nil
    assert(skillId,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))
    assert(skillTemp,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))
    assert(skillIns~=0,string.format("[preocessSkillRequest]: skillTemp is nil , invalid skillId %d", skillId))

    --攻击范围内目标
    local targets = {}
    local logic = Skill_GetLogic(rMe,Skill_GetLogicId(skillId))
    if logic:calcTargets(rMe,skillId,targets) == false then
         return
     end
    -- print("------------------skillIns for info:")
    --     table.walk(skillIns, function( v,k)
    --         print(k,v)
    --     end)
    params.skillId = skillIns.id

    --默认攻击总时间为动作完成时间
    params.atkAomuntTime=skillTemp.actTime
    if skillEffData then
       --设置击中时间
        params.hitTimeArr = string.split(skillEffData.hitTime, MapConstants.SPLIT_SING)
        --设置攻击时间
        if params.atkAomuntTime < skillEffData.time then
            params.atkAomuntTime=skillEffData.time
        end
    end
    if params.hitTimeArr==nil then
        params.hitTimeArr={}
        params.hitTimeArr[1]=skillTemp.actHitTime
    end
    if #params.hitTimeArr > 0 then
        params.nextHitTime=tonumber(params.hitTimeArr[1])
        params.skillExeTimesCounter=params.skillExeTimesCounter+1
    end

    --设置参数
    params.targets=targets
    params.skillLev=skillIns.lev
   -- params.atkDir=dir
    --params.flip=flip

    return  true
    -- local bRet = self:activeSkillNew(rMe)
    -- if bRet==false then

    -- end
    -- return bRet
end
---------------------------------------------------------
function SkillCore:activeSkillNew(rMe)
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    local skillInfo = rMe:getSkillInfo()
    skillInfo:init()
    if self:instanceSkill(skillInfo,rMe) then
     end
     rMe:refixSkill(skillInfo)
     local logicId = skillInfo:getLogicId()
     local skillLogic = Skill_GetLogic(rMe,logicId)
     if skillLogic==nil then return false end
     if skillLogic:isPassive() then
         return false
     end
     --skillLogic:getSkillType()
     return skillLogic:startLaunching(rMe)
    --return true
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