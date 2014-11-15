--
-- Author: wangshaopei
-- Date: 2014-10-16 11:17:59
--
local StringData = require("config.zhString")
local CommonUtil = require("app.ac.CommonUtil")
local UIUtil = {}
function UIUtil:SetStars(wgStars,num)
    for i=1,5 do
        local star=wgStars:getChildByName("star_"..i)
        if num>=i then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end
end
function UIUtil:SetQuality(frame,quality)
    local color = "white"
    if quality == 2 then
        color = "green"
    elseif quality == 3 then
        color = "blue"
    elseif quality == 4 then
        color = "purple"
    elseif quality == 5 then
        color = "orange"
    end
    frame:loadTexture(string.format("UI/package/equip_frame_%s.png",color))
    --frame:loadTexture(string.format("UI/package/equip_frame_green.png"))
end
function UIUtil:SetHeroAttLabes(lab,equip_info)
    local t = CommonUtil:GetItemAttrIndexMap()
    local t_ = {}
    for i,attr_name in ipairs(t) do
        t_[attr_name]=StringData[800000100+i]
    end
    local str = ""
    for k,v in pairs(equip_info.attr) do
        if v ~= -1 and v ~= 0 then
            str = str..t_[k].."+"..v.." \n"
        end
    end
    lab:setText(str)
end
-- function UIUtil:CreateHeroAttLables(layout,parent,params)
--     for i=1,#params.arr do
--         local options = params.arr[i]
--         layout:createUINode("Label",{
--                 name = "lab_name",
--                 text = options.text,
--                 Font = layout:getFont(),
--                 FontSize  = options.FontSize or 30,
--                 color = options.color or ccc3(255, 255, 255),
--                 pos = ccp(0,30*i)
--             }):addTo(parent)
--     end
-- end
----------------------------------------------------------------
return UIUtil
----------------------------------------------------------------