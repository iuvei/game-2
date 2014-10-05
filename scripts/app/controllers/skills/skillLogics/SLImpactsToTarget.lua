--
-- Author: wangshaopei
-- Date: 2014-08-21 18:18:52
--
--[[
    给目标一个或多个效果

]]
local configMgr       = require("config.configMgr")         -- 配置
local SkillDefine=require("app.controllers.skills.SkillDefine")
local SkillLogic = import(".SkillLogic")
local CombatCore= require("app.controllers.skills.CombatCore")
local OwnImpact = import("app.controllers.skills.OwnImpact")
local CommonDefine = require("common.CommonDefine")
local ImpactLogic003 = import("..impactLogics.LogicImpact003")

local SLImpactsToTarget = class("SLImpactsToTarget",SkillLogic)
SLImpactsToTarget.ID=SkillDefine.LogicSkill_ImpToTar
function SLImpactsToTarget:ctor()

end
--根据效果逻辑id取得对应的效果，执行注册
function SLImpactsToTarget:effectOnUnitOnce(rMe,rTar,bCritcalHit)
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    local skillInfo = rMe:getSkillInfo()

    local paramsLst=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skillInfo:getSkillId())
    for i=1,#paramsLst do
        local succ = true
        local params = paramsLst[i]
        -- assert(ImpacteIdData.impactId~=CommonDefine.INVALID_ID,
        --         string.format("effectOnUnitOnce() - ImpacteIdData.impactId == -1,skillId = %d",skillInfo:getSkillId()))
        if params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] ~= CommonDefine.INVALID_ID then
            local rand = math.random(1,CommonDefine.RATE_LIMITE)
            if rand>=params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] then
                if DEBUG_BATTLE.showSkillInfo then
                     string.format("SLImpactsToTarget:effectOnUnitOnce() - impactId = %d rand:%d >= activateRate:%d return "
                        ,params[SkillDefine.SkillParamL_ImpToTar_ImpID]
                        ,rand,params[SkillDefine.SkillParamL_ImpToTar_ActivateRate])
                end
                succ=false
            end
        end
        if succ then
            local ownImpact = OwnImpact.new()
            if params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToTar then
                ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
                if ImpactLogic003.ID == Impact_GetLogicId(ownImpact) then
                    local combat=CombatCore.new()
                    --计算基本属性值＋身上impact附加的属性值，如物理攻击
                    combat:getResultImpact(rMe, rTar, ownImpact)
                end
                self:registerImpactEvent(rTar,rMe,ownImpact,false)
            -- elseif ImpacteIdData.type==SkillDefine.AppendSkillImpType_ToSelf then
            --         ImpactCore:initImpactFromData(rMe,ImpacteIdData.impactId,ownImpact)
            --         self:registerImpactEvent(rMe,rMe,ownImpact,false)
            end
        end
    end
end
--非主技能目标类型的效果处理
function SLImpactsToTarget:effectOtherTarOnUnitOnce(rMe)
    local skillInfo = rMe:getSkillInfo()
    local paramsLst=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skillInfo:getSkillId())
    for i=1,#paramsLst do
        local succ = true
        local params = paramsLst[i]
        if params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToCustomTar then
            if params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] ~= CommonDefine.INVALID_ID then
                local rand = math.random(1,CommonDefine.RATE_LIMITE)
                if rand>=params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] then
                    if DEBUG_BATTLE.showSkillInfo then
                         string.format("SLImpactsToTarget:effectOnUnitOnce() - impactId = %d rand:%d >= activateRate:%d return "
                            ,params[SkillDefine.SkillParamL_ImpToTar_ImpID]
                            ,rand,params[SkillDefine.SkillParamL_ImpToTar_ActivateRate])
                    end
                    succ=false
                end
            end
        end
        if succ then
            local ownImpact = OwnImpact.new()
            if params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToCustomTar then
            local tarLogic = params[SkillDefine.SkillParamL_ImpToTar_TarLogic]
                local targetViews = {}
                self:getTarsByTarLogic(rMe,tarLogic,1,targetViews)
                for i=1,#targetViews do
                    local targetObj = targetViews[i]:GetModel()
                    ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
                    if ImpactLogic003.ID == Impact_GetLogicId(ownImpact) then
                        local combat=CombatCore.new()
                        --计算基本属性值＋身上impact附加的属性值，如物理攻击
                        combat:getResultImpact(rMe, targetObj, ownImpact)
                    end
                    self:registerImpactEvent(targetObj,rMe,ownImpact,false)
                end
            end
        end
    end
end
-------------------------------------------------------------------
return SLImpactsToTarget
-------------------------------------------------------------------