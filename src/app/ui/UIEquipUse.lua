--
-- Author: wangshaopei
-- Date: 2014-10-28 10:19:33
-- 装备使用
local string = string

local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local item_operator = require("app.mediator.item.item_operator")
------------------------------------------------------------------------------
local UIEquipUse  = class("UIEquipUse", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIEquipUse.DialogID=uiLayerDef.ID_EquipUse
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIEquipUse:ctor(UIManager)
    UIEquipUse.super.ctor(self,UIManager)
    self.isFading = false
    self._info=nil
    self._current_dlg=nil
    self._is_init_up=false
end
------------------------------------------------------------------------------
-- 退出
function UIEquipUse:onExit()
    UIEquipUse.super.onExit(self)
end
function UIEquipUse:onEnter()
    UIEquipUse.super.onEnter(self)
end
--params={state=slot.state,equip_slot=slot,hero_guid=self.heroinfo.GUID}
function UIEquipUse:init( params )
    --self.heroinfo = PLAYER:get_mgr_heros():get_hero_by_GUID(params.GUID)
    UIEquipUse.super.init(self,params)
    self._parmas = params.params
    -- init ctrl
    self._root_get_way = self:getWidgetByName("GetWay")
    self._root_get_way:setVisible(false)
    self._content_get_way = self:getWidgetByName("PanelGetWay")
    self._content_get_way:setVisible(false)
    self._content_up = self:getWidgetByName("PanelUp")
    self._content_up:setVisible(false)
    self._root_info = self:getWidgetByName("ItemInfo")
    self._lst_ctrl = UIListView.new(UIHelper:seekWidgetByName(self._root_get_way, "ScrollView"))
    self._lst_ctrl:InitialItem()
    self._btn=UIHelper:seekWidgetByName(self._root_info,"btn1")
    self._btn_get_way=UIHelper:seekWidgetByName(self._root_get_way,"Btn1")
    -- 顶部的合成链
    self._compond_link={}
    table.insert(self._compond_link, UIHelper:seekWidgetByName(self._root_get_way,"ItemBgSmall"))
    -- if self._parmas.state == 0 or self._parmas.state == 1 then
    --     if self._is_get then
    --         self._btn:setTitleText(StringData[100000036])
    --     else
    --         self._btn:setTitleText(StringData[100000038]) -- "升级公式"
    --     end
    -- if self._parmas.state == 2 then
    --     self._btn:setTitleText(StringData[890000001])
    -- end
    -- show info
    self:show_info(self._parmas.state, self._parmas.equip_slot.equip_info)
    self:Listen()
    self:ListenGetWay()
end

function UIEquipUse:show_info(state,equip_info)
    -- 显示物品信息

    local info_ = item_operator:get_equip_info( equip_info )
    self._info = info_
    local w=UIHelper:seekWidgetByName(self._root_info,"info")
    w:setText(info_.desc)
    local img=UIHelper:seekWidgetByName(self._root_info,"Item")
    img:loadTexture(info_.icon)
    local frame=UIHelper:seekWidgetByName(self._root_info,"ItemFrame")
    UIUtil:SetQuality(frame,info_.quality)
    w=UIHelper:seekWidgetByName(self._root_info,"Name")
    w:setText(info_.name)

    w=UIHelper:seekWidgetByName(self._root_info,"ItemNum")
    w:setVisible(false)
    local need_condition=UIHelper:seekWidgetByName(self._root_info,"LabelCondition")
    need_condition:setVisible(false)
    -- 穿上的不显示数量
    if state ~= 2 and info_.num and info_.num > 0 then
        w:setVisible(true)
        w:setText(string.format(StringData[100000037],info_.num))
    end
    w=UIHelper:seekWidgetByName(self._root_info,"AttInfo")
    UIUtil:SetHeroAttLabes(w,info_)
    -- 是否可合成
    -- _op_state: 1＝获取途径，2=升级，0=没有
    self._op_state = 0
    self._btn:setTitleText(StringData[890000001])

    if self._parmas.state == 1 then -- 有装备，未穿上
        self._btn:setTitleText(StringData[100000035])
    else
        local conf_compound
        if self._parmas.state == 2 then -- 已穿上
            conf_compound = configMgr:getConfig("compound"):get_next_info(self._info.dataId)
            if conf_compound then
                self._op_state = 2
            end
        elseif self._parmas.state == 0 then -- 没有装备
            local conf_output = configMgr:getConfig("equip"):get_output(self._info.dataId)
            conf_compound = configMgr:getConfig("compound"):get_next_info(self._info.dataId)
            if conf_output then
                 self._op_state = 1
            elseif conf_compound then
                self._op_state = 2
            end
        end
        self._conf_compound = conf_compound
        --
        if self._op_state == 1 then
            self._btn:setTitleText(StringData[100000036])
        elseif self._op_state == 2 then
            --todo
            self._btn:setTitleText(StringData[100000038])
            -- stre need level
            if conf_compound.elevel > self._info.elevel then
                 need_condition:setColor(display.COLOR_RED)
            end
            need_condition:setVisible(true)
            need_condition:setText(string.format(StringData[100000045],conf_compound.elevel))
        else
            self._btn:setTitleText(StringData[890000001])
        end
    end

end

function UIEquipUse:Listen()
    self._btn:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                        self:ClickBtn(self._parmas.state)
                                    end
                                end)
