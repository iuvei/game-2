--
-- Author: Anthony
-- Date: 2014-07-16 10:51:05
--
------------------------------------------------------------------------------
local configMgr = require("config.configMgr")
local Formation = require("app.character.views.Formation")
------------------------------------------------------------------------------
local M  = class("UIFormationLayer", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
M.DialogID=uiLayerDef.ID_Formation
------------------------------------------------------------------------------
function M:ctor(UIManager)
    M.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function M:onExit( )
    M.super.onExit(self)
    -- display.removeSpriteFramesWithFile("FormationUi0.plist", "FormationUi0.png")
end
------------------------------------------------------------------------------
-- 编辑阵形UI
function M:init( ccsFileName )
    M.super.init(self,ccsFileName)

    -----------------------------------------------------------
    -- 上阵方块
    self:ListenerFormationCell()
    -----------------------------------------------------------
    -- 阵形选择
    self:ListenerFormation()
    -----------------------------------------------------------
    -- hero list
    self:ListenerHeroList()
    -----------------------------------------------------------
    -- 设置默认按钮
    self:getWidgetByName("Button_defaut",function( ccsButton )
        ccsButton:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                -- print("设置默认阵型",self.LastSelectedFormation)
                G_DefaultSelectedFormation = self.LastSelectedFormation
            end
        end)
    end)

    -----------------------------------------------------------
    -- 上阵按钮
    self:getWidgetByName("Button_sz",function(BtnSZ)
        BtnSZ:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:getWidgetByName("ListView_33",function(lv)
                    local selectedItem = lv:getItem(self.LastSelectedHero-1)
                    if selectedItem then
                        local heroDt = selectedItem.heroDt
                        local confHeroData = configMgr:getConfig("heros"):GetHeroDataById(heroDt.dataId)

                        -- 判断是否已经上场
                        if not DATA_Formation:checkOnByGUID(heroDt.GUID) then
                            -- -- print("上阵",self.LastSelectedHero,"->",self.LastSelectedCell)
                            self:CreateFormationCell( heroDt, confHeroData, self.LastSelectedCell)
                        else
                            -- print("已经上阵",heroDt.GUID,confHeroData.nickname)
                            KNMsg:getInstance():flashShow(confHeroData.nickname.."已经上阵")
                        end
                    end
                end)
            end
        end)
    end)


    -----------------------------------------------------------
    -- 有上阵数据，直接显示
    local Fdata_ = DATA_Formation:get_data()
    for key , v in pairs(Fdata_) do
        -- print("···",v.index,v.GUID)
        self:CreateFormationCell( v )
    end

    -----------------------------------------------------------
    -- 重新刷新阵形块
    self:FlashFormationCell()

    -- -- 执行开启动画
    -- local action = ActionManager:shareManager():getActionByName("FormationUi_1.ExportJson","UI_Open");
    -- if action then
    --     action:play()
    -- end
end
------------------------------------------------------------------------------
-- 阵形选择模块
------------------------------------------------------------------------------
--
function M:ListenerFormation( )

    self.LastSelectedFormation = G_DefaultSelectedFormation
    for i=1,10 do
        self:getWidgetByName("CBFormation_"..i,function ( ccsCheckBox )
            local function selectedEvent( sender, eventType )
                self:SelectFormation( i )
                if eventType == 0 then -- 选择
                    -- 刷新阵形
                    self:FlashFormationCell()
                end
            end
            ccsCheckBox:addEventListenerCheckBox(selectedEvent)
        end)
    end

    -- print("···",self.LastSelectedFormation)
    self:SelectFormation( self.LastSelectedFormation )
end
------------------------------------------------------------------------------
function M:SelectFormation( index )

    self:getWidgetByName("CBFormation_"..self.LastSelectedFormation,function(wd)
        if wd then wd:setSelectedState(false) end
    end)

    self:getWidgetByName("CBFormation_"..index,function(wd)
        if wd then wd:setSelectedState(true) end
    end)

    self.LastSelectedFormation = index

    self:ShowFormationCell( self.LastSelectedFormation )
