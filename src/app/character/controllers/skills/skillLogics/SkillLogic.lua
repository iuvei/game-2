--
-- Author: wangshaopei
-- Date: 2014-08-21 17:15:56
--
local SkillDefine = import("..SkillDefine")
local configMgr       = require("config.configMgr")         -- 配置
local CommonDefine = require("app.ac.CommonDefine")
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

    --技能消耗处理,前面已做了检测此处肯定成功
    local bRet = self:depleteProcess(rMe)
    return bRet
end
function SkillLogic:activate(rMe)
    local skillInfo = rMe:getSkillInfo()
    local activateTimes = skillInfo:getActivateTimes()
    if activateTimes == 0 then
        activateTimes=1
    end
    if activateTimes == 0 then
        return false
    end
    activateTimes = activateTimes - 1
    if self:activateOnce(rMe)==true then
        -- self:effectOtherTarOnUnitOnce(rMe)
    end

    return true
end
-- 执行一次
function SkillLogic:activateOnce(rMe)
    local targets ={}
    if not self:getTargets(rMe,targets) then

    end
    for k,rTarv in pairs(targets) do
        local tar_obj = rTarv:GetModel()
        local b = self:critcalHitThisTarget(rMe,tar_obj)
        if self:hitThisTarget(rMe,rTarv:GetModel())==true then
           self:effectOnUnitOnce(rMe,rTarv:GetModel(),b)
        else
            rTarv:createMiss()
        end
    end
    return true
end

--消耗处理
function SkillLogic:depleteProcess(rMe)
    local params = rMe:getTargetAndDepleteParams()
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(params.skillId)
    rMe:increaseRage(-skillIns.consumeRage)
    return true
end

--主技能目标的效果处理
function SkillLogic:effectOnUnitOnce(rMe,rTar,bCritcalHit)
end
function SkillLogic:effectOnMultOnce(rMe,rTar,isHits,isCritcalHits)
end
--其他效果处理
function SkillLogic:effectOtherTarOnUnitOnce(rMe)
end
-- 添加并执行效果
function SkillLogic:registerImpactEvent(rReceiver,rSender,ownImpact,bCritical)
    local skillInfo = rSender:getSkillInfo()
    local params = rSender:getTargetAndDepleteParams()
    ownImpact:setSkillId(skillInfo:getSkillId())
    if bCritical == false then
    end
    rSender:getMap():registerImpactEvent(rReceiver, rSender, ownImpact, bCritical)
