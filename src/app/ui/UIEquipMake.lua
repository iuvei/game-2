--
-- Author: wangshaopei
-- Date: 2014-12-01 21:39:29
--
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local item_operator = require("app.mediator.item.item_operator")
local item_helper = require("app.mediator.item.item_helper")
local CommonUtil = require("app.ac.CommonUtil")
local CommonDefine = require("app.ac.CommonDefine")
------------------------------------------------------------------------------
local UIEquipMake  = class("UIEquipMake", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIEquipMake.DialogID=uiLayerDef.ID_EquipMake
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIEquipMake:ctor(UIManager)
    UIEquipMake.super.ctor(self,UIManager)
    self.isFading = false
    self._current_info={select_dlg=nil,select_equip_info=nil,select_index=nil}
    self._is_init_up=false
    self._dlgs={nil,nil,nil}
    self._btns={nil,nil,nil} -- 强化，镶嵌，附魔
    self._equip_slots={}
end
------------------------------------------------------------------------------
-- 退出
function UIEquipMake:onExit()
    UIEquipMake.super.onExit(self)
end
function UIEquipMake:onEnter()
    UIEquipMake.super.onEnter(self)
end
--params={state=slot.state,equip_slot=slot,hero_guid=self.heroinfo.GUID}
function UIEquipMake:init( params )
    --self.heroinfo = PLAYER:get_mgr_heros():get_hero_by_GUID(params.GUID)
    UIEquipMake.super.init(self,params)
    -- self._parmas = params.params
    self._hero_info = params.params.hero_info
    -- init ctrl
    self._root = self:getWidgetByName("Panel_Root")
    self._root_bg = self:getWidgetByName("Panel_bg")
    self._root_hero_info = self:getWidgetByName("PanelRoleInfo")
    -- scrollView
    self._lst_ctrl = UIListView.new(UIHelper:seekWidgetByName(self._root, "ScrollView"))
    self._lst_ctrl:InitialItem()
    for i=1,6 do
        local item=self._lst_ctrl:AddItem(i)
        UIHelper:seekWidgetByName(item,"ItemFrameLight"):setEnabled(false)
        table.insert(self._equip_slots,{use=false,equip_info=nil,item_root=item})

    end
    --
    self._btns[1] = UIHelper:seekWidgetByName(self._root, "ButtonStre")
    self._btns[2] = UIHelper:seekWidgetByName(self._root, "ButtonXiangQian")
    self._btns[3] = UIHelper:seekWidgetByName(self._root, "ButtonFuMo")

    self:ListenHeroInfo()
    self:UpdataHeroInfoDlg(self._hero_info)
end
function UIEquipMake:ListenHeroInfo()
    --
    local btn_chg = UIHelper:seekWidgetByName(self._root, "ButtonChgHero")
    btn_chg:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then

                                        end
                                    end)
    --
    for i=1,#self._equip_slots do
        local item_root = self._equip_slots[i].item_root
        local item_frame = UIHelper:seekWidgetByName(item_root,"ItemFrame")
        item_frame:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            local item_frame_light = UIHelper:seekWidgetByName(item_root,"ItemFrameLight")
                                            self._current_info.select_equip_info = nil
                                            if self._current_info.select_frame then
                                                self._current_info.select_frame:setEnabled(false)
                                            end
                                            if self._equip_slots[i].use then
                                                item_frame_light:setEnabled(true)
                                                self._current_info.select_equip_info=self._equip_slots[i].equip_info
                                                self._current_info.select_frame = item_frame_light
                                                if self._current_info.select_dlg then
                                                    self:UpdataDlg(self._current_info.select_index, self._current_info.select_equip_info.GUID)

                                                end

                                            end

                                        end
                                    end)
    end
    for i=1,#self._btns do
        self._btns[i]:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            if self._current_info.select_equip_info then
                                                self:ShowDlg(i)
                                            end
                                        end
                                    end)
    end