end
------------------------------------------------------------------------------
-- 阵形显示模块
------------------------------------------------------------------------------
-- 监听
function M:ListenerFormationCell( )

    self.LastSelectedCell = 0
    for i=1,9 do
        self:getWidgetByName("CheckBox_"..i,function( ccsCheckBox )
            --
            local function selectedEvent( sender, eventType )
                if ccsCheckBox:isBright() then
                    self:SelecFormationCell( i )
                end
            end
            ccsCheckBox:addEventListenerCheckBox(selectedEvent)
        end)
    end
end
------------------------------------------------------------------------------
function M:SelecFormationCell( index )
    -- print("SelecFormationCell",self.LastSelectedCell,index)

    self:getWidgetByName("CheckBox_"..self.LastSelectedCell,function( wd )
        if wd then wd:setSelectedState(false) end
    end)

    self:getWidgetByName("CheckBox_"..index,function( wd )
        if wd then wd:setSelectedState(true) end
    end)

    self.LastSelectedCell = index
end
------------------------------------------------------------------------------
-- 重新刷新阵形块
function M:FlashFormationCell( )
    -- print("FlashFormation")
    local count = 1
    local notBright = {}

    local shangzhenPanel = self:getWidgetByName("Panel_shangzhen")
    local cnt = #shangzhenPanel:getChildren()
    -- 先遍历出不可用位置
    for i=1,cnt do
        self:getWidgetByName("CheckBox_"..i,function( usedSlot_wigt )
            if not usedSlot_wigt:isBright()then

                local children = usedSlot_wigt:getChildren()
                if children:count() > 0 then
                    local c = children:objectAtIndex(0)
                    notBright[count] = c
                    count = count + 1
                end
            end
        end)
    end

    -- 把不可用位置的数据放到可用位置
    for i=1,cnt do
        self:getWidgetByName("CheckBox_"..i,function( usedSlot_wigt )
            if usedSlot_wigt:isBright() then
                local children = usedSlot_wigt:getChildren()
                if children:count() == 0 then
                    count = count - 1
                    local widget = notBright[count]
                    if widget == nil then return  end
                    -- 修改位置
                    widget:retain()
                    widget:removeFromParentAndCleanup(false)
                    widget:setPosition(cc.p(0,0))
                    usedSlot_wigt:addChild(widget)

                    self:ChangeHeroIndex(widget,i)
                end
            end
        end)
    end
end
------------------------------------------------------------------------------
-- 显示英雄阵形
function M:ShowFormationCell( fid )

    --
    Formation:build( fid, function ( param, index)
        self:getWidgetByName("CheckBox_"..index):setBright(param)
    end )

    -- 设置默认选中项
    if fid == 1 then --鱼鳞阵
        self:SelecFormationCell(5)
    elseif fid == 2 then
        self:SelecFormationCell(4)
    elseif fid == 3 then
        self:SelecFormationCell(3)
    elseif fid == 4 then
        self:SelecFormationCell(6)
    elseif fid == 5 then
        self:SelecFormationCell(5)
    elseif fid == 6 then
        self:SelecFormationCell(4)
    elseif fid == 7 then
        self:SelecFormationCell(5)
    elseif fid == 8 then
        self:SelecFormationCell(4)
    elseif fid == 9 then
        self:SelecFormationCell(6)
    elseif fid == 10 then
        self:SelecFormationCell(5)
    end
end
------------------------------------------------------------------------------
-- 改变hero上阵的位置
function M:ChangeHeroIndex( widget, index )
    widget.data.Index = index
    DATA_Formation:SetIndex(widget.data.GUID,index)
