--
-- Author: Your Name
-- Date: 2014-07-24 17:01:49
--
local math2d = require("common.math2d")
local configMgr       = require("config.configMgr")         -- 配置
local HeroAtkCommand=require("app.character.controllers.commands.HeroAtkCommand")
local HeroMoveCommand = require("app.character.controllers.commands.HeroMoveCommand")
local HeroCGCommand = require("app.character.controllers.commands.HeroCGCommand")
local MapConstants      = require("app.ac.MapConstants")
local BehaviorBase = require("app.character.controllers.behaviors.BehaviorBase")
local AICharacterBehavior = class("AICharacterBehavior", BehaviorBase)
function AICharacterBehavior:ctor()
    AICharacterBehavior.super.ctor(self, "AICharacterBehavior",
        {"StateMachineBehavior","DestroyedBehavior","MovableBehavior","SkillBehavior"},
        1)
end
------------------------------------------------------------------------------
function AICharacterBehavior:bind(object)
    self.object__=object
    self:bindMethods(object)

    self:reset(object)
    -- object:ResetAI()
end
------------------------------------------------------------------------------
function AICharacterBehavior:unbind(object)
    self:unbindMethods(object)
end
------------------------------------------------------------------------------
function AICharacterBehavior:reset(object)

end
------------------------------------------------------------------------------
function AICharacterBehavior:bindMethods(object)
    ----------------------------------------
    local function ResetAI()
        object._target_view = nil
        object._cur_select_skill = nil
        object._atk_distance = nil
        object._action_point={move = 1,attack=1}
    end
    self:bindMethod(object,"ResetAI", ResetAI)
    ----------------------------------------
    -- 强攻阵 : 寻找最近的敌人进行攻击
    local function AI(object,map_event)
        if object._target_view == nil then
        -- if object._action_point.move + object._action_point.attack >= 2 then
            for k,v in pairs(object:getMap():getAllObjects())  do
                v:updataCellPos()
            end
            object._target_view = object:findNearestEnemy(map_event,false)
            object._cur_select_skill = object:getSelectSkill()
            object._atk_distance = object:GetAtkDistance()
            object._action_point={move = 1,attack=1}
        end
        if object._target_view then

            --攻击范围内目标
            local skill_logic = Skill_GetLogic(object,Skill_GetLogicId(object._cur_select_skill.id))
            local out_target_views = {}
            -- 技能作用距离内,满足目标逻辑的对象
            skill_logic:calcSkillTargets(object,object._cur_select_skill.id,out_target_views)

            local isInRange = #out_target_views > 0

            if object._action_point.attack > 0 and isInRange and not object:isState("attacking") and object:canAttack() then

                HeroOperateManager:destroyCommandByType(CommandType.HeroMove)
                if not object:UseSkill(object._cur_select_skill.id,out_target_views) then
                    assert(false,"888"..object:getNickname())
                end
                object:doStopEvent()
                object._action_point.attack = object._action_point.attack - 1
                object._action_point.move = object._action_point.move - 1
            elseif object._action_point.move > 0 and not isInRange and not object:isState("moving") and object:canMove() then
                object:UpdataMove(map_event)
                object._action_point.move = object._action_point.move - 1
            end
        end
    end
    self:bindMethod(object,"AI", AI)
    local function GetAtkDistance(object)
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(object._cur_select_skill.id)
        return skillIns.atkDistance
    end
    self:bindMethod(object,"GetAtkDistance", GetAtkDistance)
    local function UpdataMove(object,map_event)
        local cell_pos_begin = object:getView():getCellPos()
        local cell_pos_end = object._target_view:getCellPos()
        local shortestSteps= AStarUtil:findPath(cell_pos_begin ,cell_pos_end,map_event,object:getView())
        if not shortestSteps then
            return false
        end
        local target_position_datas = {}
        for i=1,object:getMoveDistance() do
            if table.nums(shortestSteps)>=i then
                local cellPosPre = cell_pos_begin
                local preStep = shortestSteps[i-1]
                if preStep then
                    cellPosPre=preStep.pos
                end
                local cellPos= shortestSteps[i].pos
                local dir= object:calcDir(cellPosPre,cellPos)

                -- local targetPosWorld = mapEvent:getMap():getDMap():cellPosToWorldPos(cellPos)
                -- HeroOperateManager:addCommand(HeroMoveCommand.new(object,mapEvent,targetPosWorld,dir))
                target_position_datas[#target_position_datas+1]={target_cell_position=cellPos,dir=dir}
             end
        end
        for i=1,#target_position_datas do
            local t = {target_position_datas[i]}
            HeroOperateManager:addCommand(HeroMoveCommand.new(object:getView(),mapEvent,t))
        end

    end
    self:bindMethod(object,"UpdataMove", UpdataMove)
    -- local function AILogicMove(object,mapEvent)
    --     local object = object:getView()
    --     if object:GetModel():isMoving() then
    --         return false
    --     end
    --     if not object:GetModel():canMove() then
    --         return false
    --     end

    --     local tx, ty = object:getPosition()
    --     local cellPosSelf = mapEvent:getMap():getDMap():worldPosToCellPos(cc.p(tx,ty))
    --     local cellPosEnemy=nil
    --     -- if object:GetModel():getType()=="gongbing" then
    --     if math.floor(object:GetModel():getArmId() / 1000) == 3 then
    --         cellPosEnemy=object:GetModel():getMovePosWayFindNearEnemy(mapEvent,false)
    --     else
    --         cellPosEnemy=object:GetModel():getMovePosWayForRow(mapEvent)
    --     end
    --     if not cellPosEnemy then return false end
    --     local shortestSteps= AStarUtil:findPath(cellPosSelf ,cellPosEnemy,mapEvent,object)
    --     if not shortestSteps then
    --         return false
    --     end
    --     local target_position_datas = {}
    --     for i=1,object:GetModel():getMoveDistance() do
    --         if table.nums(shortestSteps)>=i then
    --             local cellPosPre = cellPosSelf
    --             local preStep = shortestSteps[i-1]
    --             if preStep then
    --                 cellPosPre=preStep.pos
    --             end
    --             local cellPos= shortestSteps[i].pos
    --             local dir= object:GetModel():calcDir(cellPosPre,cellPos)

    --             -- local targetPosWorld = mapEvent:getMap():getDMap():cellPosToWorldPos(cellPos)
    --             -- HeroOperateManager:addCommand(HeroMoveCommand.new(object,mapEvent,targetPosWorld,dir))
    --             target_position_datas[#target_position_datas+1]={target_cell_position=cellPos,dir=dir}
    --          end
    --     end
    --     HeroOperateManager:addCommand(HeroMoveCommand.new(object,mapEvent,target_position_datas))
    --     return true
    -- end
    -- self:bindMethod(object,"AILogicMove", AILogicMove)
    ----------------------------------------
    -- AI攻击逻辑
    -- local function AILogicAkt(object,mapEvent)
    --     local ov = object:getView()
    --     -- if object:isState("moving") then
    --     --     return false
    --     -- ends
    --     if object:isState("attacking") then
    --         return false
    --     end
    --     if not object:canAttack() then
    --         return false
    --     end
    --     --判断人物当前是否可使用技能

    --     --取得人物要使用的技能
    --      --local ownSkill = object:getSkills()[1]
    --     local ownSkill = object:getSelectSkill()
    --     if ownSkill == nil then return false end

    --     if DEBUG_BATTLE.showSkillInfo then
    --         -- print("SelectSkill:")
    --         -- showTableInfo(ownSkill)
    --         -- print("----------------------")
    --     end

    --     --执行技能
    --     if not object:UseSkill(ownSkill.id) then
    --         return false
    --     end
    --     --local dis = math.floor(math2d.dist(selfPos.x, selfPos.y, targetPos.x, targetPos.y))

    --     return true
    -- end
    -- self:bindMethod(object,"AILogicAkt", AILogicAkt)
    -- local function SelectTargetObjs(object,target_views)
    --     local ownSkill = object:getSelectSkill()
    --     if ownSkill == nil then return false end
    --    if not object.skillCore_:preocessSkillRequest(object,ownSkill.skillId) then
    --         object:getTargetAndDepleteParams():init()
    --         return false
    --     end
    --     target_views=object:getTargetAndDepleteParams().targets
    --     return true
    -- end
    -- self:bindMethod(object,"SelectTargetObjs", SelectTargetObjs)
    ----------------------------------------
    --找最近的敌人
    local function findNearestEnemy(object,mapEvent,isPriSelectRow)
        local object_view = object:getView()

        local camp = object:getCampId()
        if camp == MapConstants.PLAYER_CAMP then
            camp = MapConstants.ENEMY_CAMP
        elseif camp == MapConstants.ENEMY_CAMP then
            camp = MapConstants.PLAYER_CAMP
        end

        -- local mx,my = object:getPosition()
        local cellPosSelf = object_view:getCellPos() -- local cellPosSelf = mapEvent:getMap():getDMap():worldPosToCellPos(cc.p(mx,my))

        local disInfo={}
        for id, object_view_ in pairs(mapEvent.map_:getAllCampObjects(camp)) do
            if object_view_ and object_view_:GetModel():getClassId() == "hero" and not object_view_:GetModel():isDead() then
                local dis = math2d.dist(cellPosSelf.x, cellPosSelf.y, object_view_:getCellPos().x, object_view_:getCellPos().y)
                  -- print("···ppppp",object:getId(),dis,cellPosSelf.x,cellPosSelf.y,object_view_:getCellPos().x,object_view_:getCellPos().y)
                    table.insert(disInfo,{dis_=dis,enemy_obj_view=object_view_})
            end
        end

        if table.nums(disInfo)>0 then
            table.sort(disInfo,function(a, b) return a.dis_ < b.dis_ end)
            -- for i=1,#disInfo do
            --     print("···",object:getId(),disInfo[i].dis_)
            -- end
            --是否优先选择同一行的敌人
            if isPriSelectRow then
                for i,target in ipairs(disInfo) do
                    -- local tx,ty = target.enemyObj:getPosition()
                    -- local cellPosEnemy = mapEvent:getMap():getDMap():worldPosToCellPos(cc.p(tx,ty))
                    local cellPosEnemy = target.enemy_obj_view:getCellPos()
                    --TODO 找到同一线上的，需改成按规则查找
                    if cellPosEnemy.y == cellPosSelf.y then
                        return target.enemy_obj_view
                    end
                end
            end
            return disInfo[1].enemy_obj_view
        end
        return nil
    end
    self:bindMethod(object,"findNearestEnemy", findNearestEnemy)
    local function getAktDirObjsByDis(object,aktDirs,dis)
        local targets = {}
        local ov = object:getView()
        local sCellPos = ov:getCellPos()
        for i=1, #aktDirs do
            local offset =aktDirs[i]
            for j=1,dis do
                local p=cc.p(sCellPos.x+offset[1]*j, sCellPos.y+offset[2]*j)
                local t=object:getMap():getHeroByCellPos(p)
                if t and not t:GetModel():isDead() then
                    table.insert(targets,t)
                end
            end
        end
        return targets
    end
    self:bindMethod(object,"getAktDirObjsByDis", getAktDirObjsByDis)
    ----------------------------------------
    --移动方式：横向移动
    local function getMovePosWayForRow(object,mapEvent)
        local object = object:getView()
        local mx,my = object:getPosition()
        local startCellPos = mapEvent:getMap():getDMap():worldPosToCellPos(cc.p(mx,my))
        local target = startCellPos
        local camp = object:GetModel():getCampId()
        if camp == MapConstants.PLAYER_CAMP then
            camp = MapConstants.ENEMY_CAMP
            --local s =mapEvent:getMap():getDMap():getMapSize()
            --target.x=s.width-2
        elseif camp == MapConstants.ENEMY_CAMP then
            camp = MapConstants.PLAYER_CAMP
            --target.x=1
        end
        target = mapEvent:getMap():getAktBuildByCamp(camp)
        return target
    end
    self:bindMethod(object,"getMovePosWayForRow", getMovePosWayForRow)
    ----------------------------------------
    --移动方式：找最近的敌人
    local function getMovePosWayFindNearEnemy(object,mapEvent,isPriSelectRow)
        local enemy =object:findNearestEnemy(mapEvent,isPriSelectRow)
        local mx,my=enemy:getPosition()
        return mapEvent:getMap():getDMap():worldPosToCellPos(cc.p(mx,my))
    end
    self:bindMethod(object,"getMovePosWayFindNearEnemy", getMovePosWayFindNearEnemy)
    ----------------------------------------
    --
    local function calcDir(object,startPos,tarPos)
        local dy = tarPos.y-startPos.y
        local dx = tarPos.x-startPos.x
        local dir = object:getDir()
        if dx < 0 then
            dir = MapConstants.DIR_L
        elseif dx > 0 then
            dir = MapConstants.DIR_R
        elseif dy > 0 then
            dir = MapConstants.DIR_D
        elseif dy < 0 then
            dir = MapConstants.DIR_T
        end
        return dir
    end
    self:bindMethod(object,"calcDir", calcDir)
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function AICharacterBehavior:unbindMethods(object)
    -- self:unbindMethod(object,"AILogicMove")
    -- self:unbindMethod(object,"AILogicAkt")
    self:unbindMethod(object,"findNearestEnemy")
    self:unbindMethod(object,"calcMoveDir")
    self:unbindMethod(object,"getMovePosWayFindNearEnemy")
    self:unbindMethod(object,"getMovePosWayForRow")
    self:unbindMethod(object,"getAktDirObjsByDisAndCamp")
    self:unbindMethod(object,"getAktDirObjsByDis")
end
return AICharacterBehavior