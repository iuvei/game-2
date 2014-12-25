--
-- Author: wangshaopei
-- Date: 2014-10-16 11:17:59
--
local StringData = require("config.zhString")
local CommonUtil = require("app.ac.CommonUtil")
local UIUtil = {}
function UIUtil:ShowTip(is_open,parent,contents)
    local root_tip=parent:getChildByName("Panel_Root_Tip")
    if not root_tip then
        if not is_open then
            return nil
        end
        root_tip=tolua.cast(GUIReader:shareReader():widgetFromJsonFile("UI/item_tip.json"),"Layout")
        parent:addChild(root_tip)
    end
    root_tip:getChildByName("Label"):setText(contents)
    root_tip:setEnabled(false)
    if is_open then
        root_tip:setEnabled(true)
        -- root_tip:setVisible(true)
    end
    return root_tip
end
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
function UIUtil:SetIconFrame(root,icon,quality)
    local img=UIHelper:seekWidgetByName(root,"Item")
    img:loadTexture(icon)
    local frame=UIHelper:seekWidgetByName(root,"ItemFrame")
    self:SetQuality(frame,quality)
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
--                 pos = cc.p(0,30*i)
--             }):addTo(parent)
--     end
-- end
----------------------------------------------------------------
return UIUtil
----------------------------------------------------------------