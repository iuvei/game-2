--
-- Author: wangshaopei
-- Date: 2014-08-21 17:15:56
--
local SkillDefine = import("..SkillDefine")
local configMgr       = require("config.configMgr")         -- 配置
local CommonDefine = require("common.CommonDefine")
local MapConstants    = require("app.ac.MapConstants")
local CombatCore= import("..CombatCore")
local SkillLogic = class("SkillLogic")

function SkillLogic:isPassive()
    return false
end
function SkillLogic:startLaunching(rMe)

    return self:activateOnceHandler(rMe)
end
function SkillLogic:activateOnceHandler(rMe)
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(params.skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    local skillInfo = rMe:getSkillInfo()
    --技能消耗处理
    local bRet = self:depleteProcess(rMe)
    if bRet then
        local activateTimes = skillInfo:getActivateTimes()
        if activateTimes == 0 then
            activateTimes=1
        end
        for i=1,activateTimes do
            if self:activateOnce(rMe)==true then
                 self:effectOtherTarOnUnitOnce(rMe)
             end
        end
    end
    return bRet
end
--消耗处理
function SkillLogic:depleteProcess(rMe)
    local params = rMe:getTargetAndDepleteParams()
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    rMe:increaseRage(-skillIns.consumeRage)
    return true
end
function SkillLogic:activateOnce(rMe)
    local targets ={}
    if not self:getTargets(rMe,targets) then
        return false
    end
    for k,rTarv in pairs(targets) do
        local b = self:critcalHitThisTarget()
        if self:hitThisTarget(rMe,rTarv:GetModel())==true then
           self:effectOnUnitOnce(rMe,rTarv:GetModel(),b)
        else
            rTarv:createMiss()
        end
    end
    return true
end
--主技能目标的效果处理
function SkillLogic:effectOnUnitOnce(rMe,rTar,bCritcalHit)
end
--其他效果处理
function SkillLogic:effectOtherTarOnUnitOnce(rMe)
end
function SkillLogic:registerImpactEvent(rReceiver,rSender,ownImpact,bCritical)
    local skillInfo = rSender:getSkillInfo()
    local params = rSender:getTargetAndDepleteParams()
    ownImpact:setSkillId(skillInfo:getSkillId())
    if bCritical == false then
    end
    rSender:getMap():registerImpactEvent(rReceiver, rSender, ownImpact, bCritical)
end
function SkillLogic:calcTargets(rMe,skillId,targetViews)
    --数据
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)

    local attackDis = skillIns.atkDistance
    self:getTarsByTarLogic(rMe,skillTemp.useTarget_type,attackDis,targetViews)
    if #targetViews<=0 then return false end
    local fristObjv = targetViews[1]

    --更新人物攻击方向
    local selfPos= rMe:getView():getCellPos()
    local targetPos= fristObjv:getCellPos()
    local dir= rMe:calcDir(selfPos,targetPos)
    local flip = true
    if dir== MapConstants.DIR_L then
        flip=false
    end
    params.atkDir=dir
    --params.flip=flip
    if skillIns.atkRangeType==SkillDefine.AtkRange_Around then
        self:getAktRangeAroundTars(rMe,fristObjv,skillId,targetViews,true)
    elseif skillIns.atkRangeType==SkillDefine.AtkRange_Hor then
        self:getAktRangeHorTars(rMe,fristObjv,skillId,targetViews,true)
    else

    end

    return true
