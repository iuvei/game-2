--
-- Author: Anthony
-- Date: 2014-08-08 18:53:53
--
------------------------------------------------------------------------------
local scaleEf = require("common.effect.ScaleEffect")
------------------------------------------------------------------------------
local M  = class("UIManager", function()
    return display.newColorLayer(ccc4(0, 0, 0,0))
end)
------------------------------------------------------------------------------
function M:ctor(parent)
    self:setNodeEventEnabled(true)
    self:createTouchLayer(parent)
    parent:addChild(self)
    self.uiLayers_={}
end
------------------------------------------------------------------------------
-- 退出
function M:onExit()
    if self.touchLayer_ then
        self.touchLayer_:removeFromParent()
        self.touchLayer_ = nil
    end
end
------------------------------------------------------------------------------
function M:init()

end
----------------------------------------------------------------
function M:getTouchLayer()
    return self.touchLayer_
end
----------------------------------------------------------------
function M:setTouchLayerEnabled(layer,touchEnabled,touchSwallowEnabled)
    if touchSwallowEnabled == nil then touchSwallowEnabled = true end
    layer:setTouchEnabled(touchEnabled)
    layer:setTouchSwallowEnabled(touchSwallowEnabled)
end
----------------------------------------------------------------
-- 触摸层
function M:createTouchLayer(parent)

    self.touchLayer_ = display.newColorLayer(ccc4(0, 0, 0,0)):addTo(self,10000)
    -- parent:addChild(self,10000)
    -- 启用触摸
    self:setTouchLayerEnabled(self:getTouchLayer(),false,false)
    --触摸事件
    -- self:getTouchLayer():addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     -- print(event.name)
    --     -- 触摸事件处理
    --     if event.name == "began" then     self.BeganPos = {x=event.x,y=event.y}
    --     elseif event.name == "ended" then self:close(ccp(self.BeganPos.x,self.BeganPos.y))
    --     end
    --     return true
    -- end)
end
------------------------------------------------------------------------------
--[[
    打开 UI
    params.uiScript     require后的数据与scriptfile不共存，优先处理
    params.scriptFile   lua脚本文件
    params.ccsFileName  ccs文件
    params.params       附带的参数，会传到界面的init函数里

    例：
    1 .uiScript模式打开
    local UIServerlist  = import(".UIServerlist")
    self:openUI({uiScript = UIServerlist,
            ccsFileName = "UI/serverlist/serverlist.json"
            })
    2.scriptFile 模式打开
    self:openUI({scriptFile   = "app.scenes.login.UIServerlist",
            ccsFileName = "UI/serverlist/serverlist.json"
            })
]]
------------------------------------------------------------------------------
-- 关闭 UI
-- function M:closeUI()
--     self:close()
-- end
function M:openUI(params)
    self:create(params)
    self:open(params.ui)
end

------------------------------------------------------------------------------
function M:create(params)

    -- 如果有开过，则先关闭
    --self:closeUI()

    if self.closestate then return false end
    if self.openstate then return false end

    local ly = nil
    if params.uiScript then
        --self.CurUILayer = params.uiScript.new(self):addTo(self:getTouchLayer())
        ly = params.uiScript.new(self)
    else
        -- self.CurUILayer = INIT_FUNCTION.reloadModule(scriptFile).new(self):addTo(self:getTouchLayer())
        if params.scriptFile == nil then print("UIManager 必须填写scriptFile或uiScript") end
        --self.CurUILayer = require(params.scriptFile).new(self):addTo(self:getTouchLayer())
        ly = require(params.scriptFile).new(self)
    end
    assert(not self:isExist(ly.DialogID),string.format("DialogID = %d,is exist", ly.DialogID))
    self:getTouchLayer():addChild(ly)
    ly:init(params.ccsFileName,params.params or {})

    self:registerUI(ly)
    if DEBUG_BATTLE.showUILayerInfo then
        printf("open uiLayer dialogID = %d file = %s", ly.DialogID,params.ccsFileName)
    end
    params.ui=ly
    --self.CurUILayer:init(params.ccsFileName,params.params or {})
end
------------------------------------------------------------------------------
function M:open(uiLayer)

    if not self:canDo(uiLayer) then return false end

    -- 特效
    scaleEf:run( uiLayer,{
        initSacle = 0.3,
        from = { time = 0.1, scale = 1.1 },
        to   = { tiem = 0.1, scale = 1 },
        onInit = function()
            -- open state
            self.openstate = true
            -- 暂停触摸
            --self:setTouchLayerEnabled(self:getTouchLayer(),false)
            --self:getTouchLayer():setOpacity(200)
        end,
        onComplete = function()
            -- 恢复触摸
            --self:setTouchLayerEnabled(self:getTouchLayer(),true)
            uiLayer:setTouchLayerEnabled(true,false)
            self.openstate = false
        end,
    })
end
------------------------------------------------------------------------------
function M:close(uiLayer)

    if not self:canDo(uiLayer) then return false end

    -- if pos then
    --     -- 判断是否点击到界面
    --     local Panelbg = self.CurUILayer:getWidgetByName("Panel_bg")
    --     if Panelbg:hitTest(pos) then return true end
    -- end

    -- 特效
    scaleEf:run( uiLayer,{
        from = { time = 0.1, scale = 1.1 },
        to   = { tiem = 0.1, scale = 0.5 },
        onInit = function()
            -- 关闭标志，因为删除窗口是异步的
            self.closestate = true
            -- 暂停触摸
            --self:setTouchLayerEnabled(self:getTouchLayer(),false)
        end,
        onComplete = function()

            -- 关闭UI
            self:clearByID(uiLayer.DialogID)
            -- 恢复触摸
            --self:setTouchLayerEnabled(self:getTouchLayer(),true,false)

            --self:getTouchLayer():setOpacity(0)
            self.closestate = false
        end,
    })
end
------------------------------------------------------------------------------
--
function M:canDo(uiLayer)
    if self:isExist(uiLayer.DialogID) == nil then return false end
    if self.closestate then return false end
    if self.openstate then return false end
    return true
end
------------------------------------------------------------------------------
--
function M:isExist(dialogID)
    if self.uiLayers_[dialogID] then
        return true
    end
    return false
end
function M:registerUI(uiLayer)
    self.uiLayers_[uiLayer.DialogID]=uiLayer

end
function M:getUI(dialogID)
    return self.uiLayers_[dialogID]
end
function M:clearByID(dialogID)
    local ly=self.uiLayers_[dialogID]
    if ly then
        ly:removeFromParent()
        self.uiLayers_[dialogID]=nil
        if DEBUG_BATTLE.showUILayerInfo then
            printf("close uiLayer dialogID = %d ", ly.DialogID)
        end
    end
end
function M:clear()
    -- body
end
------------------------------------------------------------------------------
-- 设置是否触摸
function M:SetALLChildrenTouchState( wigt, TouchEnabled,SwallowEnabled )
    if SwallowEnabled == nil then SwallowEnabled = false end

    local children = wigt:getChildren()
    local cnt = children:count()
    for i=0,cnt-1 do
        local c = children:objectAtIndex(i)
        if c:getChildren():count() > 0 then
            self:SetALLChildrenTouchState( c,TouchEnabled,SwallowEnabled )
        end
        self:setTouchLayerEnabled(c,TouchEnabled,SwallowEnabled)
    end
    self:setTouchLayerEnabled(wigt,TouchEnabled,SwallowEnabled)
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------