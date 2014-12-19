--
-- Author: wangshaopei
-- Date: 2014-12-08 16:29:27
--
--
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIPlayerInfo  = class("UIPlayerInfo", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIPlayerInfo.DialogID=uiLayerDef.ID_PlayerInfo
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIPlayerInfo:ctor(UIManager)
    UIPlayerInfo.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function UIPlayerInfo:onExit( )
    UIPlayerInfo.super.onExit(self)
end
function UIPlayerInfo:onEnter()
    UIPlayerInfo.super.onEnter(self)
end
function UIPlayerInfo:init( params )
    UIPlayerInfo.super.init(self,params)
    self:Listen()
    self:UpdataData()
end
function UIPlayerInfo:Listen()
    -- 1=金币 2=钻石 3=体力
    -- local panel_item=self._root_widget:getChildByName("PanelItem"..i)
    -- local btn = panel_item:getChildByName("ButtonAdd")
    -- btn:addTouchEventListener(function(sender, eventType)
    --                                     if eventType == self.ccs.TouchEventType.ended then
    --                                     print("···touch")
    --                                 end
    --                             end)

end
function UIPlayerInfo:UpdataData()
    if not PLAYER:get_basedata() then
        return
    end
    -- 等级
    UIHelper:seekWidgetByName(self._root_widget, "LabelLev"):setText(tostring(PLAYER:get_basedata().level))
    --
    local name =UIHelper:seekWidgetByName(self._root_widget, "LabelName")
    local name_str=PLAYER:get_basedata().name
    name:setEnabled(false)
    if name_str then
        name:setText(name_str)
        name:setEnabled(true)
    end
end
function UIPlayerInfo:ProcessNetResult(params)
    if params.msg_type == "C_UpdataHeroInfo"
        then
            self:UpdataData()
    end
end

return UIPlayerInfo
