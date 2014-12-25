--
-- Author: Anthony
-- Date: 2014-07-10 16:47:23
--
--[[
    淡隐淡出
]]
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
--[[执行特效]]
function M:run( sprite_ , param )
    if type(param) ~= "table" then param = {} end

    if param.time1 == nil then
        param.time1 = 0.4
    end
    if param.time2 == nil then
        param.time2 = 0.5
    end
    if param.time3 == nil then
        param.time3 = 0.3
    end

    -- 闪两下，然后消失
    local sequence = transition.sequence({
        -- CCDelayTime:create(0.5),
        CCFadeOut:create(param.time1),
        CCFadeIn:create(param.time2),
        CCFadeOut:create(param.time3),
    })
    transition.execute( sprite_,sequence,{
        onComplete = param.onComplete,
    })
    return true
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------