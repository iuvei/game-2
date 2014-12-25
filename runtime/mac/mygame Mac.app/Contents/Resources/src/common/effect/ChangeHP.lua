--
-- Author: Anthony
-- Date: 2014-07-10 18:28:57
--
--[[

    血量改变  数字变化  (向上漂的数字)

]]


local M = {}

--[[执行特效]]
function M:run( sprite_ , num , param )
    if type(param) ~= "table" then param = {} end

    if tonumber( num ) == 0 then
        if param.onComplete then param.onComplete() end
        return
    end

    local group , group_width
    if param.is_crt then
        audio.playSound("sound/crit.mp3")
        --暴击掉血
        -- group , group_width = getImageNum( math.abs( num ) , "common/cirt.png" , { offset = -10 } )
        group , group_width = getImageNum_( num , num>0 and "num_green_" or "num_orange_" )
    else
        --掉血或者加血
        -- group , group_width = getImageNum( math.abs( num ) , num>0 and "common/hp_green.png" or "common/hp.png" )
        group , group_width = getImageNum_( num , num>0 and "num_green_" or "num_red_" )
    end

    setAnchPos( group , 0 , 0 , 0.5 )
    sprite_:getParent():addChild(group,param.zorder)
    local x_,y_=sprite_:getPosition()
    group:setPosition(cc.p(x_,y_))

    --[[特效开始]]
    group:setScale(0.3)
    if param.is_crt then
        transition.scaleTo(group, {
            time = 0.1,
            -- scale = 2.5,

            scale = 2,
        })
        --
        local ps_crt=display.newSprite("scene/battle/midas_crip2.png")
        setAnchPos( ps_crt , x_,y_+50, 0.5 )
        transition.moveTo(ps_crt, { time = 0.4, x = x_ , y = y_+150  })

        transition.fadeOut(ps_crt, {
            delay = 0.7,
            time = 0.3,
            onComplete = function()
                ps_crt:removeFromParentAndCleanup(true)  -- 清除自己
            end
        })
        sprite_:getParent():addChild(ps_crt,param.zorder)
    else
        transition.scaleTo(group, {
            time = 0.1,
            -- scale = 2.5,

            scale = 1,
        })
    end

    transition.scaleTo(group, {
        delay = 0.2,
        time = 0.2,
        -- scale = 1,
        scale = 0.5,
    })

    transition.moveTo(group, { delay = 0.6 , time = 0.4, x = x_ , y = y_+100  })

    transition.fadeOut(group, {
        delay = 0.7,
        time = 0.3,
        onComplete = function()
            group:removeFromParentAndCleanup(true)  -- 清除自己
            if param.onComplete then param.onComplete() end
        end
    })

    -- -- 添加到 特效层
    -- logic:getLayer("effect"):addChild( group )

end
return M