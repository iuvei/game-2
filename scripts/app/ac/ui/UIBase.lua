--
-- Author: Anthony
-- Date: 2014-08-09 15:43:51
--
local scaleEf = require("common.effect.ScaleEffect")
------------------------------------------------------------------------------
local M  = class("UIBase", function()
    return display.newColorLayer(ccc4(0, 0, 0,200))
end)
------------------------------------------------------------------------------
function M:ctor(UIManager)
    self.UIManager_ = UIManager
    self:setNodeEventEnabled(true)
    self.touchGroup_ = nil

    self:CCSDefine()
end
------------------------------------------------------------------------------
--
function M:init( ccsFileName )
    if ccsFileName == nil or ccsFileName == "" then return false end

    -- 阵形界面
    self:setTouchGroup( TouchGroup:create():addTo(self) )
    widget = GUIReader:shareReader():widgetFromJsonFile(ccsFileName)
    self:GetTouchGroup():addWidget(widget)
end
------------------------------------------------------------------------------
-- 退出
function M:onExit()
end
function M:onEnter()
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- print(event.name)
        -- 触摸事件处理
        if event.name == "began" then     self.BeganPos = {x=event.x,y=event.y}
        elseif event.name == "ended" then
            self:close(ccp(self.BeganPos.x,self.BeganPos.y))
        end
        return true
    end)
end
------------------------------------------------------------------------------
function M:getUIManager()
    return self.UIManager_
end

function M:loadCCSJsonFile(parent, jsonFile)
    local node, width, height = cc.uiloader:load(jsonFile)
    if node then
        node:setPosition((display.width - width)/2, (display.height - height)/2)
        -- node:setPosition(ccp(0, 0))
        parent:addChild(node)

        -- dumpUITree(node)
        -- drawUIRegion(node, scene, 6)
    end
end
------------------------------------------------------------------------------
function M:close(pos)
    if pos then
        -- 判断是否点击到界面
        local Panelbg = self:getWidgetByName("Panel_bg")
        if Panelbg:hitTest(pos) then return true end
    end
    self:getUIManager():close(self)
end
------------------------------------------------------------------------------
function M:CCSDefine()
    self.ccs = ccs or {}
    -- 事件ID
    self.ccs.TouchEventType = {
        began = 0,
        moved = 1,
        ended = 2,
        canceled = 3,
    }

    self.ccs.LoadingBarType = {
        left = 0,
        right = 1,
    }

    self.ccs.CheckBoxEventType = {
        selected = 0,
        unselected = 1,
    }

    self.ccs.SliderEventType = {
        percent_changed = 0
    }

    self.ccs.TextFiledEventType = {
        attach_with_ime = 0,
        detach_with_ime = 1,
        insert_text = 2,
        delete_backward = 3,
    }

    self.ccs.LayoutBackGroundColorType = {
        none = 0,
        solid = 1,
        gradient = 2,
    }

    self.ccs.LayoutType = {
        absolute = 0,
        linearVertical = 1,
        linearHorizontal = 2,
        relative = 3,
    }

    self.ccs.UILinearGravity = {
        none = 0,
        left = 1,
        top = 2,
        right = 3,
        bottom = 4,
        centerVertical = 5,
        centerHorizontal = 6,
    }

    self.ccs.SCROLLVIEW_DIR = {
        none = 0,
        vertical = 1,
        horizontal = 2,
        both = 3,
    }

    self.ccs.PageViewEventType = {
       turning = 0,
    }

    self.ccs.ListViewEventType = {
        init_child = 0,
        update_child = 1,
    }

    self.ccs.ListViewDirection = {
        none = 0,
        vertical = 1,
        horizontal = 2,
    }
end
------------------------------------------------------------------------------
--
function M:GetTouchGroup()
    return self.touchGroup_
end
------------------------------------------------------------------------------
--
function M:setTouchGroup(touchGroup)
    self.touchGroup_ = touchGroup
end
------------------------------------------------------------------------------
function M:setTouchLayerEnabled(touchEnabled,touchSwallowEnabled)
    if touchSwallowEnabled == nil then touchSwallowEnabled = true end
    self:GetTouchGroup():setTouchEnabled(touchEnabled)
    self:GetTouchGroup():setTouchSwallowEnabled(touchSwallowEnabled)
end
------------------------------------------------------------------------------
function M:getWidgetByName(name, callback_)
    local widget = self:GetTouchGroup():getWidgetByName(name)
    if callback_ then callback_(widget) end
    return widget
end
------------------------------------------------------------------------------
function M:getWidgetByTag(tag, callback_ )
    local widget = self:GetTouchGroup():getWidgetByTag(tag)
    if callback_ then callback_(widget) end
    return widget