end
function UIEquipUse:ListenGetWay()
    self._btn_get_way:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                        if self._content_get_way:isEnabled() then
                                            if #self._compond_link == 1 then
                                                self:HideDlg(self._root_get_way)
                                            else
                                                self:ChangSubDlg("compound")
                                            end
                                        elseif self._content_up:isEnabled() then
                                            item_operator:compound(self._parmas.hero_guid,self._conf_compound.dataId)
                                        end
                                    end
                                end)
end
function UIEquipUse:ListenCompound()
    for i=1,#self._item_sub do
        local item_sub_info = self._item_sub[i]
        local frame = item_sub_info.item_sub:getChildByName("ItemFrame")
        frame:setTouchEnabled(true)
        frame:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                    -- print("···",item_sub_info.data_id)
                                        self:ChangSubDlg("get_way",item_sub_info.data_id)
                                    end
                                end)
    end

end
function UIEquipUse:ClickBtn(state)
    if state == 1 then
        PLAYER:send("CS_UseItem",{
                GUID        = self._parmas.equip_slot.equip_info.GUID,
                HeroGUID    = self._parmas.hero_guid,
            })
        self._btn:setVisible(false)
    else
        if self._op_state == 1 then
            self:ShowDlg("get_way",true)
        elseif self._op_state == 2 then
            self:ShowDlg("compound",true)
        else
            self:close()
        end
    end
end
function UIEquipUse:ShowDlg(type,is_open,isFade)
    if self.isFading then
        return
    end
    self._root_get_way:setVisible(false)
    if is_open then
        -- 设置小icon
        UIUtil:SetIconFrame(self._compond_link[1],self._info.icon,self._info.quality)
        if type == "get_way" then
            self._root_get_way:setVisible(true)
            self._root_get_way:setVisible(true)
            self:ChangSubDlg(type,self._info.dataId)
        elseif type == "compound" then
            self._root_get_way:setVisible(true)
            self._root_get_way:setVisible(true)
            self:ChangSubDlg(type,self._info.dataId)
        end
    else

    end

end
function UIEquipUse:ChangSubDlg(type,dataId)
    self._content_get_way:setVisible(false)
    self._content_up:setVisible(false)
    if type == "get_way" then
        self._content_get_way:setVisible(true)
        self._content_get_way:setVisible(true)
        self:UpdataGetWay({dataId=dataId})
    elseif type == "compound" then
        self._content_up:setVisible(true)
        self._content_up:setVisible(true)
        self:InitialUp()
        self:UpdataCompound({dataId=dataId})
    end
 end
