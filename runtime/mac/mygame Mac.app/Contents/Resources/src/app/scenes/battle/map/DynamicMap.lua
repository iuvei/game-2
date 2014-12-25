--
-- Author: Your Name
-- Date: 2014-07-14 11:21:48
--
local DynamicMap= class("DynamicMap")
function DynamicMap:ctor(map,lenX,lenY)
    self.dyMap_={}
    self.map_=map
    self.lenX_=lenX
    self.lenY_=lenY

    -- local obj = nil
    -- for id, object in pairs(self.map_:getAllObjects()) do
    --     obj=object
    --     break
    -- end
    -- self.cellWidth_=obj:getSize().width
    -- self.cellHeight_=obj:getSize().height

    self.cellWidth_=math.floor(map:getTileSize().width)
    self.cellHeight_=math.floor(map:getTileSize().height)
    self:createMap()
end
function DynamicMap:init(Map,x,y)

end
------------------------------------------------------------------------------
--
function DynamicMap:createMap()
    for y=1,self:getMapSize().height do
        self.dyMap_[y]={}
        for x=1,self:getMapSize().width do
            rc=cc.rect(math.round((x-1)*self.cellWidth_),
                math.round(self:getMapSize().height*self.cellHeight_-(y)*self.cellHeight_),
                self.cellWidth_,self.cellHeight_)
            self.dyMap_[y][x]={posX=x-1,posY=y-1,rect=rc,}
        end
    end
   -- print("DynamicMap:getSize(),",self:getMapSize().width,self:getMapSize().height)
end
------------------------------------------------------------------------------
--
function DynamicMap:getMapCell(x,y)
    return self.dyMap_[y+1][x+1]
end
------------------------------------------------------------------------------
--
function DynamicMap:getMapSize()
    --return cc.size(13,6)
     return cc.size(self.lenX_,self.lenY_)
end
------------------------------------------------------------------------------
--
function DynamicMap:getCellSize()
    return cc.size(self.cellWidth_, self.cellHeight_)
end
------------------------------------------------------------------------------
-- 通过指定的坐标转换为地图块坐标
function DynamicMap:worldPosToCellPos(worldPos)
    local x = math.floor( worldPos.x / self:getCellSize().width )
    local y = math.floor( worldPos.y / self:getCellSize().height )
    y = (self:getMapSize().height-1) - y
    return cc.p(x,y)
end
------------------------------------------------------------------------------
--
function DynamicMap:cellPosToWorldPos(cellPos)
    --local pos = cc.p(cellPos.x*self:getCellSize().width,cellPos.y*self:getCellSize().height)
    local rc = self:getMapCell(cellPos.x,cellPos.y).rect
    local pos = cc.p(cc.rectGetMidX(rc),cc.rectGetMidY(rc))
    --pos.x =  math.floor(pos.x + self:getCellSize().width /2)
    --pos.y = math.floor(pos.y + self:getCellSize().height /2)

    return pos
end
------------------------------------------------------------------------------
--
function DynamicMap:isObstacle(cellPos)
    local b = true
    if not self:isRangeOut(cellPos) then
        b=false
    end
    return b
end
------------------------------------------------------------------------------
--
function DynamicMap:isRangeOut(cellPos)
    if (cellPos.x >= 0 and cellPos.x < self:getMapSize().width )
    and (cellPos.y >= 0 and cellPos.y < self:getMapSize().height) then
        return false
    end
    return true
end
return DynamicMap