end
function UIEquipMake:UpdataHeroInfoDlg(hero_info)
    local function get_equip( equips, point )
        for k,v in ipairs(equips) do
            if point == item_helper.get_serial_type(v.dataId) then
                return v
            end
        end
    end
    local name = UIHelper:seekWidgetByName(self._root,"LabelName")
    -- hero_info.nickname＝nil 设置到 setText 可能导致内存泄露
    name:setText(hero_info.nickname)
    local item = UIHelper:seekWidgetByName(self._root,"Item")
    item:loadTexture(hero_info.headIcon)
    for i=0,self._lst_ctrl:getCount()-1 do
        local pos = i+1
        local item = UIHelper:seekWidgetByName(self._lst_ctrl:getItemByIndex(i),"Item")
        local equip_info = get_equip( hero_info.equips, pos )
        if equip_info then
            local equip_info_ = item_operator:get_equip_info( equip_info )
            item:loadTexture(equip_info_.icon)
            self._equip_slots[pos].use=true
            self._equip_slots[pos].equip_info=equip_info_
        end
    end
end

function UIEquipMake:ShowDlg(index)
    if self._current_info.select_dlg then
        self._current_info.select_dlg:setEnabled(false)
    end
    -- for i=1,3 do
    --     local dlg=self._dlgs[i]
    --     if dlg then
    --         dlg:setEnabled(false)
    --     end
    -- end
    -- show
    local dlg=self:_GetDlg(index)
    if dlg then
        self:UpdataDlg(index, self._current_info.select_equip_info.GUID)
        self._current_info.select_dlg = dlg
        self._current_info.select_index = index
        dlg:setVisible(true)
        dlg:setEnabled(true)
        dlg:setPositionY(self._root_hero_info:getPositionY())
        local offset_x=self._root:getContentSize().width/2 - (dlg:getContentSize().width + self._root_hero_info:getContentSize().width)/2
        self._root_hero_info:setPositionX(offset_x)
        dlg:setPositionX(self._root_hero_info:getPositionX()+self._root_hero_info:getContentSize().width)
    end
    -- stre
    if index == 1 then
        --todo
    -- inlay
    elseif index == 2 then
        --todo
    -- attach
    elseif index == 3 then

    end
    --