end
-- ------------------------------------------------------------------------------
-- -- 刷新数据，如果存在会先删除
-- function M:FormationData( index, heroDt )
--     if DATA_Formation:haveData(index) then
--         -- print("有数据删除",heroDt.index, index)
--         DATA_Formation:Remove(index)
--     end
--     -- 有数据则加入
--     if heroDt then
--         DATA_Formation:insertByIndex(index,heroDt)
--     end
-- end
------------------------------------------------------------------------------
-- 创建阵形头像
function M:CreateFormationCell( heroDt, confHeroData, index )
    -----------------------------------------
    if confHeroData == nil then
       confHeroData = configMgr:getConfig("heros"):GetHeroDataById(heroDt.dataId)
    end

    if index then
        -- 增加内部数据
        DATA_Formation:addData( index,heroDt )
    end

    local headImg = configMgr:getConfig("heros"):GetHerosArt(confHeroData.artId).headIcon

    -- print("上阵",heroDt.GUID,confHeroData.nickname)

    -----------------------------------------
    -- 位置上只要有一个就删除
    local ccsCell = self:getWidgetByName("CheckBox_"..heroDt.index)
    local ccsCellChildren = ccsCell:getChildren()
    local cnt = ccsCellChildren:count()
    for i=0,cnt-1 do
        local c = ccsCellChildren:objectAtIndex(i)
        c:removeFromParentAndCleanup(true)
        break
    end

    -----------------------------------------
    -- 添加widget
    local custom_widget = self:createUINode("ImageView",{
        name    = "heroImg"..heroDt.GUID,
        texture = headImg,
        -- achorpoint = cc.p(1,1),
        pos = cc.p(0,0),
    }):addTo(ccsCell)
    -- 存储的数据
    custom_widget.data = { GUID = heroDt.GUID, Index = heroDt.index }

    -- 开启触摸模式
    custom_widget:setTouchEnabled(true)
    local function touch( widget, eventType )
        local ccs = self.ccs
        -- local widgetParent = widget:getParent()

        -----------------------------------------
        if eventType == ccs.TouchEventType.began then

            self.widgetLastWorldSpace = widget:convertToWorldSpace(cc.p(0,0))
            self.widgetLastNodeSpace = cc.p(widget:getPosition())
            self.lastWidgetParent = widget:getParent()

            -- 需执行retain，再removeFromParentAndCleanup，不然会崩溃
            -- 因为parent为Layout，所以需用Parent处理，不然后面位置会有问题
            widget:retain()
            widget:removeFromParentAndCleanup(false)
            self:addChild(widget)

            widget:setPosition(widget:getTouchStartPos())

            -- 默认选中
            self:SelecFormationCell(widget.data.Index)
        -----------------------------------------
        elseif eventType == ccs.TouchEventType.moved then
            widget:setPosition(widget:getTouchMovePos())
        -----------------------------------------
        else

            local isInUsedSlot = false

            -----------------------------------------
            -- drop into used slot
            local shangzhenPanel = self:getWidgetByName("Panel_shangzhen")
            -- local Panelchildren = shangzhenPanel:getChildren()
            for i = 1,shangzhenPanel:getChildren():count() do

                local usedSlot_wigt = self:getWidgetByName("CheckBox_"..i)
                if usedSlot_wigt:isBright() and usedSlot_wigt:hitTest(cc.p(widget:getPosition())) then

                    local tempIndex = i
                    -----------------------------------------
                    -- 处理目标
                    local children = usedSlot_wigt:getChildren()
                    if children:count() > 0 then
                        -- 设置位置
                        local c = children:objectAtIndex(0)
                        c:retain()
                        c:removeFromParentAndCleanup(false)
                        c:setPosition(self.widgetLastNodeSpace)
                        self.lastWidgetParent:addChild(c)

                        -- 交换位置
                        tempIndex = c.data.Index
                        c.data.Index = widget.data.Index
                        widget.data.Index = tempIndex
                        self:ChangeHeroIndex(c, c.data.Index)
                    end
                    -----------------------------------------
                    -- 处理自己
                    widget:removeFromParentAndCleanup(false)
                    widget:setPosition(cc.p(0,0))
                    usedSlot_wigt:addChild(widget)
                    -- 设置位置
                    self:ChangeHeroIndex(widget, tempIndex)
                    -----------------------------------------
                    -- 默认选中
                    self:SelecFormationCell(widget.data.Index)
                    -----------------------------------------
                    isInUsedSlot = true
                    -----------------------------------------
                    break
                end
            end

            -----------------------------------------
            -- 脱出了界面外,删除
            if not isInUsedSlot then
                self:getWidgetByName("Panel_bg",function( PanelRoot )
                    if not PanelRoot:hitTest(cc.p(widget:getPosition())) then
                        DATA_Formation:addData( widget.data.Index )
                        widget:removeFromParentAndCleanup(true)
                        isInUsedSlot = true
                    end
                end)
            end
            -----------------------------------------
            -- back to last position if cannot drop other slot
            if isInUsedSlot == false then
                -- 执行动作
                local sequence = transition.sequence({
                    CCEaseExponentialOut:create(CCMoveTo:create(1.0, self.widgetLastWorldSpace)),
                })
                transition.execute( widget,sequence,{
                    onComplete = function ()
                        -- 回到原来位置
                        -- widget:retain()
                        widget:removeFromParentAndCleanup(false)
                        widget:setPosition(self.widgetLastNodeSpace)
                        self.lastWidgetParent:addChild(widget)

                        -- 可以触摸
                        self:SetALLChildrenTouchState(shangzhenPanel,true)
                    end,
                })

                -- 不可触摸,防止再拖动
                self:SetALLChildrenTouchState(shangzhenPanel,false)
            end
            -----------------------------------------
        end -- end if eventType
    end -- end function touch
    custom_widget:addTouchEventListener(touch)
