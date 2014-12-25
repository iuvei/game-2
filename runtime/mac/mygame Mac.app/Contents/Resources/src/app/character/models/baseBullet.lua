--
-- Author: wang shaopei
-- Date: 2014-07-09 18:31:15
--
local baseBullet = class("baseBullet",
	function()
    	return display.newNode()
	end
)
function baseBullet:ctor(rMe,startpos,endpos,fileName,scale)
    --print("11111:"..startpos.x)
	--self.sprite_ = display.newSprite("#gongbing-jianshi.png",startpos.x,startpos.y)
    self.sprite_ = display.newSprite(fileName,startpos.x,startpos.y)
    self.sprite_:addTo(rMe:getMap())
    self:Fire(startpos,endpos,scale)
end

function baseBullet:preFire()

end

function baseBullet:Fire(startpos,endpos,scale)
	--self.sprite_:setPosition(statrpos)
    --[[
    local bezier2 = ccBezierConfig()
    bezier2.controlPoint_1 = cc.p(100, size.height / 2)
    bezier2.controlPoint_2 = cc.p(200, - size.height / 2)
    bezier2.endPosition = cc.p(240, 160)
    ]]--

    -- local bezier0 ={
    --     startpos,
    --     cc.p(startpos.x+(endpos.x-startpos.x)*0.5, startpos.y+(endpos.y-startpos.y)*0.5+80),
    --     endpos
    -- }
    local bezier2 = {
        startpos,
        cc.p(startpos.x+(endpos.x-startpos.x)*0.5, startpos.y+(endpos.y-startpos.y)*0.5+80),
        endpos,
    }
    -- local bezier2 = ccBezierConfig()
    -- bezier2.controlPoint_1 = startpos
    -- bezier2.controlPoint_2 = cc.p(startpos.x+(endpos.x-startpos.x)*0.5, startpos.y+(endpos.y-startpos.y)*0.5+80)
    -- bezier2.endPosition = endpos
    --local b = cc.BezierTo:create(1, bezier0)
    self.sprite_:setScale(scale)
    transition.execute(self.sprite_, cc.BezierTo:create(1, bezier2), {
        onComplete = function()
        	self.sprite_:removeFromParent()
        	self:removeSelf()
        end,
    })
end

function baseBullet:endFire()
end
return baseBullet