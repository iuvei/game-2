--
-- Author: Anthony
-- Date: 2014-08-08 18:53:53
--
--[[
UI层结构
    scene
      | - uimanager(layer)
              | - touchlayer(layer)
]]

------------------------------------------------------------------------------
local scaleEf = require("common.effect.ScaleEffect")
------------------------------------------------------------------------------
local M  = class("UIManager", function()
    return display.newColorLayer(ccc4(0, 0, 0,0))
end)
------------------------------------------------------------------------------
function M:ctor(parent)
    self:setNodeEventEnabled(true)
    -- 默认关闭根结点触摸
    self:setTouchEnabled(false)
    --
    self:createTouchLayer(parent)
    parent:addChild(self)
    --
    self.uiLayers_={}          -- 当前场景所有窗口
    self.uiLayersByClass_={} -- 存放模态类型窗口
    self.uiLayersByClass_["mode"]={}
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
function M:getUiLayers()
    return self.uiLayers_
end
----------------------------------------------------------------
-- 触摸层
function M:createTouchLayer(parent)

    self.touchLayer_ = display.newColorLayer(cc.c4b(0, 0, 0,0)):addTo(self,10000)
    self.touchLayer_:setTouchEnabled(false)
    -- parent:addChild(self,10000)
    -- 启用触摸
    -- self:setTouchLayerEnabled(self:getTouchLayer(),true,false)
    --触摸事件
    -- self:getTouchLayer():addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     -- print(event.name)
    --     -- 触摸事件处理
    --     if event.name == "began" then     self.BeganPos = {x=event.x,y=event.y}
    --     elseif event.name == "ended" then self:closeTopUI(cc.p(self.BeganPos.x,self.BeganPos.y))
    --     end
    --     return true
    -- end)
end
----------------------------------------------------------------
function M:setTouchLayerEnabled(layer,touchEnabled,touchSwallowEnabled)

    if touchSwallowEnabled == nil then touchSwallowEnabled = true end
    layer:setTouchEnabled(touchEnabled)
    layer:setTouchSwallowEnabled(touchSwallowEnabled)
