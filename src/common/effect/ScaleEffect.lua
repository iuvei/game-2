--
-- Author: Anthony
-- Date: 2014-08-08 17:33:24
-- 放大缩小处理
--[[
    param.initSacle --设置初始缩放大小,没填默认为sprite_当前的缩放大小

    -- 第一次缩放
    param.from.time  -- 时间
    param.from.scale -- 缩放大小

    -- 第二次缩放
    param.to.time  -- 时间
    param.to.scale -- 缩放大小

    param.onInit    -- 初始时回调函数
    param.onComplete -- 结束时回调函数
]]
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
--[[执行特效]]
function M:run( sprite_ , param )
    if type(param) ~= "table" then param = {} end
    if type(param.from) ~= "table" then param.from = {} end
    if type(param.to) ~= "table" then param.to = {} end

    if param.initSacle == nil then  param.initSacle = sprite_:getScale(); end
    if param.from.time == nil then  param.from.time = 0.1  end
    if param.from.scale == nil then param.from.scale = 1.1 end
    if param.to.time == nil then  param.to.time = 0.1 end
    if param.to.scale == nil then param.to.scale = 1  end

    -- 开始处理
    if param.onInit then param.onInit(); end
    sprite_:setScale(param.initSacle)
    local sequence = transition.sequence({
        CCScaleTo:create(param.from.time, param.from.scale),
        CCScaleTo:create(param.to.time, param.to.scale),
    })
    transition.execute( sprite_,sequence,{
        onComplete = param.onComplete,
    })
    return true
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------