end
-------------------------------------------------------------
--取得目标相关
--根据目标逻辑取得目标
function SkillLogic:getTarsByTarLogic(rMe,tarLogicType,attackDis,targetViews)
    local fristObjv = nil
    if SkillDefine.TargetLogic_Self == tarLogicType then
        fristObjv = rMe:getView()
        table.insert(targetViews, fristObjv)
    elseif SkillDefine.TargetLogic_AllEnemy == tarLogicType then
        for k,v in pairs(rMe:getMap():getAllCampObjects(rMe:getEnemyCampId())) do
            if v:GetModel():getClassId()=="hero" then
                table.insert(targetViews, v)
            end
        end
    elseif SkillDefine.TargetLogic_AllTeam == tarLogicType then
        for k,v in pairs(rMe:getMap():getAllCampObjects(rMe:getCampId())) do
            if v:GetModel():getClassId()=="hero" and v:GetModel():getId()~=rMe:getId() then
                table.insert(targetViews, v)
            end
        end
    else
        local objs={}
        if attackDis > 0 then
            --AKT_DIRCTIONS= {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} -- 左，上，下，右
            local dirs = nil
            if  rMe:getDir() == MapConstants.DIR_L then
                dirs=MapConstants.AKT_DIRCTIONS_L
            else
                dirs=MapConstants.AKT_DIRCTIONS_R
            end
            objs = rMe:getAktDirObjsByDisAndCamp(dirs,attackDis,true)
        end
        if #objs<=0 then
            return false
        end
        if SkillDefine.TargetLogic_Enemy_Unit == tarLogicType then
            fristObjv=objs[1]
            table.insert(targetViews, fristObjv)
        elseif SkillDefine.TargetLogic_Team_Unit == tarLogicType then

        end
    end
    return true
end
function SkillLogic:getAktRangeHorTars(rMe,objectView,skillId,targets,isEnemy)
    --数据
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local amount = skillIns.aktRangeParam-1
    local startCellPos = objectView:getCellPos()
    local dir = {{1,0}}
    if params.atkDir == MapConstants.DIR_L then
        dir[1][1]=dir[1][1]*-1
    end
    if amount<0 then return end
    for i=1,amount do
        local p = ccp(startCellPos.x+dir[1][1]*i,startCellPos.y+dir[1][2])
        self:getRangeTars(rMe,p,targets,true)
    end
end
function SkillLogic:getAktRangeAroundTars(rMe,objectView,skillId,targets,isEnemy)
    local params = rMe:getTargetAndDepleteParams()
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local amount = skillIns.aktRangeParam-1
    if amount<=0 then return end
    local startCellPos = objectView:getCellPos()
    local dirs=MapConstants.AKT_DIRCTIONS_R
    if params.atkDir == MapConstants.DIR_L then
        dirs=MapConstants.AKT_DIRCTIONS_L
    end
    if amount > #dirs then
        amount=#dirs
    end
    for i=1,amount do
        local p = ccp(startCellPos.x+dirs[i][1],startCellPos.y+dirs[i][2])
        self:getRangeTars(rMe,p,targets,true)
    end
end
function SkillLogic:getRangeTars(rMe,cellPos,targets,isEnemy)
    local t=rMe:getMap():getHeroByCellPos(cellPos)
    if t and not t:GetModel():isDead() then
        if isEnemy == true then
            if rMe:isEnemyByObj(t:GetModel()) then
                table.insert(targets,t)
            end
        else
            if not rMe:isEnemyByObj(t:GetModel()) then
                table.insert(targets,t)
            end
        end
    end
end
function SkillLogic:getTargets(rMe,targets)
    local params = rMe:getTargetAndDepleteParams()
    --targets=clone(params.targets)
    for i=1,#params.targets do
        table.insert(targets,params.targets[i])
    end
    --targets=params.targets
    --table.insert(targets,params.targets)
    return #targets>0
end
-------------------------------------------------------------
--命中相关
function SkillLogic:critcalHitThisTarget(rMe,target)
    return false
end
function SkillLogic:hitThisTarget(rMe,target)
    if rMe:isFriend(target) then
        --给队友技能100%
        return true
    end
    local skillInfo = rMe:getSkillInfo()
    if self:isHit(rMe,target,skillInfo:getAccuracy()) == false then
        return false
    end
    return true
end
function SkillLogic:isHit(rMe,target,accuracy)
    local myCombat = CombatCore.new()
    if accuracy==CommonDefine.INVALID_ID then
        accuracy=myCombat.calcHitRate(rMe:getHit(),target:getMiss())
    end

    local rand = math.random(1, CommonDefine.RATE_LIMITE)
    return myCombat:isHit(accuracy,rand)

end
function SkillLogic:refix_SkillEffect(skill,attrType,outAttr)
    -- body
end
-----------------------------------------------------------------
return SkillLogic
-----------------------------------------------------------------