end
-- StringData[100000041]="强化等级:%d级"
-- StringData[100000042]="可强化等级上限:%d级"
-- StringData[100000043]="当前%d级效果:%s"
-- StringData[100000044]="升%d级效果:%s"
function UIEquipMake:UpdataDlg(index,equip_guid,options)
    -- equip info
    local equip_info = PLAYER:get_mgr("heros"):get_equip_by_guid(self._hero_info.GUID, equip_guid)
    local equip_info_ = item_operator:get_equip_info( equip_info )
    -- dlg
    local dlg=self._dlgs[index]
    -- stre
    if index == 1 then
        -- conf data of equip
        local conf_equip = configMgr:getConfig("equip"):get_info(equip_info_.dataId)
        -- 当前强化数据
        local conf_enhance = configMgr:getConfig("equip"):get_equip_enhance(equip_info_.elevel)
        -- 下级强化数据
        local conf_enhance_next = nil
        if equip_info_.elevel < conf_equip.maxlevel then
            conf_enhance_next = configMgr:getConfig("equip"):get_equip_enhance(equip_info_.elevel+1)
        end
        -- icon of equip
        local w = UIHelper:seekWidgetByName(dlg,"Item")
        w:loadTexture(equip_info_.icon)
        -- name
        w=UIHelper:seekWidgetByName(dlg,"LabelName")
        w:setText(equip_info_.name)
        w:setColor(display.COLOR_RED)
        -- stre info of current equip
        w=UIHelper:seekWidgetByName(dlg,"LabelInfo")
        w:setText(string.format(StringData[100000041],equip_info_.elevel).."\n"..string.format(StringData[100000042],conf_equip.maxlevel))
        w:setColor(display.COLOR_RED)

        w=UIHelper:seekWidgetByName(dlg,"LabelUpEffect")
        if conf_enhance_next then
             -- stre info of next equip
             local arrt_name=CommonUtil:GetItemAttrName(conf_equip.attr_type1)
             local arrt_name_text = CommonUtil:GetItemAttrNameText(conf_equip.attr_type1)
             -- print("···",current_arrt_name,next_arrt_name,conf_equip.attr_type1,
             -- conf_enhance.attr_percent1,conf_enhance_next.attr_percent1)
             local current_ = 0
             if conf_enhance then
                  current_ = item_operator:calc_equip_enhance(equip_info_.attr[arrt_name],conf_enhance.attr_percent1)
             end
             local next_ = item_operator:calc_equip_enhance(equip_info_.attr[arrt_name],conf_enhance_next.attr_percent1)
            w:setText(string.format(StringData[100000043],equip_info_.elevel,arrt_name_text.."+"..current_).."\n"
            ..string.format(StringData[100000044],equip_info_.elevel+1,arrt_name_text.."+"..next_))
            w:setColor(display.COLOR_RED)
            -- need item
            local conf_need_item = item_operator:get_conf_mgr(conf_enhance_next.stuff_id)
            local icon = conf_need_item:get_icon(conf_enhance_next.stuff_id)
            -- num
            local num=item_operator:get_num_by_dataId(conf_enhance_next.stuff_id)
            w = UIHelper:seekWidgetByName(dlg,"NeedItemNum")
            w:setText(string.format(StringData[890000003],num,conf_enhance_next.stuff_num))
            if num < conf_enhance_next.stuff_num then
                w:setColor(display.COLOR_RED)
            end
            --
            w = UIHelper:seekWidgetByName(dlg,"GoldNum")
            w:setText(conf_enhance_next.money)
            if PLAYER:get_basedata().money < conf_enhance_next.money then
                w:setColor(display.COLOR_RED)
            end
            --
            w = UIHelper:seekWidgetByName(dlg,"ImageNeedItem")
            w.contents=conf_need_item:get_info(conf_enhance_next.stuff_id).name
            w:loadTexture(icon)
        end

    -- inlay
    elseif index == 2 then
        --todo
    -- attach
    elseif index == 3 then

    end
end
function UIEquipMake:_GetDlg(index)
    local dlg = self._dlgs[index]
    if dlg then
        return dlg
    end
    local file_name = nil
    -- stre
    if index == 1 then
        file_name = "UI/equip_make_stre.json"
    -- inlay
    elseif index == 2 then
        --todo
    -- attach
    elseif index == 3 then

    end
    -- initial
    if file_name then
        dlg=tolua.cast(GUIReader:shareReader():widgetFromJsonFile(file_name),"Layout")
        self:_InitialDlg(dlg)
        self._dlgs[index]=dlg
        self._root_bg:addChild(dlg)
    end
    return self._dlgs[index]
end
function UIEquipMake:_InitialDlg(dlg,options)
    self:_ListenDlg(dlg)
end
function UIEquipMake:_ListenDlg(dlg,index)
    local w = UIHelper:seekWidgetByName(dlg,"ButtonStre")
    w:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                        -- print("···",self._current_info.select_equip_info.dataId)
                                            item_operator:enhance( self._hero_info.GUID, self._current_info.select_equip_info.dataId )
                                        end
                                    end)
    w = UIHelper:seekWidgetByName(dlg,"ImageNeedItem")
    w:setTouchEnabled(true)
    w:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            UIUtil:ShowTip(false,w)
                                        elseif eventType == self.ccs.TouchEventType.began then
                                            UIUtil:ShowTip(true,w,w.contents)
                                        end
                                    end)
end
------------------------------------------------------------------------------
-- 网络包返回
function UIEquipMake:ProcessNetResult(params)
    if params.msg_type == "SC_EquipEnhance" then
        if params.args.result ~= 0 then
            self:UpdataDlg(self._current_info.select_index, self._current_info.select_equip_info.GUID)
        end
    end
end
------------------------------------------------------------------------------
return UIEquipMake
------------------------------------------------------------------------------