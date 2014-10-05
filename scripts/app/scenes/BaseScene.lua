--
-- Author: wangshaopei
-- Date: 2014-09-23 11:00:21
--
local BaseScene = class("BaseScene", function()
    return display.newScene("BaseScene")
end)
function BaseScene:ctor()
    self.pos_=ccp(0, 0)
end
function BaseScene:setSceneSize(size)
    self:setContentSize(size)
end
function BaseScene:getSceneSize()
    return self:getContentSize()
end
function BaseScene:setPos(pos)
    self.pos_=pos
end
function BaseScene:getPos()
    return self.pos_.x,self.pos_.y
end
function BaseScene:viewPos2worldPos(viewPos)
    local  x,y = self:getPos()
    return ccp(math.abs(x) + viewPos.x,math.abs(y) + viewPos.y)
end
function BaseScene:worldPos2viewPos(worldPos)
    local  x,y = self:getPos()
    local viewPt = ccp(x+worldPos.x,y+worldPos.y)
    assert(viewPt.x>=0 and viewPt.y>=0,string.format("worldPos2viewPos() - faild!,x = %d,y=%d",viewPt.x,viewPt.y))
    return viewPt
end
return BaseScene