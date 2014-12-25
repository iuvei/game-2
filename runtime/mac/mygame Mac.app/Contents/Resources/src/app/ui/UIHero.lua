--
-- Author: wangshaopei
-- Date: 2014-09-26 17:13:33
--
------------------------------------------------------------------------------
local RichLabelCtrl = require("app.ac.ui.RichLabelCtrl")
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local M  = class("UIHero", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
M.DialogID=uiLayerDef.ID_Hero
------------------------------------------------------------------------------
function M:ctor(UIManager)
    M.super.ctor(self,UIManager)
    self.readyHeros_={}
end
------------------------------------------------------------------------------
-- 退出
function M:onExit( )
    M.super.onExit(self)
end
------------------------------------------------------------------------------
function M:init( params )
    M.super.init(self,params)
    --初始化选择阵型界面
    --self:showFormation(wgFormationMain,false)
    self:initTouchSelFormation()

     local lstItem = self:getWidgetByName("ScrollView")
     self._lstItem =UIListView.new(lstItem)
     self._tplItem = tolua.cast(GUIReader:shareReader():widgetFromJsonFile("UI/hero_main_item.json"),"Layout")

    local heros = PLAYER:get_mgr("heros"):get_data()
    for k,v in pairs(heros) do
        local heroinfo = v:get_info()
        -- dump(heroinfo)
        self:addItem({ GUID = heroinfo.GUID, dataId = heroinfo.dataId})
    end
    self:sortList("level")
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
    local ctrl_fight=UIButtonCtrl.new(self:getWidgetByName("btn_fight"))
    ctrl_fight:SetText(StringData[100000030])
    local widget_camp=UIButtonCtrl.new(self:getWidgetByName("btn_camp"))
    widget_camp:SetText(StringData[100000031])
    if ctrl_fight then
        ctrl_fight:GetCtrl():addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:sortList("fight")
                ctrl_fight:SetDisable(true)
                widget_camp:SetDisable(false)
            end
        end)
    end
    if widget_camp then
        widget_camp:GetCtrl():addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:sortList("country")
                ctrl_fight:SetDisable(false)
                widget_camp:SetDisable(true)
            end
        end)
    end
    self:initFmtSlots()
end
------------------------------------------------------------------------------
--英雄列表相关
function M:sortList(type)
    local callback =nil
    -- local item=tolua.cast(GUIReader:shareReader():widgetFromJsonFile("UI/hero_main_item.json"),"Layout")
    if type =="fight" then
        function sortFightFun(arrInList)
            table.sort(arrInList,function (a,b)
                return a.data.fight > b.data.fight
            end)
        end
        callback = sortFightFun
    elseif type == "country" then
        function sortCampFun(arrInList)
            table.sort(arrInList,function (a,b)
                return a.data.country < b.data.country
            end)
        end
        callback = sortCampFun
    elseif type == "level" then
        function sortLevelFun(arrInList)
            table.sort(arrInList,function (a,b)
                return a.data.level > b.data.level
            end)
        end
        callback = sortLevelFun
    end
    self._lstItem:updataScrollArea(callback)
