--
-- Author: wangshaopei
-- Date: 2014-09-26 17:13:33
--
local UIListView = require("app.ac.ui.UIListView")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local M  = class("UIHero", require("app.ac.UI.UIBase"))
local uiLayerDef =require("app.ac.uiLayerDefine")
M.DialogID=uiLayerDef.ID_Hero
------------------------------------------------------------------------------
function M:ctor(UIManager)
    M.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function M:onExit( )
    M.super.onExit(self)
end
------------------------------------------------------------------------------
function M:init( ccsFileName, params )
    M.super.init(self,ccsFileName)
    --初始化选择阵型界面
    --self:showFormation(wgFormationMain,false)
    self:initTouchSelFormation()
     local lstItem = tolua.cast(self:getWidgetByName("ScrollView"),"ScrollView")

     self._lstItem =UIListView.new(lstItem)

     self._tplItem = tolua.cast(GUIReader:shareReader():widgetFromJsonFile("UI/hero_main_item.json"),"Layout")
    local count = DATA_Hero:get_lenght()
    for i=1,count do
        local heroDt = DATA_Hero:getTable(i)
        self:addItem(heroDt)
    end

    --lstItem:setInnerContainerSize(CCSize(400,960))
    local widget=self:getWidgetByName("close")
    if widget then
        widget:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:getUIManager():close(self)
            end
        end)
    end
     widget=self:getWidgetByName("btn_fight")
    if widget then
        widget:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then

            end
        end)
    end

end
------------------------------------------------------------------------------
function M:addItem(heroDt)
    local confHeroData = configMgr:getConfig("heros"):GetHeroDataById(heroDt.dataID)
    local headImg = configMgr:getConfig("heros"):GetHerosArt(confHeroData.artId).headIcon
    local widgetItem = self._tplItem:clone()    -- 拷贝C++数据
    --名称
    local w = UIHelper:seekWidgetByName(widgetItem, "name")
    w:setText(confHeroData.nickname)
    --头像
    w = tolua.cast(UIHelper:seekWidgetByName(widgetItem, "Image_head"),"ImageView")
    w:loadTexture(headImg)
    w:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.began then
                self._lstItem:getScrollView():setDirection(SCROLLVIEW_DIR_NONE)
                -----------------------------------------
                -- 添加widget到self用来拖动，当到达对应区域时删除
                self.newCell = self:createUINode("ImageView",{
                    name    = "heroImg"..heroDt.GUID,
                    texture = headImg,
                    pos     = ccp(0,0),
                }):addTo(self,2)
                self.newCell.data = { GUID = heroDt.GUID, Index = heroDt.index }
                self.newCell:setPosition(sender:getTouchStartPos())

            elseif eventType == ccs.TouchEventType.moved then
                self.newCell:setPosition( sender:getTouchMovePos())
            else
                self._lstItem:getScrollView():setDirection(SCROLLVIEW_DIR_VERTICAL)

                UIHelper:seekWidgetByName(widgetItem, "name")
                self:getWidgetByName("formation_pos_bg",function ( PanelPos )
                        for i = 1,PanelPos:getChildren():count() do
                            if self.newCell then
                                local wg_slot = PanelPos:getChildByName("PanelPos_"..i)
                                if wg_slot:hitTest(ccp(self.newCell:getPosition())) then
                                    self:setFormationPosInfo(heroDt,wg_slot)
                                    break
                                end
                            end
                        end -- end for
                    end)
                -- 删除
                self.newCell:removeFromParentAndCleanup(true)
                self.newCell = nil

            end
        end)

    --信息
    w = tolua.cast(UIHelper:seekWidgetByName(widgetItem, "info"),"Label")
    w:setText(string.format("等级:%d 战斗力:%d",confHeroData.level,confHeroData.attack+confHeroData.defense))
    self._lstItem:insert(widgetItem)
end
function M:setFormationPosInfo(heroDt,slot)
    local confHeroData = configMgr:getConfig("heros"):GetHeroDataById(heroDt.dataID)
    local headImg = configMgr:getConfig("heros"):GetHerosArt(confHeroData.artId).headIcon

    local w = slot:getChildByName("pos_head")
    w:loadTexture(headImg)
    w = slot:getChildByName("name")
    w:setText(confHeroData.nickname)
end
------------------------------------------------------------------------------
--选择阵型界面相关
function M:initTouchSelFormation()
    self:showFormation(false)
    self.wg_sel_formation = tolua.cast(self:getWidgetByName("img_sel_formation"),"ImageView")
    self.wg_sel_formation:addTouchEventListener(function(weight, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:showFormation(true)
               -- self:getUIManager():openUI({uiScript=require("app.scenes.home.UIFormationLayer"), ccsFileName="UI/FormationUi_1/FormationUi_1.json"})
            end
    end)
    self:setSelFormation(self.wg_sel_formation,1)
    local wg = tolua.cast(self:getWidgetByName("return"),"Button")
    wg:addTouchEventListener(function(weight, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:showFormation(false)
            end
    end)
    self:updataItemFormation()

end
function M:setSelFormation(wg,type)
    wg.formationType=type
    local headImg = string.format("UI/common/fomation/%d.png",type)
    wg:loadTexture(headImg)
end

function M:showFormation(b)
    local wg = tolua.cast(self:getWidgetByName("PanelFormationMian"),"Layout")
    wg:setEnabled(b)
end
function M:updataItemFormation()
    self:getWidgetByName("PanelScrollView",function ( PanelScrollView )
                        local ScrollView = tolua.cast(PanelScrollView:getChildByName("ScrollView"),"ScrollView")
                        local tplItemFmt = tolua.cast(ScrollView:getChildByName("PanelItem"),"Layout")
                        --tplItemFmt:setEnabled(true)
                        self._lstItemFmt =UIListView.new(ScrollView)
                        for i=1,10 do
                            self:addItemFormation(i,tplItemFmt)
                        end
                        --tplItemFmt:setEnabled(false)
                    end)
end
function M:addItemFormation(index,tplItem)

    local widgetItem=tplItem
    if index>1 then
        widgetItem = tplItem:clone()    -- 拷贝C++数据
        self._lstItemFmt:insert(widgetItem)
    end

    --名称
    local w = UIHelper:seekWidgetByName(widgetItem, "name")
    w:setText(string.format(StringData[100000003],StringData[100000004],1) )
    --人数
    local w = UIHelper:seekWidgetByName(widgetItem, "heroInfo")
    w:setText(string.format(StringData[100000001],"5") )
    --阵型信息
    local w = UIHelper:seekWidgetByName(widgetItem, "formationInfo")
    w:setText(StringData[100000002])
    --阵型图片
    w = tolua.cast(UIHelper:seekWidgetByName(widgetItem, "formation"),"ImageView")
    self:setSelFormation(w,index)

    w.formationType=index
    function touch(weight, eventType)
        local ccs = self.ccs
        if eventType == ccs.TouchEventType.ended then
            self:setSelFormation(self.wg_sel_formation,weight.formationType)
            self:showFormation(false)
        end
    end
    w:addTouchEventListener(touch)

end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------