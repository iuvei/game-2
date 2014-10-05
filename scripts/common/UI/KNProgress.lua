local KNProgress = {}

----------------------------------------------------------------
-- 创建一个进度条
function KNProgress:newProgressTimer( bgBarImg,progressBarImg,scale )
    local bg = display.newSprite(bgBarImg)
    local bg1 = display.newSprite(progressBarImg)
    local progressTimer = CCProgressTimer:create(bg1)

    bg.progressTimer = progressTimer
    progressTimer:setType(kCCProgressTimerTypeBar)
    progressTimer:setPercentage(0)
    progressTimer:setMidpoint(ccp(0,0))
    progressTimer:setBarChangeRate(ccp(1, 0))
    progressTimer:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2))
    bg:addChild(progressTimer, 140)
    return bg
end

return  KNProgress