end
--
function M:addItem(heroDt)
    local heroinfo = PLAYER:get_mgr("heros"):get_hero_by_GUID(heroDt.GUID)
    local widgetItem = self._tplItem:clone()    -- 拷贝C++数据
    --名称
    local w = UIHelper:seekWidgetByName(widgetItem, "name")
    w:setText(heroinfo.nickname)
    --国家
    w=UIHelper:seekWidgetByName(widgetItem, "country")
    w:setText(heroinfo.countryInfo.name)
    --头像
    w = tolua.cast(UIHelper:seekWidgetByName(widgetItem, "Image_head"),"ccui.ImageView")
    w:loadTexture(heroinfo.headIcon)
    --星级数量
    self:updataStars(UIHelper:seekWidgetByName(widgetItem, "Panel_31"),heroinfo.stars)
    --
    w:addTouchEventListener(function(sender, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.began then
                self.drag = {
                    isClickDown=true,
                    isMove=false
                }

            elseif eventType == ccs.TouchEventType.moved then
                if widgetItem.data.isFlag then
                        --KNMsg:getInstance():flashShow(confHeroData.nickname.."已经上阵")
                    self.drag.isMove=true
                    return true
                end
                if self.drag.isClickDown and not self.drag.isMove then

                    self._lstItem:getScrollView():setDirection(ccui.ScrollViewDir.none)
                    -----------------------------------------
                    -- 添加widget到self用来拖动，当到达对应区域时删除
                    self.newCell = self:createUINode("ImageView",{
                        name    = "heroImg"..heroDt.GUID,
                        texture = heroinfo.headIcon,
                        pos     = cc.p(0,0),
                    }):addTo(self,2)
                    self.newCell.data = { GUID = heroDt.GUID, Index = heroDt.index }
                    self.newCell:setPosition(sender:getTouchBeganPosition())
                end
                self.drag.isMove=true
                self.newCell:setPosition( sender:getTouchMovePosition())
            else
                self._lstItem:getScrollView():setDirection(ccui.ScrollViewDir.vertical)
                --UIHelper:seekWidgetByName(widgetItem, "name")
                --拖动后弹起处理
                if self.drag.isClickDown and self.drag.isMove then
                    self:getWidgetByName("formation_pos_bg",function ( PanelPos )
                            for i = 1,#PanelPos:getChildren() do
                                if self.newCell then
                                    local wg_slot = PanelPos:getChildByName("PanelPos_"..i)
                                    if wg_slot:hitTest(cc.p(self.newCell:getPosition())) then
                                        local data = {
                                            fId=self.wg_sel_formation.formationType,
                                            slotIndex=i,
                                            heroDt=heroDt,
                                            heroItem=widgetItem,
                                            slot=wg_slot
                                        }
                                        self:addReadyHero(data)
                                        PLAYER:get_mgr("formations"):update(self:indexToPos(self.wg_sel_formation.formationType,i),heroDt)
                                        -- 更新服务端数据
                                        self:update2server(data.slotIndex, data.heroDt)
                                        break
                                    end
                                end
                            end -- end for
                        end)
                    -- 删除
                    if self.newCell then
                        self.newCell:removeFromParentAndCleanup(true)
                        self.newCell = nil
                    end
                end
                --点击弹起处理
                if self.drag.isClickDown and not self.drag.isMove then
                    self:getUIManager():openUI({uiScript=require("app.ui.UIHeroInfo"),ccsFileName="UI/hero_info.json",
                                                params={GUID=heroDt.GUID}})
                end
            end
        end)

    --信息
    w = UIHelper:seekWidgetByName(widgetItem, "info")
    w:setText(string.format("等级:%d 战斗力:%d",heroinfo.level,heroinfo.attr.PhysicsAtk+heroinfo.attr.PhysicsDef))
    widgetItem.data={level=heroinfo.level,isFlag=false,
                    fight=heroinfo.attr.PhysicsAtk+heroinfo.attr.PhysicsDef,country=heroinfo.countryInfo.id,
                    heroDt=heroDt}
    self:setHeroFlag(widgetItem,false)
    self._lstItem:insert(widgetItem)
end
--
function M:updataStars(wgStars,num)
    for i=1,5 do
        local star=wgStars:getChildByName("star_"..i)
        if num>=i then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end
end
--
function M:getHeroItemById(GUID)
    for i=1,self._lstItem:getCount() do
        local item=self._lstItem:getItemByIndex(i)
        if item.data.heroDt.GUID==GUID then
            return item
        end
    end
end
--
function M:addReadyHero(data)
    local old_data=self:getReadyHero(data)
    if old_data then
        self:delReadyHero(old_data)
    end
    self.readyHeros_[data.slotIndex]=data
    if not data.bNoUpdateView then
        if data.heroItem then
            data.heroItem.data.isFlag=true
             self:updataHeroItem(data.heroItem)
        end
        if data.slot then
            local heroinfo = PLAYER:get_mgr("heros"):get_hero_by_GUID(data.heroDt.GUID)
            if heroinfo then
                self:setFormationPosInfo({nickname=heroinfo.nickname,headImg=heroinfo.headIcon,isFlag=true},data.slot)
                self:setSelectedFormationCell(data.fId,data.slotIndex,true)
            end

         end
    end
end
--
function M:delReadyHero(data)
    local old_data=self:getReadyHero(data)
    if old_data.heroItem then
        old_data.heroItem.data.isFlag=false
         self:updataHeroItem(old_data.heroItem)
     end
     if old_data.slot then
        self:setFormationPosInfo({nickname="--",headImg="UI/common/hero_bg_2.png",isFlag=false},old_data.slot)
        self:setSelectedFormationCell(data.fId,old_data.slotIndex,false)
     end
    self.readyHeros_[data.slotIndex]=nil
end
--
function M:getReadyHero(data)
    return self.readyHeros_[data.slotIndex]
end
--
function M:updataHeroItem(item)
    self:setHeroFlag(item,item.data.isFlag)
end
--英雄上阵
function M:setHeroFlag(item,bFlag)
    local wgImg=item:getChildByName("ImgFlag")
    if bFlag then
        wgImg:setVisible(true)
    else
        wgImg:setVisible(false)
    end
end
--
function M:setFormationPosInfo(option,slot)

    local w = slot:getChildByName("pos_head")
    w:loadTexture(option.headImg)
    w = slot:getChildByName("name")
    w:setText(option.nickname)
    slot.isFlag=option.isFlag
end
------------------------------------------------------------------------------
--选择阵型界面相关
function M:initTouchSelFormation()
    self.markCreateFormationItems=false
    --显示阵型界面
    self:showFormation(false)
    self.wg_sel_formation = self:getWidgetByName("img_sel_formation")
    self.wg_sel_formation:addTouchEventListener(function(weight, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                if not self.markCreateFormationItems then
                    self.markCreateFormationItems=true
                    self:createFormationItems()
                end
                self:showFormation(true)
                --self:getUIManager():openUI({uiScript=require("app.ui.home.UIFormationLayer"), ccsFileName="UI/FormationUi_1/FormationUi_1.json"})
            end
    end)
    --创建阵型格子数
    self:createFormationCell(self.wg_sel_formation)
    --设置选择的阵型
    self:setSelFormation(self.wg_sel_formation,G_DefaultSelectedFormation)
    for i=1,5 do
        self:setSelectedFormationCell(self.wg_sel_formation.formationType,i,false)
    end
    --关闭阵型界面
    local wg = tolua.cast(self:getWidgetByName("return"),"Button")
    wg:addTouchEventListener(function(weight, eventType)
            local ccs = self.ccs
            if eventType == ccs.TouchEventType.ended then
                self:showFormation(false)
            end
    end)

end
function M:setSelFormation(wg,type)
    wg.formationType=type
    local headImg = string.format("UI/common/fomation/%d.png",type)
    wg:loadTexture(headImg)
end

function M:showFormation(b)
    local wg = tolua.cast(self:getWidgetByName("PanelFormationMian"),"Layout")
    wg:setEnabled(b)
    wg:setVisible(b)
end
--创建阵型Item
function M:createFormationItems()
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
    w = UIHelper:seekWidgetByName(widgetItem, "heroInfo")
    w:setText(string.format(StringData[100000001],"5") )
    --阵型信息
    w = RichLabelCtrl.new(UIHelper:seekWidgetByName(widgetItem, "formationInfo"),{text = StringData[100000002]})
    --阵型图片
    w = tolua.cast(UIHelper:seekWidgetByName(widgetItem, "formation"),"ccui.ImageView")
    self:setSelFormation(w,index)

    w.formationType=index
    function touch(weight, eventType)
        local ccs = self.ccs
        if eventType == ccs.TouchEventType.ended then
            self:setSelFormation(self.wg_sel_formation,weight.formationType)
            self:showFormation(false)
            self:updataSelectedFmt()
            self:updataHerosFormationPos()
        end
    end
    w:addTouchEventListener(touch)

end
--
function M:createFormationCell(wgfmt)
    wgfmt.arrCell={}
    for i=1,5 do
        local l=self:addLabelWidget({text="-",FontSize=22,color=display.COLOR_RED})
        wgfmt:addChild(l)
        wgfmt.arrCell[i]=l
    end
end
--
function M:setSelectedFormationCell(fId,index,isLight)
    local pos =self:indexToPos(fId,index)
    local wgfmt = self.wg_sel_formation
    wgfmt.arrCell[index]:setPosition(cc.p(3+10+((pos-1)%3)*20, 66-3-10-(math.floor((pos-1)/3))*20))
    if isLight then
        wgfmt.arrCell[index]:setText(tostring(index))
    else
        wgfmt.arrCell[index]:setText("-")
    end
end
--槽索引转为阵型位置
function M:indexToPos(fId,index)
    local formation = ""
    if fId == 1 then      formation= "2,4,5,6,8"  -- 鱼鳞阵
    elseif fId == 2 then  formation= "2,3,4,5,7"  -- 长蛇阵
    elseif fId == 3 then  formation= "1,2,3,4,5"  -- 乱剑阵
    elseif fId == 4 then  formation= "2,3,6,8,9"  -- 方圆阵
    elseif fId == 5 then  formation= "1,4,5,6,7"  -- 虎韬阵
    elseif fId == 6 then  formation= "1,3,4,7,9"  -- 鹤翼阵
    elseif fId == 7 then  formation= "1,3,5,7,9"  -- 箕行阵
    elseif fId == 8 then  formation= "2,3,4,8,9"  -- 雁形阵
    elseif fId == 9 then  formation= "1,2,6,7,8"  -- 锥形阵
    elseif fId == 10 then formation= "3,4,5,6,9"  -- 锋矢阵
    end
    local arr=string.split(formation, ",")
    local pos = tonumber(arr[index])
    return pos
end
function M:posToIndex(fId,pos)
    local formation = ""
    if fId == 1 then      formation= "2,4,5,6,8"  -- 鱼鳞阵
    elseif fId == 2 then  formation= "2,3,4,5,7"  -- 长蛇阵
    elseif fId == 3 then  formation= "1,2,3,4,5"  -- 乱剑阵
    elseif fId == 4 then  formation= "2,3,6,8,9"  -- 方圆阵
    elseif fId == 5 then  formation= "1,4,5,6,7"  -- 虎韬阵
    elseif fId == 6 then  formation= "1,3,4,7,9"  -- 鹤翼阵
    elseif fId == 7 then  formation= "1,3,5,7,9"  -- 箕行阵
    elseif fId == 8 then  formation= "2,3,4,8,9"  -- 雁形阵
    elseif fId == 9 then  formation= "1,2,6,7,8"  -- 锥形阵
    elseif fId == 10 then formation= "3,4,5,6,9"  -- 锋矢阵
    end
    local arr=string.split(formation, ",")
    for i=1,#arr do
        if tonumber(arr[i])==pos then
            return i
        end
    end
    return nil
end
--
function M:initFmtSlots()
    local newCell = nil
    self:getWidgetByName("formation_pos_bg",
    function ( PanelPos )
        for i = 1,#PanelPos:getChildren() do
            local wg_slot = PanelPos:getChildByName("PanelPos_"..i)
            local wg_slot_img = wg_slot:getChildByName("pos_head")
            local function touchSlot(widget, eventType)
                local ccs = self.ccs

                if eventType == ccs.TouchEventType.began then
                    self.drag = {
                        isClickDown=true,
                        isMove=false
                    }
                elseif eventType == ccs.TouchEventType.moved then
                    if not wg_slot.isFlag then
                        return true
                    end
                    if self.drag.isClickDown and not self.drag.isMove then
                        -----------------------------------------
                        -- 添加widget到self用来拖动，当到达对应区域时删除
                        newCell = wg_slot_img:clone()
                        self:addChild(newCell,2)
                        newCell:setPosition(widget:getTouchBeganPosition())
                    end
                    self.drag.isMove=true
                    newCell:setPosition( widget:getTouchMovePosition())
                else
                    --UIHelper:seekWidgetByName(widgetItem, "name")
                    --拖动后弹起处理
                    if self.drag.isClickDown and self.drag.isMove then
                        if not wg_slot:hitTest(cc.p(newCell:getPosition())) then
                            local data = {
                                            fId=self.wg_sel_formation.formationType,
                                            slotIndex=i,
                                        }
                            self:delReadyHero(data)

                            PLAYER:get_mgr("formations"):remove(self:indexToPos(self.wg_sel_formation.formationType,i))
                            -- 更新服务端数据
                            self:update2server(data.slotIndex)
                        end
                        -- 删除
                        if newCell then
                            newCell:removeFromParentAndCleanup(true)
                            newCell = nil
                        end
                    end
                end
            end
            wg_slot_img:addTouchEventListener(touchSlot)

        end -- end for
    end)

    local Fdata_ = PLAYER:get_mgr("formations"):get_data()
    for key , v in pairs(Fdata_) do
        local info = v:get_info()

        if info.index>0 and info.GUID>0 then --需要有值

            local data = {
                fId=self.wg_sel_formation.formationType,
                heroDt= info
            }
            data.slotIndex=self:posToIndex(data.fId,info.index)
            data.heroItem=self:getHeroItemById(data.heroDt.GUID)
            data.slot=self:getSlotByIndex(data.slotIndex)
            self:addReadyHero(data)
        end
    end
end
--
function M:updataHerosFormationPos()
    G_DefaultSelectedFormation=self.wg_sel_formation.formationType
    for k,v in pairs(self.readyHeros_) do
        v.fId=self.wg_sel_formation.formationType
        PLAYER:get_mgr("formations"):update_index(v.heroDt.GUID,self:indexToPos(v.fId, v.slotIndex))
    end
end
--
function M:updataSelectedFmt()
    self:getWidgetByName("formation_pos_bg",function ( PanelPos )
                            for i = 1,#PanelPos:getChildren() do
                                local wg_slot = PanelPos:getChildByName("PanelPos_"..i)
                                if wg_slot.isFlag then
                                    self:setSelectedFormationCell(self.wg_sel_formation.formationType,i,true)
                                else
                                    self:setSelectedFormationCell(self.wg_sel_formation.formationType,i,false)
                                end

                            end -- end for
                        end)
end
function M:getSlotByIndex(index)
    local wg_slot=nil
    self:getWidgetByName("formation_pos_bg",
    function ( PanelPos )
        for i = 1,#PanelPos:getChildren() do
            if index==i then
                wg_slot = PanelPos:getChildByName("PanelPos_"..i)
                break
            end
        end
    end)
    return wg_slot
end
------------------------------------------------------------------------------
-- 更新服务端数据
function M:update2server(index, herodata)
    PLAYER:get_mgr("formations"):update_server_fomation( index, herodata )
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------