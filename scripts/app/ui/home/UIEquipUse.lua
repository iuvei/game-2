--
-- Author: wangshaopei
-- Date: 2014-10-28 10:19:33
-- 装备使用
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIEquipUse  = class("UIEquipUse", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIEquipUse.DialogID=uiLayerDef.ID_EquipUse
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIEquipUse:ctor(UIManager)
    UIEquipUse.super.ctor(self,UIManager)
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
    --self.heroinfo = CLIENT_PLAYER:get_mgr_heros():get_hero_by_GUID(params.GUID)
    UIEquipUse.super.init(self,params)
    self._parmas = params.params
    self._btn=self:getWidgetByName("btn1")
    if self._parmas.state == 0 then
        self._btn:setTitleText(StringData[100000036])
    elseif self._parmas.state == 1 then
        self._btn:setTitleText(StringData[100000035])
    elseif self._parmas.state == 2 then
        self._btn:setTitleText(StringData[890000001])
    end
    if self._parmas.state == 1 or self._parmas.state == 2 then
        local info_ = self._parmas.equip_slot.equip_info
        local w=self:getWidgetByName("info")
        w:setText(info_.desc)
        local img=self:getWidgetByName("Item")
        img:loadTexture(info_.icon)
        local frame=self:getWidgetByName("ItemFrame")
        UIUtil:SetQuality(frame,info_.quality)
        w=self:getWidgetByName("Name")
        w:setText(info_.name)
        w=self:getWidgetByName("ItemNum")
        w:setEnabled(false)
        if info_.num then
            w:setEnabled(true)
            w:setText(string.format(StringData[100000037],info_.num))
        end
        w=self:getWidgetByName("AttInfo")
        UIUtil:SetHeroAttLabes(w,info_)
    end
    self:Listen()
end

function UIEquipUse:Listen()
    self._btn:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                        self:ClickBtn(self._parmas.state)
                                    end
                                end)
end
function UIEquipUse:ClickBtn(state)
    if state == 1 then
        CLIENT_PLAYER:send("CS_UseItem",{
                GUID        = self._parmas.equip_slot.equip_info.GUID,
                HeroGUID    = self._parmas.hero_guid,
            })
        self._btn:setEnabled(false)
    else
        self:close()
    end
end
function UIEquipUse:ProcessNetResult(params)
    if params.msg_type == "SC_UseItem" then
        if params.args.result ~= 0 then
            self:close()
        end
    end
end
------------------------------------------------------------------------------
return UIEquipUse
------------------------------------------------------------------------------