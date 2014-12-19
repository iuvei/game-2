--
-- Author: wangshaopei
-- Date: 2014-09-23 11:00:21
--
local base_cene = class("base_cene", function()
    return display.newScene("base_cene")
end)
function base_cene:ctor()
    self.name = self.__cname
    self.pos_=ccp(0, 0)
end
function base_cene:setSceneSize(size)
    self:setContentSize(size)
end
function base_cene:getSceneSize()
    return self:getContentSize()
end
function base_cene:setPos(pos)
    self.pos_=pos
end
function base_cene:getPos()
    return self.pos_.x,self.pos_.y
end
function base_cene:viewPos2worldPos(viewPos)
    local  x,y = self:getPos()
    return ccp(math.abs(x) + viewPos.x,math.abs(y) + viewPos.y)
end
function base_cene:worldPos2viewPos(worldPos)
    local  x,y = self:getPos()
    local viewPt = ccp(x+worldPos.x,y+worldPos.y)
    assert(viewPt.x>=0 and viewPt.y>=0,string.format("worldPos2viewPos() - faild!,x = %d,y=%d",viewPt.x,viewPt.y))
    return viewPt
end
return base_cene