end
------------------------------------------------------------------------------
-- 设置是否触摸
function M:SetALLChildrenTouchState( wigt, state )
    local children = wigt:getChildren()
    local cnt = children:count()
    for i=0,cnt-1 do
        local c = children:objectAtIndex(i)
        if c:getChildren():count() > 0 then
            self:SetALLChildrenTouchState( c,state )
        end
        c:setTouchEnabled(state)
        -- c:setTouchSwallowEnabled(true)
    end
    wigt:setTouchEnabled(state)
    -- wigt:setTouchSwallowEnabled(true)
end
------------------------------------------------------------------------------
-- 英雄列表模块
------------------------------------------------------------------------------
function M:ListenerHeroList( )
    self.LastSelectedHero = 1

    local lv = self:getWidgetByName("ListView_33")
    -----------------------------------------
    -- list 的监听函数
    local function listViewEvent( sender, eventType)
    -- print("···",eventType)
        if eventType == LISTVIEW_ONSELECTEDITEM_START then
            -- print("select child index = ",sender:getCurSelectedIndex())
            -- self:SetALLChildrenTouchState( sender,false )
            self:SelecHeroList(lv, sender:getCurSelectedIndex()+1)
        elseif eventType == LISTVIEW_ONSELECTEDITEM_END then

            self:SelecHeroList(lv, sender:getCurSelectedIndex()+1)
        end
    end
    lv:addEventListenerListView(listViewEvent)
    -----------------------------------------
    -- 添加items
    local count = DATA_Hero:get_lenght()
    local num_ = 0
    for i=1,count do
        -----------------------------------------
        -- 数据
        local heroDt = DATA_Hero:getTable(i)
        local confHeroData = configMgr:getConfig("heros"):GetHeroDataById(heroDt.dataId)

        -- local cell = self:GetTouchGroup():getWidgetByName("heroImg"..heroDt.GUID)
        -- if not DATA_Formation:haveDataByGUID(heroDt.GUID) then
            num_ = num_ + 1
            -----------------------------------------
            -- 文字框
            -- 创建
            local custom_widget = self:createUINode("CheckBox",{
                name    = "hero"..num_,
                textures = {"scene/home/name_bg.png",
                            "scene/home/name_bg.png",
                            "scene/home/selected03.png",
                            "",
                            ""},
                touchEnable = true,
            })
            custom_widget.index  = num_
            custom_widget.heroDt = heroDt -- 存储数据其他地方会用到

            -- 显示文字
            self:createUINode("Label",{
                name = "list_name",
                text = confHeroData.nickname,
                Font = font_UIScrollViewTest,
                FontSize  = 30,
                color = ccc3(255, 255, 255),
            }):addTo(custom_widget)

            -----------------------------------------
            -- 头像
            local headImg = configMgr:getConfig("heros"):GetHerosArt(confHeroData.artId).headIcon

            local function touch( widget, eventType )
                local ccs = self.ccs
                -----------------------------------------
                local heroDt = widget:getParent().heroDt
                -----------------------------------------
                if eventType == ccs.TouchEventType.began then
                    -----------------------------------------
                    -- 是否已经上阵
                    self.isSeleted = false -- 用来标识是否已经存在
                    local cell = self:getWidgetByName("heroImg"..heroDt.GUID)
                    if cell then
                        self.isSeleted = true
                        KNMsg:getInstance():flashShow(confHeroData.nickname.."已经上阵")
                        return true
                    end
                    -----------------------------------------
                    -- 添加widget到self用来拖动，当到达对应区域时删除
                    self.newCell = self:createUINode("ImageView",{
                        name    = "heroImg"..heroDt.GUID,
                        texture = headImg,
                        pos     = cc.p(0,0),
                    }):addTo(self)

                    self.newCell.data = { GUID = heroDt.GUID, Index = heroDt.index }

                    self.newCell:setPosition(widget:getTouchStartPos())
                -----------------------------------------
                elseif eventType == ccs.TouchEventType.moved then
                    -----------------------------------------
                    if self.isSeleted then
                        return true
                    end
                    -----------------------------------------
                    self.newCell:setPosition( widget:getTouchMovePos())
                -----------------------------------------
                else
                    -----------------------------------------
                    if self.isSeleted then
                        return true
                    end
                    -----------------------------------------
                    local isInUsedSlot = false
                    -----------------------------------------
                    -- drop into used slot
                    self:getWidgetByName("Panel_shangzhen",function ( shangzhenPanel )
                        for i = 1,shangzhenPanel:getChildren():count() do

                            if self.newCell then
                                local usedSlot_wigt = self:getWidgetByName("CheckBox_"..i)
                                if usedSlot_wigt:isBright() and usedSlot_wigt:hitTest(cc.p(self.newCell:getPosition())) then
                                    -- 删除
                                    self.newCell:removeFromParentAndCleanup(true)
                                    self.newCell = nil
                                    -- 创建新的
                                    self:CreateFormationCell( heroDt,nil,i )
                                    self:RemoveItem(lv,widget:getParent())
                                    isInUsedSlot = true
                                    break
                                end
                            end
                        end -- end for
                    end)
                    -----------------------------------------
                    if not isInUsedSlot then
                        -- 脱出了界面外,删除
                        self:getWidgetByName("Panel_bg",function ( PanelRoot )
                            if not PanelRoot:hitTest(cc.p(widget:getPosition())) then
                                self.newCell:removeFromParentAndCleanup(true)
                                self.newCell = nil
                                isInUsedSlot = true
                            end
                        end)
                    end
                    -----------------------------------------
                end
            end

            -- 创建
            self:createUINode("ImageView",{
                name    = "herolistImg"..heroDt.GUID,
                texture = headImg,
                pos     = cc.p(-60,0),
                scale   = 0.7,
                touchEnable = true,
                TouchEvent = touch,
            }):addTo(custom_widget)
            -----------------------------------------
            -- 放到list里面
            lv:pushBackCustomItem(custom_widget)
            -----------------------------------------
        -- end
    end
    -----------------------------------------
    --
    self:SelecHeroList(lv,self.LastSelectedHero)
