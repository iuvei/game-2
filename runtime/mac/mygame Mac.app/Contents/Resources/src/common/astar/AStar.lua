--
-- Author: Your Name
-- Date: 2014-07-30 12:09:38
--
local AStar= class("AStar")
-- 寻找路径
--[[
deleget = {
    g = function(point1, point2)
        -- add your code
        -- 返回点point1到点point2的实际代价
    end
    h = function(point1, point2)
        -- add your code
        -- 返回点point1到点point2的估算代价
    end
    getValue = function(x,y,map,object)
        -- 返回地图中第x行，第y列的数据 1为障碍物，0为非障碍物,map所在地图,object操作对象
    end
    width -- 地图宽度
    height -- 地图高度
}
--]]
function AStar:ctor()
    self.openPathSteps_={}      -- 开放节点
    self.closePathSteps_={}     -- 关闭节点
    self.mapData_={}             -- 地图数据
    self.deleget_=nil           -- 代理
    self.startPoint_=nil        -- 起点
    self.destPoint_=nil         -- 目标点
end
function AStar:init()

end
function AStar:reset()
    self.openPathSteps_={}
    self.closePathSteps_={}
    self.mapData_={}
    for x = 1,self.deleget_.width do
        self.mapData_[x] = {}
        for y = 1, self.deleget_.height do
            local value = self.deleget_.getValue(x-1,y-1,self.deleget_.map,self.deleget_.object)
            self.mapData_[x][y] = value

        end

    end

    if DEBUG_BATTLE.showDMapInfo then
        print("-----------------------------------")
        for y = 1,self.deleget_.height do
            local str = ""
            for x = 1, self.deleget_.width do
                str = str.." "..self.mapData_[x][y]
            end
            print(str)
        end
        print("-----------------------------------")
    end

    local step =self:createStep(self.startPoint_)
     self:insertInOpenSteps(step)
end
function AStar:createStep(cellPos)
    local step ={
        pos=cellPos,
        gScore=0,
        hScore=0,
        parent={}
    }
   -- step["key"] = getKey(step)
    return step
end
function AStar:findPath(deleget,startCellPos,destCellPos)
    if DEBUG_BATTLE.showShortestPath then
        print("From:",startCellPos.x,startCellPos.y)
        print("To:",destCellPos.x,destCellPos.y)
    end
    self.deleget_=deleget
    self.startPoint_=startCellPos
    self.destPoint_=destCellPos
    self:reset()

     while table.nums(self.openPathSteps_) > 0 do
        --得到最小的F值步骤
        --因为是有序列表，第一个步骤总是最小的F值
         local curStep=self.openPathSteps_[1]

        table.insert(self.closePathSteps_,curStep)
        table.remove(self.openPathSteps_,1)
         --找到目标
        if self:isEqual(curStep,destCellPos) then
            --self.openPathSteps_={}
            self.closePathSteps_={}
            return self:constructSteps(curStep)
        else
            --得到当前步骤的相邻方块坐标
            local nextPositions=self:getAroundCell(curStep.pos)
            for k,v in pairs(nextPositions) do
                local nextStep =self:createStep(v)
                --检查步骤是不是已经在closed列表
                if self:getStepIndex(self.closePathSteps_,nextStep) ==false then
                    -- 计算从当前步骤到此步骤的成本
                     local moveCost = self:calcCostOffsetScore(curStep, nextStep)
                     -- 检查此步骤是否已经在open列表
                     local index= self:getStepIndex(self.openPathSteps_, nextStep)
                     -- 不在open列表，添加它
                     if index == false then
                        nextStep.parent = curStep
                        nextStep.gScore=curStep.gScore+moveCost
                        nextStep.hScore= self.deleget_.h(nextStep.pos,destCellPos)
                        if self:isObstacle(nextStep.pos) == false then
                            self:insertInOpenSteps(nextStep)
                        end
                     else
                        local step = self.openPathSteps_[index]
                        --检查G值是否低于当前步骤到此步骤的值
                        if curStep.gScore + moveCost < step.gScore then
                            step.gScore=curStep.gScore + moveCost
                            table.remove(self.openPathSteps_,index)
                            self:insertInOpenSteps(step)
                        end
                     end
                end
            end
        end
     end
    return nil
end
-- 两个点是否是同一个点
function AStar:isEqual(point1, point2)
    return point1.pos.x==point2.x and point1.pos.y==point2.y
end
-- 是否是障碍物
function AStar:isObstacle(point)
    local value = self.mapData_[point.x+1][point.y+1]
    if value == 1 then
        return true
    end
    return false
end
function AStar:calcCostOffsetScore(curStep,targetStep)
    return -1
end
function AStar:getStepIndex(pathSteps,step)
    for i,v in ipairs(pathSteps) do
        if v.pos.x == step.pos.x and v.pos.y == step.pos.y then
            --print("index:",i)
            return i
        end
    end
    return false
end
function AStar:getAroundCell(curCellPos)
    local tmp={}
    for i = 1, #self.deleget_.directions do
        local offset = self.deleget_.directions[i]
        local  p=cc.p(curCellPos.x+offset[1], curCellPos.y+offset[2])
        if not self:isRangeOut(p) then
            table.insert(tmp,p)
        end
    end
    return tmp
end
function AStar:insertInOpenSteps(pathStep)
   --  local stepFScore=pathStep.gScore+pathStep.hScore
   --  local num=table.nums(self.openPathSteps_)
   -- local counter = 1
   --  for i,v in ipairs(self.openPathSteps_) do

   --      if stepFScore <= v.gScore+v.hScore then
   --         break
   --      end
   --      counter = counter+1
   --  end
   --  table.insert(self.openPathSteps_,counter,pathStep)
   table.insert(self.openPathSteps_,pathStep)
   table.sort( self.openPathSteps_, function (a,b)
       return a.gScore+a.hScore < b.gScore+b.hScore
   end )
end
function AStar:constructSteps(targetStep)
    local shortestPathSteps={}
    while table.nums(targetStep)>0 do
        if table.nums(targetStep.parent)>0 then
            table.insert(shortestPathSteps,1,targetStep)
        end
        targetStep=targetStep.parent
    end
    --显示最短路径信息
    if DEBUG_BATTLE.showShortestPath then
        print("----------------------------------------------------")
        for i,v in ipairs(shortestPathSteps) do
            print("shortestPathSteps_:","x=",v.pos.x,"y=",v.pos.y,""," g=",v.gScore," h=",v.hScore," f=",v.gScore+v.hScore)
        end
        print("----------------------------------------------------")
    end

    return shortestPathSteps
end
function AStar:isRangeOut(cellPos)
    if (cellPos.x >= 0 and cellPos.x < self.deleget_.width ) and (cellPos.y >= 0 and cellPos.y < self.deleget_.height) then
        return false
    end
    return true
end

return AStar