end
------------------------------------------------------------------------------
function M:createUINode(clsName, options)
    if not clsName then
        return
    end

    local node

    if clsName == "Node" then
        -- node = self:createNode(options)
    elseif clsName == "Sprite" or clsName == "Scale9Sprite" then
        -- node = self:createSprite(options)
    elseif clsName == "ImageView" then
        node = self:addImageWidget(options )
    elseif clsName == "Button" then
        node = self:addButtonWidget(options)
    elseif clsName == "LoadingBar" then
        -- node = self:createLoadingBar(options)
    elseif clsName == "Slider" then
        -- node = self:createSlider(options)
    elseif clsName == "CheckBox" then
        node = self:addCheckBoxWidget(options)
    elseif clsName == "LabelBMFont" then
        -- node = self:createBMFontLabel(options)
    elseif clsName == "Label" then
        node = self:addLabelWidget(options)
    elseif clsName == "LabelAtlas" then
        -- node = self:createLabelAtlas(options)
    elseif clsName == "TextField" then
        -- node = self:createEditBox(options)
    elseif clsName == "Panel" then
        node = self:addLayoutWidget(options)
    elseif clsName == "ScrollView" then
        -- node = self:createScrollView(options)
    elseif clsName == "ListView" then
        -- node = self:createListView(options)
    elseif clsName == "PageView" then
        -- node = self:createPageView(options)
    else
        -- printError("CCSUILoader not support node:" .. clsName)
        printInfo("createUINode not support node:" .. clsName)
    end

    return node
end
------------------------------------------------------------------------------
function M:setWidgetOptions( widget, options)
    if options.opactiy then
        widget:setOpacity(options.opactiy)
    end
    if options.name then
        widget:setName(options.name)
    end
    if options.tag then
        widget:setTag(options.tag)
    end
    if options.size then
        widget:setSize(options.size)
    end
    if options.achorpoint then
        widget:setAnchorPoint(options.achorpoint)
    end
    if options.pos then
       widget:setPosition(options.pos)
    end
    if options.scaleX then
        widget:setScaleX(options.scaleX)
    end
    if options.scaleY then
        widget:setScaleY(options.scaleY)
    end
    if options.scale then
        widget:setScale(options.scale)
    end
    if options.touchEnable then
        widget:setTouchEnabled(options.touchEnable)
    end
    if options.swallowEnabled then
        widget:setTouchSwallowEnabled(options.swallowEnabled)
    end
    if options.TouchEvent then
        widget:addTouchEventListener(options.TouchEvent)
    end
end
------------------------------------------------------------------------------
function M:addImageWidget(options)
    if options == nil then options={} end
    -----------------------------------------
    -- 添加widget
    local custom_widget = ImageView:create()
    if options.texture then
        custom_widget:loadTexture(options.texture)
    end
    self:setWidgetOptions( custom_widget, options)
    return custom_widget
end
------------------------------------------------------------------------------
function M:addButtonWidget(options)
    if options == nil then options={} end
    -----------------------------------------
    -- 添加widget
    local custom_widget = Button:create()
    custom_widget:loadTextures( options.textures[1],
                                options.textures[2],
                                options.textures[3])

    self:setWidgetOptions( custom_widget, options)
    return custom_widget
end
------------------------------------------------------------------------------
--Layout
function M:addLayoutWidget(options)
    if options == nil then options={} end
    -----------------------------------------
    local custom_widget = Layout:create()

    if options.texture then
        custom_widget:setBackGroundImage(options.texture)
    end
    custom_widget:setBackGroundColorType(self.ccs.LayoutBackGroundColorType.solid)
    custom_widget:setBackGroundColorOpacity(options.opactiy or 0)
    custom_widget:setBackGroundColor(options.color or display.COLOR_BLACK)

    self:setWidgetOptions( custom_widget, options)
    return custom_widget
end
------------------------------------------------------------------------------
function M:getFont()
    return FONT_GAME
end
------------------------------------------------------------------------------
--Label
function M:addLabelWidget(options)
    local custom_widget = Label:create()
    custom_widget:setText(options.text)
    custom_widget:setFontName(options.Font or self:getFont())
    custom_widget:setFontSize(options.FontSize or 30)
    custom_widget:setColor(options.color or display.COLOR_WHITE)
    self:setWidgetOptions( custom_widget, options)

    return custom_widget
end
------------------------------------------------------------------------------
function M:addCheckBoxWidget(options)
    if options == nil then options={} end
    -----------------------------------------
    -- 添加widget
    local custom_widget = CheckBox:create()
    custom_widget:loadTextures( options.textures[1],
                                options.textures[2],
                                options.textures[3],
                                options.textures[4],
                                options.textures[5])
    self:setWidgetOptions( custom_widget, options)
    return custom_widget
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------