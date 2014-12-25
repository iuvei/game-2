--
-- Author: wangshaopei
-- Date: 2014-09-23 11:00:21
--
local base_scene = class("base_scene", function()
    return display.newScene("base_scene")
end)
function base_scene:ctor()
    self.name = self.__cname
    self.pos_=cc.p(0, 0)
end
function base_scene:setSceneSize(size)
    self:setContentSize(size)
end
function base_scene:getSceneSize()
    return self:getContentSize()
end
function base_scene:setPos(pos)
    self.pos_=pos
end
function base_scene:getPos()
    return self.pos_.x,self.pos_.y
end
function base_scene:viewPos2worldPos(viewPos)
    local  x,y = self:getPos()
    return cc.p(math.abs(x) + viewPos.x,math.abs(y) + viewPos.y)
end
function base_scene:worldPos2viewPos(worldPos)
    local  x,y = self:getPos()
    local viewPt = cc.p(x+worldPos.x,y+worldPos.y)
    assert(viewPt.x>=0 and viewPt.y>=0,string.format("worldPos2viewPos() - faild!,x = %d,y=%d",viewPt.x,viewPt.y))
    return viewPt
end
return base_scene