end
-- 技能效果范围内的对象
function SkillLogic:calcSkillEffectTargets(rMe,skillId,targetViews)
    --数据
    local params = rMe:getTargetAndDepleteParams()
    -- local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    -- local attackDis = skillIns.atkDistance
    -- local target_logic = skillTemp.useTarget_type
    local isChaos = rMe:isChaos()
    -- if rMe:isChaos() then
    --     -- target_type=self:_toInverseTargetLogic(target_type)
    --     target_type=SkillDefine.TargetLogic_All
    -- end
    -- -- 根据目标逻辑计算攻击目标
    -- local out_target_views = {}
    -- self:getTarsByTarLogic(rMe,target_logic,attackDis,out_target_views)
    -- if #out_target_views<=0 then return false end
    -- -- 选择全体不需要在计算技能范围
    -- if target_logic == SkillDefine.TargetLogic_All or
    --     target_logic == SkillDefine.TargetLogic_AllEnemy or
    --     target_logic == SkillDefine.TargetLogic_AllTeam
    --     then
    --     targetViews = out_target_views
    --     return true
    -- end
    -- -- 混乱
    -- if isChaos then
    --     local rand = math.random(1,#out_target_views)
    --     table.insert(targetViews, out_target_views[rand])
    -- else
    --     table.insert(targetViews, out_target_views[1])
    -- end

    -- 更新人物攻击方向
    local fristObjv = targetViews[1]
    local selfPos= rMe:getView():getCellPos()
    local targetPos= fristObjv:getCellPos()
    local dir= rMe:calcDir(selfPos,targetPos)
    params.atkDir=dir

    -- 技能攻击范围无效不处理
    if skillIns.atkRangeType == -1 then
        return true
    end
    local select_type = "enemy"
    if isChaos then
        select_type = "all"
    end
    -- 根据技能范围增加攻击目标
    if skillIns.atkRangeType==SkillDefine.AtkRange_Around then
        self:getAktRangeAroundTars(rMe,skillId,targetViews,select_type)
    elseif skillIns.atkRangeType==SkillDefine.AtkRange_Hor then
        self:getAktRangeHorTars(rMe,skillId,targetViews,select_type)
    else

    end

    return true
end
-- 技能作用距离内,满足目标逻辑的对象
function SkillLogic:calcSkillTargets(rMe,skillId,out_target_views)
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local attackDis = skillIns.atkDistance
    local target_logic = skillTemp.useTarget_type

    local isChaos = rMe:isChaos()
    -- 根据目标逻辑计算攻击目标
    local out_target_views_ = {}
    self:getTarsByTarLogic(rMe,target_logic,attackDis,out_target_views_)
    if #out_target_views_<=0 then return false end
    -- 选择全体不需要在计算技能范围
    if target_logic == SkillDefine.TargetLogic_All or
        target_logic == SkillDefine.TargetLogic_AllEnemy or
        target_logic == SkillDefine.TargetLogic_AllTeam
        then
        out_target_views = out_target_views_
        return true
    end
    -- 混乱
    if isChaos then
        local rand = math.random(1,#out_target_views_)
        table.insert(out_target_views, out_target_views_[rand])
    else
        table.insert(out_target_views, out_target_views_[1])
    end
    return #out_target_views_>0
end
-- 转换逻辑目标为对立
function SkillLogic:_toInverseTargetLogic(target_logic)
    if target_logic == SkillDefine.TargetLogic_Enemy_Unit then
        return SkillDefine.TargetLogic_Team_Unit
    elseif target_logic == SkillDefine.TargetLogic_AllEnemy then
        return SkillDefine.TargetLogic_AllTeam
    elseif target_logic == SkillDefine.TargetLogic_Team_Unit then
        return SkillDefine.TargetLogic_Enemy_Unit
    elseif target_logic == SkillDefine.TargetLogic_AllTeam then
        return SkillDefine.TargetLogic_AllEnemy
    end
    return target_logic
end
-------------------------------------------------------------
--取得目标相关
--根据目标逻辑取得目标
function SkillLogic:getTarsByTarLogic(rMe,tarLogicType,attackDis,targetViews)
    local options = {
        out_target_views = targetViews,
        cell_positions = {},
        use_target_type = tarLogicType,
        is_contain_sender = false,
        sender_obj = rMe,
    }
    -- AKT_DIRCTIONS = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} -- 左，上，下，右
    local dirs = nil
    if  rMe:getDir() == MapConstants.DIR_L then
        dirs = MapConstants.AKT_DIRCTIONS_L
    else
        dirs = MapConstants.AKT_DIRCTIONS_R
    end
    -- 检测攻击距离，－1时设为0，可能目标为自己
    if attackDis < 0 then attackDis = 0 end
    local cell_pos = rMe:getView():getCellPos()
    for i=1, #dirs do
        local offset =dirs[i]
        for j=1,attackDis do
            local p=cc.p(cell_pos.x+offset[1]*j, cell_pos.y+offset[2]*j)
            table.insert(options.cell_positions,p)
        end
    end
    -- objs = rMe:getAktDirObjsByDisAndCamp(dirs,attackDis,true)
    rMe:getMap():scanByTargetLogic(options) -- options={out_targets,cell_positions,use_target_type,is_contain_sender,sender_obj}
end
function SkillLogic:getAktRangeHorTars(rMe,skillId,target_views,select_type)

     local options = {
        out_target_views=target_views,
        cell_positions={},
        target_type="enemy",
        sender_obj_id=rMe:getId()
    }
    if select_type == "enemy" then
        if rMe:getEnemyCampId() == MapConstants.PLAYER_CAMP then
            options.target_type = "player"
        end
    elseif select_type == "all" then
        options.target_type = "all"
    end
    --数据
    local params = rMe:getTargetAndDepleteParams()
    local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local amount = skillIns.aktRangeParam-1
    local startCellPos = target_views[1]:getCellPos()
    local dir = {{1,0}}
    if params.atkDir == MapConstants.DIR_L then
        dir[1][1]=dir[1][1]*-1
    end
    if amount<0 then return end
    for i=1,amount do
        local p = cc.p(startCellPos.x+dir[1][1]*i,startCellPos.y+dir[1][2])
        table.insert(options.cell_positions,p)
        -- self:_getRangeTars(rMe,p,targets,true)
    end
    rMe:getMap():scan(options)
end
function SkillLogic:getAktRangeAroundTars(rMe,skillId,target_views,select_type)
    local params = rMe:getTargetAndDepleteParams()
    local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
    local amount = skillIns.aktRangeParam-1
    if amount<=0 then return end
    local startCellPos = target_views[1]:getCellPos()
    local dirs=MapConstants.AKT_DIRCTIONS_R
    if params.atkDir == MapConstants.DIR_L then
        dirs=MapConstants.AKT_DIRCTIONS_L
    end
    if amount > #dirs then
        amount=#dirs
    end
    local options = {
    out_target_views=target_views,
    cell_positions={},
    target_type="enemy",
    sender_obj_id = rMe:getId(),
    }
    if select_type == "enemy" then
        if rMe:getEnemyCampId() == MapConstants.PLAYER_CAMP then
            options.target_type = "player"
        end
    elseif select_type == "all" then
        options.target_type = "all"
    end
    for i=1,amount do
        local p = cc.p(startCellPos.x+dirs[i][1],startCellPos.y+dirs[i][2])
        -- self:_getRangeTars(rMe,p,targets,true)
        table.insert(options.cell_positions,p)
    end
    rMe:getMap():scan(options) -- options={out_targets,cell_positions,target_type}
    -- special_obj._map:scan(options) -- options={out_targets,cell_positions,target_type}
end
function SkillLogic:_getRangeTars(rMe,cellPos,targets,isEnemy)
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
    if not params.targets or #params.targets==0 then
        return
    end
    --targets=clone(params.targets)
    for i=1,#params.targets do
        table.insert(targets,params.targets[i])
    end
    return #targets>0
end
-------------------------------------------------------------
--命中相关
function SkillLogic:critcalHitThisTarget(rMe,target)
    local skllinfo=rMe:getSkillInfo()
    local myCombat = CombatCore.new()

    local accuracy=myCombat:calcCrtRate(rMe:getAttr2(CommonDefine.RoleAttr_Crt),
        skllinfo.crt_factor,
        rMe:getAttr2(CommonDefine.RoleAttr_Crtdef),
        skllinfo.crtdef_factor
        ) * CommonDefine.RATE_LIMITE_100
    local rand = math.random(1, CommonDefine.RATE_LIMITE_100)
    return myCombat:isCrtHit(accuracy,rand)
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
        accuracy=myCombat:calcHitRate(rMe:getHit(),target:getMiss()) * CommonDefine.RATE_LIMITE_100
    end

    local rand = math.random(1, CommonDefine.RATE_LIMITE_100)
    return myCombat:isHit(accuracy,rand)

end
function SkillLogic:refix_SkillEffect(rMe,skill,attrType,outAttr)
    -- body
end
--
function SkillLogic:getTimesAtk()
    return 1
end
-----------------------------------------------------------------
return SkillLogic
-----------------------------------------------------------------