function UIEquipUse:HideDlg(dlg)
    if dlg then
        dlg:setVisible(false)
    end
end
function UIEquipUse:UpdataGetWay(options)
    local conf_mgr = item_operator:get_conf_mgr(options.dataId)
    local conf_info = conf_mgr:get_info(options.dataId)
    local icon = conf_mgr:get_icon(options.dataId)
    self._btn_get_way:setTitleText(StringData[100000040])
    --
    local ctrl_name =UIHelper:seekWidgetByName(self._root_get_way,"Name")
    ctrl_name:setText(conf_info.name)
    -- ctrl_name:setFontColor(ffcf91)
    local root =UIHelper:seekWidgetByName(self._content_get_way,"ItemBg")
    UIUtil:SetIconFrame(root,icon,conf_info.quality)

    --
    local conf_output = configMgr:getConfig("equip"):get_output(options.dataId)
    if conf_output then
        for i=1,#conf_output do
           local stage_id = conf_output[i]
            local conf_stage = configMgr:getConfig("stages"):getStage(stage_id)
            local item=self._lst_ctrl:AddItem(i)
            item:getChildByName("WayName"):setText(conf_stage.Name)
        end
    end
end
function UIEquipUse:InitialUp()
    if not self._is_init_up  then
        self._item_main = UIHelper:seekWidgetByName(self._content_up,"ItemBg")
        self._item_sub = {}
        for i=1,#self._conf_compound.stuff_id do
            -- 合成材料dataid
            local sub_id = self._conf_compound.stuff_id[i]
            if sub_id > 0 then
                -- 拥有的合成材料个数
                local datas=item_operator:get_mgr(sub_id):get_data()
                local need_num = self._conf_compound.stuff_num[i]
                local sub_num = item_operator:get_num_by_dataId(sub_id)
                -- 创建子物品
                local item_sub =self._item_main:clone()
                local x,y=UIHelper:seekWidgetByName(self._content_up,"ImagePos"..i):getPosition()
                item_sub:setPosition(cc.p(x,y))
                --创建文本
                local color_ = ccc3(0, 255, 0)
                if sub_num < need_num then
                    color_ = ccc3(255, 0, 0)
                end
                self:createUINode("Label",{
                    name = "val",
                    text = string.format(StringData[890000003],sub_num,need_num),--%d/%d
                    -- Font = font_UIScrollViewTest,
                    pos  = cc.p(x,y-20-item_sub:getContentSize().height/2),
                    FontSize  = 30,
                    color = color_,
                }):addTo(self._item_main:getParent())

                self._item_main:getParent():addChild(item_sub)

                self._item_sub[i] = {data_id=sub_id,item_sub=item_sub}
                -- 设置icon
                local conf_equip=configMgr:getConfig("equip"):get_info(sub_id)
                if conf_equip then
                    local icon = configMgr:getConfig("equip"):get_icon(sub_id)
                    UIUtil:SetIconFrame(item_sub,icon,conf_equip.quality)
                end
            end

        end
        local ctrl_name =UIHelper:seekWidgetByName(self._content_up,"LabelMoneyVal")
        ctrl_name:setText(self._conf_compound.money)
        self.is_init_up=true
        self:ListenCompound()

    end
end
function UIEquipUse:UpdataCompound()
    self._btn_get_way:setTitleText(StringData[100000039])
    UIUtil:SetIconFrame(self._item_main,self._info.icon,self._info.quality)
    local ctrl_name =UIHelper:seekWidgetByName(self._root_get_way,"Name")
    ctrl_name:setText(self._info.name)

end
function UIEquipUse:ProcessNetResult(params)
    if params.msg_type == "SC_UseItem" then
        if params.args.result ~= 0 then
            self:close()
        end
    elseif params.msg_type == "SC_Compound" then
        if params.args.result ~= 0 then
            self:close()
        else
            --todo
        end
    elseif params.msg_type == "SC_NewHero" then

    end
end
------------------------------------------------------------------------------
return UIEquipUse
------------------------------------------------------------------------------