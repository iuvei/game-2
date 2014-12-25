--
-- Author: Your Name
-- Date: 2014-07-30 18:11:10
--
local AStar=import(".AStar")
local AStarUtil = {}

function AStarUtil:findPath(startCellPos, targetCellPos, map,object)
    local deleget = {}
     deleget.g = function(point1, point2)
         return math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
     end
     deleget.h = deleget.g
     deleget.map = map
     deleget.object=object
     deleget.width=map:getMap():getDMap():getMapSize().width
     deleget.height=map:getMap():getDMap():getMapSize().height
     deleget.getValue = function(x,y,map,object)
                            --特殊判断地图障碍
                            local h = map:getMap():getDMap():getMapSize().height
                            if y <= 2 then
                                return 1
                            end
                            if x==0 or x==map:getMap():getDMap():getMapSize().width-1 then
                                if y == 3 then
                                    return 1
                                end
                            end
                            --自己阵营设为障碍
                             if map:isSelfCampByCellPos(cc.p(x,y),object:GetModel():getCampId()) then
                                 return 1
                             end
                             return 0
                         end
     deleget.directions = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} -- 左，上，下，右

     return AStar.new():findPath(deleget, startCellPos, targetCellPos)
end
return AStarUtil