end
------------------------------------------------------------------------------
--[[
    打开 UI
    params.uiScript     require后的数据与scriptfile不共存，优先处理
    params.scriptFile   lua脚本文件
    params.ccsFileName  ccs文件
    params.open_close_effect 是否有开启关闭动画
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
    return self:open(self:create(params))
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
    if params.is_no_modle then
        self:addChild(ly,params.zorder or 0)
    else
        self:getTouchLayer():addChild(ly)
    end

    ly:init(params or {})

    self:registerUI(ly)
    if DEBUG_BATTLE.showUILayerInfo then
        printf("open uiLayer dialogID = %d file = %s", ly.DialogID,params.ccsFileName)
    end
    -- params.ui=ly
    return ly
    --self.CurUILayer:init(params.ccsFileName,params.params or {})
end
------------------------------------------------------------------------------
function M:open(uiLayer)

    if not self:canDo(uiLayer) then return nil end
    if uiLayer.open_close_effect == true then
        -- 特效
        scaleEf:run( uiLayer,{
            initSacle = 0.3,
            from = { time = 0.1, scale = 1.1 },
            to   = { tiem = 0.1, scale = 1 },
            onInit = function()
                -- open state
                self.openstate = true
                -- 暂停触摸
                self:setTouchLayerEnabled(self:getTouchLayer(),false)
                self:getTouchLayer():setOpacity(200)
            end,
            onComplete = function()
                -- 恢复触摸
                self:setTouchLayerEnabled(self:getTouchLayer(),true)
                -- uiLayer:setTouchLayerEnabled(true,false)
                self.openstate = false
            end,
        })
    else
        -- 模态
        if not uiLayer.is_no_modle then
            self:getTouchLayer():setOpacity(200)

            -- uiLayer:GetTouchGroup():setTouchEnabled(false)
            -- 设置uimanager层
            -- self:setTouchLayerEnabled(self:getTouchLayer(),true) -- 触碰吞噬
            --  self:setTouchEnabled(true)
            -- self:setTouchSwallowEnabled(true)
            -- 设置ui层
            -- uiLayer:setTouchEnabled(true)
            -- uiLayer:setTouchSwallowEnabled(false)
            -- uiLayer:setTouchLayerEnabled(true,false)

            -- self:setTouchLayerEnabled(self:getTouchLayer(),true,false)
            -- self:setTouchLayerEnabled(self,true,false)
        -- 非模态
        else
            -- uiLayer:setTouchEnabled(true)
            -- self:setTouchLayerEnabled(self:getTouchLayer(),true,false)
            --  uiLayer:setTouchLayerEnabled(true,false)

        end

        self.openstate = false
    end
    return uiLayer
end
------------------------------------------------------------------------------
--关闭相关
function M:closeTopUI(pos)
    local uiLayer = self:getTopModeUI()
    if not uiLayer then return false end
    if pos then
        -- 判断是否点击到界面
        local Panelbg = uiLayer:getWidgetByName("Panel_bg")
        if not Panelbg then return false end
        if Panelbg:hitTest(pos) then return true end
    end
    self:close(uiLayer)
end
--
function M:close(uiLayer)

    if not self:canDo(uiLayer) then return false end

    if uiLayer.open_close_effect == true then
        -- 特效
        scaleEf:run( uiLayer,{
            from = { time = 0.1, scale = 1.1 },
            to   = { tiem = 0.1, scale = 0.5 },
            onInit = function()
                -- 关闭标志，因为删除窗口是异步的
                self.closestate = true
                -- 暂停触摸
                self:setTouchLayerEnabled(self:getTouchLayer(),false)
            end,
            onComplete = function()
                -- 关闭UI
                self:clearByID(uiLayer.DialogID)
                self:setTouchLayerEnabled(self:getTouchLayer(),true)
                if self:getUIAmount("mode")==0 then
                    -- 恢复触摸
                    self:setTouchLayerEnabled(self:getTouchLayer(),true,false)
                    self:getTouchLayer():setOpacity(0)
                end
                self.closestate = false
            end,
        })
    else
      -- 关闭UI
        self:clearByID(uiLayer.DialogID)
        -- self:setTouchLayerEnabled(self:getTouchLayer(),true)
        if self:getUIAmount("mode")==0 then
            -- 恢复触摸
            self:setTouchLayerEnabled(self:getTouchLayer(),true,false)
            self:getTouchLayer():setOpacity(0)
        end
        self.closestate = false
    end
end
------------------------------------------------------------------------------
--
function M:getTopModeUI()
    local amount=#self.uiLayersByClass_["mode"]
    if amount == 0 then
        return nil
    end
    return self.uiLayersByClass_["mode"][amount]
end
------------------------------------------------------------------------------
--
function M:getUI(dialogID)
    return self.uiLayers_[dialogID]
end
------------------------------------------------------------------------------
--
function M:getUIAmount(typename)
    if typename == "mode" then
        return #self.uiLayersByClass_[typename]
    else
        return #self.uiLayers_
    end
end
------------------------------------------------------------------------------
--
function M:canDo(uiLayer)
    if uiLayer == nil then return false end
    if self:isExist(uiLayer.DialogID) == nil then return false end
    if self.closestate then return false end
    if self.openstate then return false end
    return true
end
------------------------------------------------------------------------------
--
function M:isExist(dialogID)
    if self:getUI(dialogID) then
        return true
    end
    return false
end
------------------------------------------------------------------------------
--
function M:registerUI(uiLayer)
    if not uiLayer.is_no_modle then
        table.insert(self.uiLayersByClass_["mode"],uiLayer)
    end
    assert(self.uiLayers_[uiLayer.DialogID]==nil,"registerUI() - failed : ui is exist! id = "..uiLayer.DialogID)
    self.uiLayers_[uiLayer.DialogID]=uiLayer
end

------------------------------------------------------------------------------
--清理相关
function M:clearTopUI()
    local  ly = self:getTopModeUI()
    if ly then
        self:clearByID(ly.DialogID)
    end
end
--
function M:clearByID(dialogID)
    -- self.uiLayersByClass["mode"]
    for i=1,#self.uiLayersByClass_["mode"] do
        local dlg = self.uiLayersByClass_["mode"][i]
        if dlg and dlg.DialogID == dialogID then
            if DEBUG_BATTLE.showUILayerInfo then
                printf("close uiLayer dialogID = %d ", dlg.DialogID)
            end
            dlg:removeFromParent()
            self.uiLayersByClass_["mode"][i]=nil
            break
        end
    end
    self.uiLayers_[dialogID]=nil
end
--
function M:clear()
    -- body
end
------------------------------------------------------------------------------
-- 设置是否触摸
function M:SetALLChildrenTouchState( wigt, TouchEnabled,SwallowEnabled )
    if SwallowEnabled == nil then SwallowEnabled = false end

    local children = wigt:getChildren()
    local cnt = children:count()
    for i=1,cnt do
        local c = children[i]
        if #children > 0 then
            self:SetALLChildrenTouchState( c,TouchEnabled,SwallowEnabled )
        end
        self:setTouchLayerEnabled(c,TouchEnabled,SwallowEnabled)
    end
    self:setTouchLayerEnabled(wigt,TouchEnabled,SwallowEnabled)
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------