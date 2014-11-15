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
    --AI移动逻辑
    local function AILogicMove(object,mapEvent)
        local object = object:getView()
        if object:GetModel():isMoving() then
            return false
        end
        if not object:GetModel():canMove() then
            return false
        end

        local tx, ty = object:getPosition()
        local cellPosSelf = mapEvent:getMap():getDMap():worldPosToCellPos(ccp(tx,ty))
        local cellPosEnemy=nil
        if object:GetModel():getType()=="gongbing" then
            cellPosEnemy=object:GetModel():getMovePosWayFindNearEnemy(mapEvent,false)
        else
            cellPosEnemy=object:GetModel():getMovePosWayForRow(mapEvent)
        end
        if not cellPosEnemy then return false end
        local shortestSteps= AStarUtil:findPath(cellPosSelf ,cellPosEnemy,mapEvent,object)
        if not shortestSteps then
            return false
        end
        for i=1,object:GetModel():getMoveDistance() do
            if table.nums(shortestSteps)>=i then
                local cellPosPre = cellPosSelf
                local preStep = shortestSteps[i-1]
                if preStep then
                    cellPosPre=preStep.pos
                end
                local cellPos= shortestSteps[i].pos
                local dir= object:GetModel():calcDir(cellPosPre,cellPos)

                local targetPosWorld = mapEvent:getMap():getDMap():cellPosToWorldPos(cellPos)
                HeroOperateManager:addCommand(HeroMoveCommand.new(object,mapEvent,targetPosWorld,dir))
             end
        end
        return true
    end
    self:bindMethod(object,"AILogicMove", AILogicMove)
    ----------------------------------------
    -- AI攻击逻辑
    local function AILogicAkt(object,mapEvent)
        local ov = object:getView()
        if object:isState("moving") then
            return false
        end
        if object:isState("attacking") then
            return false
        end
        if not object:canAttack() then
            return false
        end
        --判断人物当前是否可使用技能

        --取得人物要使用的技能
         --local ownSkill = object:getSkills()[1]
        local ownSkill = object:getSelectSkill()
        if ownSkill == nil then return false end

        if DEBUG_BATTLE.showSkillInfo then
            -- print("SelectSkill:")
            -- showTableInfo(ownSkill)
            -- print("----------------------")
        end

        --执行技能
        if not object:UseSkill(ownSkill.id) then
            return false
        end
        --local dis = math.floor(math2d.dist(selfPos.x, selfPos.y, targetPos.x, targetPos.y))

        return true
    end
    self:bindMethod(object,"AILogicAkt", AILogicAkt)
    ----------------------------------------
    --找最近的敌人
    local function findNearestEnemy(object,mapEvent,isPriSelectRow)
        local object = object:getView()
        local camp = object:GetModel():getCampId()
        if camp == MapConstants.PLAYER_CAMP then
            camp = MapConstants.ENEMY_CAMP
        elseif camp == MapConstants.ENEMY_CAMP then
            camp = MapConstants.PLAYER_CAMP
        end

        local mx,my = object:getPosition()
        local cellPosSelf = mapEvent:getMap():getDMap():worldPosToCellPos(ccp(mx,my))

        local disInfo={}
        for id, object in pairs(mapEvent.map_:getAllCampObjects(camp)) do
            if object and not object:GetModel():isDead() then
                local dis = math.floor(math2d.dist(mx, my, object:getPositionX(), object:getPositionY()))
                    table.insert(disInfo,{dis_=dis,enemyObj=object})
            end
        end

        if table.nums(disInfo)>0 then
            table.sort(disInfo,function(a, b) return a.dis_ < b.dis_ end)
            --是否优先选择同一行的敌人
            if isPriSelectRow then
                for i,target in ipairs(disInfo) do
                    local tx,ty = target.enemyObj:getPosition()
                    local cellPosEnemy = mapEvent:getMap():getDMap():worldPosToCellPos(ccp(tx,ty))
                    --TODO 找到同一线上的，需改成按规则查找
                    if cellPosEnemy.y == cellPosSelf.y then
                        return target.enemyObj
                    end
                end
            end
            return disInfo[1].enemyObj
        end
        return nil
    end
    self:bindMethod(object,"findNearestEnemy", findNearestEnemy)
    ----------------------------------------
    --
    local function getAktDirObjsByDisAndCamp(object,aktDirs,dis,isEnemy)
        local vobjs = object:getAktDirObjsByDis(aktDirs,dis)
        local vtargets={}
        for i=1, #vobjs do
            local t = vobjs[i]
            if isEnemy == true then
                if object:isEnemyByObj(t:GetModel()) then
                    table.insert(vtargets,t)
                end
            else
                if not object:isEnemyByObj(t:GetModel()) then
                    table.insert(vtargets,t)
                end
            end
        end
        return vtargets
    end
    self:bindMethod(object,"getAktDirObjsByDisAndCamp", getAktDirObjsByDisAndCamp)
    local function getAktDirObjsByDis(object,aktDirs,dis)
        local targets = {}
        local ov = object:getView()
        local sCellPos = ov:getPositionCell()
        for i=1, #aktDirs do
            local offset =aktDirs[i]
            for j=1,dis do
                local p=ccp(sCellPos.x+offset[1]*j, sCellPos.y+offset[2]*j)
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
        local startCellPos = mapEvent:getMap():getDMap():worldPosToCellPos(ccp(mx,my))
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
        return mapEvent:getMap():getDMap():worldPosToCellPos(ccp(mx,my))
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
    self:unbindMethod(object,"AILogicMove")
    self:unbindMethod(object,"AILogicAkt")
    self:unbindMethod(object,"findNearestEnemy")
    self:unbindMethod(object,"calcMoveDir")
    self:unbindMethod(object,"getMovePosWayFindNearEnemy")
    self:unbindMethod(object,"getMovePosWayForRow")
    self:unbindMethod(object,"getAktDirObjsByDisAndCamp")
    self:unbindMethod(object,"getAktDirObjsByDis")
end
return AICharacterBehavior