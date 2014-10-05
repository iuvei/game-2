--
-- Author: Anthony
-- Date: 2014-06-27 18:13:48
--
------------------------------------------------------------------------------
local math2d = require("common.math2d")
local MapConstants = require("app.controllers.MapConstants")
local CBattle = require("app.scenes.battle.Battle")
local HeroOperateCommand = require("app.controllers.commands.HeroOperateCommand")

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
local MapEventHandler = class("MapEventHandler")
------------------------------------------------------------------------------
function MapEventHandler:ctor(runtime,map)
    -- math.randomseed(os.time())

    self.runtime_   = runtime
    self.map_       = map
    self.battle_    = CBattle.new(self)
   -- self.moveQueue  = {}

end
------------------------------------------------------------------------------
function MapEventHandler:init()
    self.battle_:init_()
    --self:updataQueue()

    if DEBUG_BATTLE.showShortestPath then
        self.map_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            return self:onTouch(event.name, event.x, event.y)
        end)
        self.map_:setTouchEnabled(true)
    end

end
------------------------------------------------------------------------------
--
function MapEventHandler:onTouch(event, x, y)
     -- CCLuaLog("onTouch")
    if event=='began' then

    elseif event=='ended' then
       -- CCLuaLog("ended")
       local o = self.battle_.implementQueue[3]
        if o == nil then
            return false
        end
        self:showFindPathInfo(o.obj,ccp(x,y))
    end
    return true
end

-- 每秒执行一次 time() 方法
function MapEventHandler:time(time, dt)
    if self.battle_:isStart_() then
        self.battle_:run_()
    end
end
function MapEventHandler:getMap()
    return self.map_
end
function MapEventHandler:isCanMove(object)
    -- for k,v in ipairs(self.implementQueue) do
    --     print("4444444updataQueue:"..v.objId)
    -- end
    local b = true
    for k,v in ipairs(self.implementQueue) do
        local objtag=self.map_.ObjectManager:getObject(v.objId)
        if objtag and object:GetModel():getId() ~= v.objId then
            if object:getCollisionArea():intersectsRect(objtag:getCollisionArea()) then
                b=false
                --print("4444444updataQueue:"..v.objId)
                break
            end
        end

    end
    return b
end
------------------------------------------------------------------------------
--
function MapEventHandler:isSelfCampByCellPos(cellPos,selfCamp)
    local obj=self:getMap():getHeroByCellPos(cellPos)
    if obj and obj:GetModel():getCampId() == selfCamp then
        return true
    end
    return false
end
------------------------------------------------------------------------------
--显示寻经数据
function MapEventHandler:showFindPathInfo(selfobj,targetPos)
    local  pChildrenArray = self.map_:getChildren()
    local len = pChildrenArray:count()
    local  arrDel ={}
    for i = 0, len-1 do
        local n= tolua.cast(pChildrenArray:objectAtIndex(i), "CCNode")
        if n and n:getTag()==10 then
            table.insert(arrDel,n)
        end
    end
    for i,v in ipairs(arrDel) do
        v:removeFromParent()
    end

    local obj = selfobj
    local sx,sy = obj:getPosition()
    --local tx,ty = enemyQueue[1].obj:getPosition()
    local tx,ty =targetPos.x,targetPos.y
    -- local shortestPathSteps = self:findPath(self:getMap():getDMap():worldPosToCellPos(ccp(sx, sy)),
    --     self:getMap():getDMap():worldPosToCellPos(ccp(tx, ty)),obj)
    local shortestPathSteps = AStarUtil:findPath(self:getMap():getDMap():worldPosToCellPos(ccp(sx, sy))
        ,self:getMap():getDMap():worldPosToCellPos(ccp(tx, ty)),self,obj)
    if  shortestPathSteps then
        if DEBUG_BATTLE.showShortestPath then
            for i,v in ipairs(shortestPathSteps) do
        --for i,v in ipairs(self.closePathSteps_) do

            local cell = self:getMap():getDMap():getMapCell(v.pos.x,v.pos.y)
                local rect = display.newRect(self:getMap():getDMap():getCellSize().width,
                    self:getMap():getDMap():getCellSize().height)
                rect:setLineColor(ccc4f(1.0, 0.0, 0.0, 1.0))
                rect:setPosition(ccp(cell.rect:getMidX(),cell.rect:getMidY()))
                rect:addTo(self.map_,1000,10)

                self.idLabel_ = ui.newTTFLabel({
                        text = v.pos.x.." , "..v.pos.y,
                        size = 15,
                        color = display.COLOR_GREEN,
                    })
                    :pos(rect:getPosition())
                    :addTo(self.map_,1000,10)
                    -- 显示tilemap坐标的真实坐标
                    self.idLabel_ = ui.newTTFLabel({
                        text = v.gScore..","..v.hScore..","..v.gScore+v.hScore,
                        size = 15,
                        color = display.COLOR_GREEN,
                    })
                    :pos(rect:getPositionX(),rect:getPositionY()+20)
                    :addTo(self.map_,1000,10)
            end
        end
        if DEBUG_BATTLE.showOpenPath then
            for i,v in ipairs(self.openPathSteps_) do
        --for i,v in ipairs(self.closePathSteps_) do
            print("openPathSteps_:",v.pos.x,v.pos.y)
            local cell = self:getMap():getDMap():getMapCell(v.pos.x,v.pos.y)
                local rect = display.newRect(self:getMap():getDMap():getCellSize().width,
                    self:getMap():getDMap():getCellSize().height)
                rect:setLineColor(ccc4f(1.0, 1.0, 1.0, 1.0))
                rect:setPosition(ccp(cell.rect:getMidX(),cell.rect:getMidY()))
                rect:addTo(self.map_,1000,10)

                self.idLabel_ = ui.newTTFLabel({
                        text = v.pos.x.." , "..v.pos.y,
                        size = 15,
                        color = display.COLOR_GREEN,
                    })
                    :pos(rect:getPosition())
                    :addTo(self.map_,1000,10)
                    -- 显示tilemap坐标的真实坐标
                    self.idLabel_ = ui.newTTFLabel({
                        text = v.gScore..","..v.hScore..","..v.gScore+v.hScore,
                        size = 15,
                        color = display.COLOR_GREEN,
                    })
                    :pos(rect:getPositionX(),rect:getPositionY()+20)
                    :addTo(self.map_,1000,10)
            end
        end
    end
end
------------------------------------------------------------------------------
return MapEventHandler
------------------------------------------------------------------------------