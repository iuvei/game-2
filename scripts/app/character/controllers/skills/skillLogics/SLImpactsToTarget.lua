--
-- Author: wangshaopei
-- Date: 2014-08-21 18:18:52
--
--[[
    给目标一个或多个效果

]]
local configMgr       = require("config.configMgr")         -- 配置
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local SkillLogic = import(".SkillLogic")
local CombatCore= require("app.character.controllers.skills.CombatCore")
local OwnImpact = import("app.character.controllers.skills.OwnImpact")
local CommonDefine = require("app.ac.CommonDefine")
local ImpactLogic003 = import("..impactLogics.LogicImpact003")

local SLImpactsToTarget = class("SLImpactsToTarget",SkillLogic)
SLImpactsToTarget.ID=SkillDefine.LogicSkill_ImpToTar
function SLImpactsToTarget:ctor()

end
function SLImpactsToTarget:activateOnce(rMe)
    local target_views ={}
    if not self:getTargets(rMe,target_views) then

    end
    local hits = {{},{}}
    for i=1,#target_views do
        local target_view = target_views[i]
        -- issue:当2次攻击时target_view为空nil
        local target_obj = target_view:GetModel()
        local isCritcalHit = self:critcalHitThisTarget(rMe,target_obj)
        local isHit = self:hitThisTarget(rMe,target_obj)
        if isHit==true then
           table.insert(hits[1],isHit)
           table.insert(hits[2],isCritcalHit)
        end
    end
    if #target_views > 0 then
        self:effectOnMultOnce(rMe,target_views,hits[1],hits[2])
    end

    return true
end
function SLImpactsToTarget:effectOnMultOnce(rMe,target_views,isHits,isCritcalHits)
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    local skillInfo = rMe:getSkillInfo()

    local paramsLst=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skillInfo:getSkillId())
    for i=1,#paramsLst do
        local succ = true
        local params = paramsLst[i]
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
            local target_obj_views = {}
            local target_obj = nil

            -- 按主技能目标逻辑
            if params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToTar then
                for i=1,#target_views do
                    -- 命中
                    local target_obj_view = target_views[i]
                    if isHits[i] then
                        target_obj = target_obj_view:GetModel()
                        local ownImpact = OwnImpact.new()
                        -- 初始化效果数据
                        ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
                        -- 计算伤害值
                        if ImpactLogic003.ID == Impact_GetLogicId(ownImpact) then
                            local combat=CombatCore.new()
                            --计算基本属性值＋身上impact附加的属性值，如物理攻击
                            combat:getResultImpact(rMe, target_obj, ownImpact)
                        end
                        self:registerImpactEvent(target_obj,rMe,ownImpact,isCritcalHits[i])
                    else
                        target_obj_view:createMiss()
                        print("···createMiss")
                    end
                end
            -- 自己定义的目标逻辑
            elseif params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToCustomTar then
                -- 取得目标逻辑
                local tarLogic = params[SkillDefine.SkillParamL_ImpToTar_TarLogic]
                self:getTarsByTarLogic(rMe,tarLogic,1,target_obj_views)
                --
                for i=1,#target_obj_views do
                    target_obj = target_obj_views[i]:GetModel()
                    local ownImpact = OwnImpact.new()
                    ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
                    local imapct_logic_id = Impact_GetLogicId(ownImpact)
                    if ImpactLogic003.ID == imapct_logic_id then
                        local combat=CombatCore.new()
                        --计算基本属性值＋身上impact附加的属性值，如物理攻击
                        combat:getResultImpact(rMe, target_obj, ownImpact)
                    end
                    self:registerImpactEvent(target_obj,rMe,ownImpact,isCritcalHits[i])
                end
            end
        end
    end
end
--根据效果逻辑id取得对应的效果，执行注册
-- function SLImpactsToTarget:effectOnUnitOnce(rMe,rTar,bCritcalHit)
--     local params = rMe:getTargetAndDepleteParams()
--     local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
--     local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
--     local skillInfo = rMe:getSkillInfo()

--     local paramsLst=configMgr:getConfig("skills"):GetSkillAppendImpacParams(skillInfo:getSkillId())
--     for i=1,#paramsLst do
--         local succ = true
--         local params = paramsLst[i]
--          if params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] ~= CommonDefine.INVALID_ID then
--             local rand = math.random(1,CommonDefine.RATE_LIMITE)
--             if rand>=params[SkillDefine.SkillParamL_ImpToTar_ActivateRate] then
--                 if DEBUG_BATTLE.showSkillInfo then
--                      string.format("SLImpactsToTarget:effectOnUnitOnce() - impactId = %d rand:%d >= activateRate:%d return "
--                         ,params[SkillDefine.SkillParamL_ImpToTar_ImpID]
--                         ,rand,params[SkillDefine.SkillParamL_ImpToTar_ActivateRate])
--                 end
--                 succ=false
--             end
--          end
--         if succ then
--             local target_obj_views = {}
--             local target_obj = nil
--             -- local target_obj = rTar

--             -- 按主技能目标逻辑
--             if params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToTar then
--                 local ownImpact = OwnImpact.new()
--             -- 初始化效果数据
--                 ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
--             -- 计算伤害值
--                 if ImpactLogic003.ID == Impact_GetLogicId(ownImpact) then
--                     local combat=CombatCore.new()
--                     --计算基本属性值＋身上impact附加的属性值，如物理攻击
--                     combat:getResultImpact(rMe, rTar, ownImpact)
--                 end
--                 target_obj = rTar
--                 self:registerImpactEvent(target_obj,rMe,ownImpact,false)

--             -- 自己定义的目标逻辑
--             elseif params[SkillDefine.SkillParamL_ImpToTar_Type]==SkillDefine.AppendSkillImpType_ToCustomTar then
--                 -- 取得目标逻辑
--                 local tarLogic = params[SkillDefine.SkillParamL_ImpToTar_TarLogic]
--                 self:getTarsByTarLogic(rMe,tarLogic,1,target_obj_views)
--                 --
--                 for i=1,#target_obj_views do
--                     target_obj = target_obj_views[i]:GetModel()
--                     local ownImpact = OwnImpact.new()
--                     ImpactCore:initImpactFromData(rMe,params[SkillDefine.SkillParamL_ImpToTar_ImpID],ownImpact)
--                     local imapct_logic_id = Impact_GetLogicId(ownImpact)
--                     if ImpactLogic003.ID == imapct_logic_id then
--                         local combat=CombatCore.new()
--                         --计算基本属性值＋身上impact附加的属性值，如物理攻击
--                         combat:getResultImpact(rMe, target_obj, ownImpact)
--                     end
--                     self:registerImpactEvent(target_obj,rMe,ownImpact,false)
--                 end
--             end
--         end
--     end
-- end
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