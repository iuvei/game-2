--
-- Author: wangshaopei
-- Date: 2014-10-22 16:44:53
--
-- kindId : 1=装备 2=消耗品 3=材料 4=碎片 5＝宝石
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIPackage  = class("UIPackage", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIPackage.DialogID=uiLayerDef.ID_Package
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIPackage:ctor(UIManager)
    UIPackage.super.ctor(self,UIManager)
    self._cur_options={item_type=nil,info=nil}
end
------------------------------------------------------------------------------
-- 退出
function UIPackage:onExit( )
    UIPackage.super.onExit(self)
end
function UIPackage:onEnter()
    UIPackage.super.onEnter(self)
end
function UIPackage:init( params )
     -- self.heroinfo = PLAYER:get_mgr_heros():get_hero_by_GUID(params.GUID)
    UIPackage.super.init(self,params)
    self._channelBtns={
        UIButtonCtrl.new(self:getWidgetByName("all")),
        UIButtonCtrl.new(self:getWidgetByName("equip")),
        UIButtonCtrl.new(self:getWidgetByName("cailiao")),
        UIButtonCtrl.new(self:getWidgetByName("baoshi")),
        UIButtonCtrl.new(self:getWidgetByName("xiaohaopin")),
    }
    self._item_list_root= self:getWidgetByName("bg1")
    self._item_list_root:setTouchEnabled(true)
    self._item_info_root= self:getWidgetByName("bg2")
    self.lstCtrl = UIListView.new(UIHelper:seekWidgetByName(self._item_list_root, "ScrollView"))
    self.lstCtrlItem = UIHelper:seekWidgetByName(self._item_list_root, "PanelItem")
    self:ShowItemInfo(false)
    self:Listen()
    self:ChannelConvertion(1)
end
function UIPackage:ChannelConvertion(item_type)
    self._cur_options.item_type = item_type
    for i=1,#self._channelBtns do
        local w=self._channelBtns[i]
        if item_type == i then
            w:SetDisable(true)
            self:UpdataList({ItemType=i})
        else
            w:SetDisable(false)
        end
    end
end
function UIPackage:ShowItemInfo(b)
    self._item_info_root:setEnabled(b)
    self._item_info_root:setVisible(b)
end
function UIPackage:Listen()
    for i=1,#self._channelBtns do
        local w=self._channelBtns[i]
        w:GetCtrl():addTouchEventListener(function(sender, eventType)
                                    local ccs = self.ccs
                                    if eventType == ccs.TouchEventType.ended then
                                        self:ChannelConvertion(i)
                                    end
                                end)
    end
    local btn=UIHelper:seekWidgetByName(self._item_info_root, "btn1")
    btn:addTouchEventListener(function(sender, eventType)
                                    local ccs = self.ccs
                                    if eventType == ccs.TouchEventType.ended then
                                        self:PushBtn1()
                                    end
                                end)
    -- local btn=UIHelper:seekWidgetByName(self._item_info_root, "ButtonUse")
    -- btn:addTouchEventListener(function(sender, eventType)
    --                                 local ccs = self.ccs
    --                                 if eventType == ccs.TouchEventType.ended then
    --                                     self:PushBtn1(self._cur_options.item_type)
    --                                 end
    --                             end)
end
function UIPackage:PushBtn1()
    -- kindId : 1=装备 2=消耗品 3=材料 4=碎片 5＝宝石
    local options = self._cur_options

    if options.info.kindId == 1 then -- 装备
        -- PLAYER:send("CS_UseEquip",{
        --         op          = 0, -- 0:穿 1：卸下
        --         GUID        = options.GUID,
        --         HeroGUID    = 1,
        --     })
    elseif options.info.kindId == 5 then -- 宝石

    elseif options.info.kindId == 4 or options.info.kindId == 2 then -- 碎片 -- 消耗品
        PLAYER:send("CS_UseItem",{
                GUID        = options.info.GUID,
            })
    else

    end

end
function UIPackage:UpdataList(options)
    self:ClearItem(self.lstCtrl)
    local data__={}
    if options.ItemType == 2 then -- 装备
        self:GetItem(options.ItemType,data__)
    elseif options.ItemType == 4 then -- 宝石
        self:GetItem(options.ItemType,data__)
    elseif options.ItemType == 3 then --碎片
        self:GetItem(options.ItemType,data__)
    elseif options.ItemType == 5 then --消耗品
        self:GetItem(options.ItemType,data__)
    else
        self:GetItem(2,data__)
        self:GetItem(3,data__)
        self:GetItem(4,data__)
        self:GetItem(5,data__)
    end
    local count=1
    for key , v in pairs(data__) do
        for k_,v_ in pairs(v) do
            local info = v_:get_info()
            local item =self:AddItem(count,self.lstCtrl,self.lstCtrlItem)
            count=count+1
            self:SetIcon(item,info)
            local item_frame = UIHelper:seekWidgetByName(item,"ItemFrame")
            item_frame:setTouchEnabled(true)
            item_frame:addTouchEventListener(function(sender, eventType)
                                    local ccs = self.ccs
                                    if eventType == ccs.TouchEventType.ended then
                                        local options = {
                                        kindId=info.kindId,
                                        info=info,
                                    }
                                        self._cur_options.info = info
                                        self:UpdataItemInfo(options)
                                        self:ShowItemInfo(true)
                                    end
                                end)
        end
    end
    self.lstCtrl:updataScrollArea()
end
function UIPackage:UpdataItemInfo(options)
    local info_ = options.info
    if info_ then
        -- name
        local ctrl_name=UIHelper:seekWidgetByName(self._item_info_root,"Name")
        ctrl_name:setText(info_.name)
        -- num
        local ctrl_item_num=UIHelper:seekWidgetByName(self._item_info_root,"ItemNum")
        ctrl_item_num:setText(string.format("%d",info_.num or 1))
        -- icon
        self:SetIcon(self._item_info_root,info_)
        -- price
        local ctrl_num=UIHelper:seekWidgetByName(self._item_info_root,"num")
        ctrl_num:setText(tostring(info_.base_price))
        -- desc
        local ctrl_desc=UIHelper:seekWidgetByName(self._item_info_root,"info")
        ctrl_desc:setText(info_.desc)
    end
    local ctrl_gem_inlay = UIHelper:seekWidgetByName(self._item_info_root,"PanelGemInlay")
    ctrl_gem_inlay:setEnabled(false)
    local btn=UIHelper:seekWidgetByName(self._item_info_root, "btn1")
    btn:setEnabled(false)

    -- kindId : 1=装备 2=消耗品 3=材料 4=碎片 5＝宝石
    if options.kindId == 1 then -- 装备
        ctrl_gem_inlay:setEnabled(true)
        if info_ then

        end
    elseif options.kindId == 2 then -- 消耗品
        btn:setEnabled(true)
        btn:setTitleText(StringData[100000046])
    end
end
function UIPackage:SetIcon(item,info)
    local img=UIHelper:seekWidgetByName(item, "Item")
    img:loadTexture(info.icon)
    local frame=UIHelper:seekWidgetByName(item, "ItemFrame")
    self:SetQuality(frame,info.quality)
end
function UIPackage:SetQuality(frame,quality)
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
function UIPackage:GetItem(item_type,out_data)
    out_data[item_type]={}
    local name = "equip"
    if item_type == 2 then -- 装备
        name = "equip"
    elseif item_type == 4 then -- 宝石
        name = "gem"
    elseif item_type == 3 then -- 碎片
        name = "debris"
    elseif item_type == 5 then -- 消耗品
        name = "comitem"
    end
    local data_ = PLAYER:get_mgr(name):get_data()
    for k,v in pairs(data_) do
        if item_type ~= 3 and item_type ~= 5 then
            out_data[item_type][k]=v
        elseif item_type == 3 and v:get_info().kindId == 4 then
            out_data[item_type][k]=v
        elseif item_type == 5 and v:get_info().kindId == 2 then
            out_data[item_type][k]=v
        end
    end

end
function UIPackage:ClearItem(listCtrl)
    for i=1,listCtrl:getCount() do
        local item = listCtrl:getItemByIndex(i)
        item:setEnabled(false)
        item:setVisible(false)
    end
end
function UIPackage:AddItem(index,listCtrl,tplItem)
    if index==1 then
        for i=1,listCtrl:getCount() do
            local item = listCtrl:getItemByIndex(i)
            item:setEnabled(false)
            item:setVisible(false)
        end
    end
    local item = nil
    if index <= listCtrl:getCount() then
        item = listCtrl:getItemByIndex(index)
        item:setEnabled(true)
        item:setVisible(true)
    else
        item = self:_AddItem(index,listCtrl,tplItem)
    end
    return item
end
function UIPackage:_AddItem(index,listCtrl,tplItem)
    local item=tplItem
    if index>1 then
        item = tplItem:clone()    -- 拷贝C++数据
        listCtrl:insert(item)
    else
        item:setEnabled(true)
        item:setVisible(true)
    end
    return item
end
function UIPackage:ProcessNetResult(params)
    if params.msg_type == "SC_UseItem" then
        if params.args.result ~= 0 then
            print("···SC_UseItem ok")
            -- =args.item.dataId
            self:ChannelConvertion(self._cur_options.item_type)
            self:ShowItemInfo(false)
        end
    end
end

------------------------------------------------------------------------------
return UIPackage
------------------------------------------------------------------------------