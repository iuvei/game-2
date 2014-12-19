--[[

初始化场景

]]
------------------------------------------------------------------------------
-- 图片资源
------------------------------------------------------------------------------
local IMG_LOG = "logo/"..CHANNEL_ID .. "_bg.png"
------------------------------------------------------------------------------
-- define logoScene
------------------------------------------------------------------------------
local logoScene = class("logoScene", function()
    return display.newScene("logoScene")
end)
------------------------------------------------------------------------------
function logoScene:ctor()

	require("launcher.init_functions")
	INIT_FUNCTION.reloadModule("version")

	-- if CHANNEL_ID == "test" then
		local layer = display.newLayer()
		local bg = display.newSprite(IMG_LOG,display.cx,display.cy)
		-- INIT_FUNCTION.setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		self:addChild(layer)

		bg:setOpacity( 0 );
		-- 执行一系列动作 边缩放边上下移
		local sequence = transition.sequence({
		    -- CCScaleTo:create(0.2, 1.2),
		    -- CCScaleTo:create(0.2, 1),
		    CCDelayTime:create(0.2),
		    CCFadeIn:create(0.5),
		    CCDelayTime:create(0.3),
		    CCFadeOut:create(0.5),
		})
		transition.execute( bg,sequence,{
		    onComplete = function()
		    end,
		})

	-- end
end
------------------------------------------------------------------------------
function logoScene:onExit()
	display.removeSpriteFrameByImageName(IMG_LOG)
end
------------------------------------------------------------------------------
function logoScene:onEnter()

	--延迟1.5秒
	self:performWithDelay(function (  )
            -- display.replaceScene(INIT_FUNCTION.reloadModule("init.updatenew").new())
            display.replaceScene(INIT_FUNCTION.reloadModule("launcher.update").new())
        end,1.5)
end
------------------------------------------------------------------------------
return logoScene
------------------------------------------------------------------------------