end
------------------------------------------------------------------------------
function M:SelecHeroList( widget, index )

    local wd =nil
    local num_ = 1
    local items = widget:getItems()
    local cnt = items:count()

    -- 取消上次选中状态
    if self.LastSelectedHero ~= index then
        for i=0,cnt-1 do
            local c = items:objectAtIndex(i)
            if c then
                if num_== self.LastSelectedHero then
                    -- print("LastSelectedHero",self.LastSelectedHero)
                    self:getWidgetByName("hero"..c.index,function( wd )
                        if wd then wd:setSelectedState(false) end
                    end)
                    break
                end
                num_ = num_ + 1
            end
        end
    end

    -- 选择新的选中状态
    num_ = 1
    for i=0,cnt-1 do
        local c = items:objectAtIndex(i)
        if c then
            if index == nil or num_ == index then
                -- print("index",c.index)
                self:getWidgetByName("hero"..c.index,function(wd)
                    if wd then wd:setSelectedState(true) end
                end)
                break
            end
            num_ = num_ + 1
        end
    end

    -- 设置选中
    self.LastSelectedHero = num_
end
------------------------------------------------------------------------------
function M:RemoveItem( widget, childWidget )
    -- local items = widget:getItems()

    -- local num_ = 0
    -- local cnt = items:count()
    -- for i=0,cnt-1 do
    --     local c = items:objectAtIndex(i)
    --     -- print("···",c:getName(),childWidget:getName())
    --     if c and c:getName() ~= "default" and c:getName() == childWidget:getName() then
    --         -- print("···",c:getName(),childWidget:getName(),num_)
    --         widget:removeItem(num_)
    --         break
    --     end
    --     num_ = num_ + 1
    -- end

    -- self:SelecHeroList(widget)
end
----------------------------------------------------------------
return M
----------------------------------------------------------------