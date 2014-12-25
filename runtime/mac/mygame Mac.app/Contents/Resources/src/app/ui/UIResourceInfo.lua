--
-- Author: wangshaopei
-- Date: 2014-12-05 17:47:58
--
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIResourceInfo  = class("UIResourceInfo", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIResourceInfo.DialogID=uiLayerDef.ID_ResourceInfo
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIResourceInfo:ctor(UIManager)
    UIResourceInfo.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function UIResourceInfo:onExit( )
    UIResourceInfo.super.onExit(self)
end
function UIResourceInfo:onEnter()
    UIResourceInfo.super.onEnter(self)
end
function UIResourceInfo:init( params )
    UIResourceInfo.super.init(self,params)
    self:Listen()
    self:UpdataData()
    self._root_widget:setTouchSwallowEnabled(true)
end
function UIResourceInfo:Listen()
    for i=1,3 do
        -- 1=金币 2=钻石 3=体力
        local panel_item=self._root_widget:getChildByName("PanelItem"..i)
        local btn = panel_item:getChildByName("ButtonAdd")
        btn:addTouchEventListener(function(sender, eventType)
                                            if eventType == self.ccs.TouchEventType.ended then

                                        end
                                    end)
    end
end
function UIResourceInfo:UpdataData()
    if not PLAYER:get_basedata() then
        return
    end
    -- 1=金币 2=钻石 3=体力
    local panel_item=self._root_widget:getChildByName("PanelItem1")
    UIHelper:seekWidgetByName(panel_item, "LabelVal"):setText(tostring(PLAYER:get_basedata().money))

    --
    panel_item=self._root_widget:getChildByName("PanelItem2")
    UIHelper:seekWidgetByName(panel_item, "LabelVal"):setText(tostring(PLAYER:get_basedata().RMB))
    --
    panel_item=self._root_widget:getChildByName("PanelItem3")
    UIHelper:seekWidgetByName(panel_item, "LabelVal"):setText(string.format(StringData[890000003],
        PLAYER:get_basedata().vigour,PLAYER:get_basedata().max_vigour))

end
function UIResourceInfo:ProcessNetResult(params)
    if params.msg_type == "C_UpdataHeroInfo"
        then
            self:UpdataData()
    end
end

return UIResourceInfo
