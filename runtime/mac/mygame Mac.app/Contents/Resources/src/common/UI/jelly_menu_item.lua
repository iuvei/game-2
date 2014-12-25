--
-- Author: Anthony
-- Date: 2014-11-12 21:10:44
-- Filename: jelly_menu_item.lua
-- 果冻效果的按钮
--[[
	local jelly_menu_item = require("common.UI.jelly_menu_item")
    local button = jelly_menu_item.new({
        image = "actor/Button01.png",
        -- imageSelected = "CloseSelected.png",
        listener = function ()
            print("click")
        end,
        x = display.cx,
        y = display.cy
    })
   local menu = ui.newMenu({button})
   self:addChild(menu)
]]
local jelly_menu_item = {}

function jelly_menu_item.new(params)
    local button = nil
    local listener = params.listener

    params.listener = function (tag)
        local function zoom1(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            local scaleX = button:getScaleX() * (size.width + offset) / size.width
            local scaleY = button:getScaleY() * (size.height - offset) / size.height

            transition.moveTo(button, {y = y - offset, time = time})
            transition.scaleTo(button, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end

        button:getParent():setEnabled(false)  --先关闭父类menu的功能

        zoom1(40, 0.08, function()
            zoom2(40, 0.09, function()
                zoom1(20, 0.10, function()
                    zoom2(20, 0.11, function()
                        button:getParent():setEnabled(true)
                        listener(tag)
                    end)
                end)
            end)
        end)
	end

    button = ui.newImageMenuItem(params)
    return button
end

return jelly_menu_item