--
-- Author: wangshaopei
-- Date: 2014-12-08 17:37:33
--

local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local UICollectCtrl = require("app.ac.ui.UICollectCtrl")
local UIPackage     = require("app.ui.UIPackage")
local UIHero        = require("app.ui.UIHero")
------------------------------------------------------------------------------
local UIMainMenu  = class("UIMainMenu", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIMainMenu.DialogID=uiLayerDef.ID_MainMenu
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIMainMenu:ctor(UIManager)
    UIMainMenu.super.ctor(self,UIManager)
    self._collect_ctrl=nil
    self._fold_ctrl = nil
end
------------------------------------------------------------------------------
-- 退出
function UIMainMenu:onExit( )
    UIMainMenu.super.onExit(self)
end
function UIMainMenu:onEnter()
    UIMainMenu.super.onEnter(self)
end
function UIMainMenu:init( params )
    UIMainMenu.super.init(self,params)
    -- 折叠按钮
    self._fold_ctrl = UIHelper:seekWidgetByName(self._root_widget, "ImageFold")
    self._fold_ctrl:setTouchEnabled(true)
    self._fold_ctrl:addTouchEventListener(function(sender, eventType)
                                            if eventType == self.ccs.TouchEventType.ended then
                                                local state = self._collect_ctrl:Activate()
                                                self:ChangeBtnState(state)
                                            end
                                        end)
    -- 模版
    local temp = UIHelper:seekWidgetByName(self._root_widget, "PanelItem")
    -- 背包
    local package = temp
    package:getChildByName("Image"):setTouchEnabled(true)
    package:getChildByName("Image"):loadTexture("UI/main_menu/main_package_button.png")
    package:getChildByName("Image"):addTouchEventListener(function(sender, eventType)
                                            if eventType == self.ccs.TouchEventType.ended then
                                                self:getUIManager():openUI({uiScript=UIPackage, ccsFileName="UI/hero_package.json",
                                                    open_close_effect=false})
                                                self:ChangeState()
                                            end
                                        end)
    -- 英雄
    local hero = temp:clone()
    hero:getChildByName("Image"):setTouchEnabled(true)
    hero:getChildByName("Image"):loadTexture("UI/main_menu/main_hero_button.png")
    hero:getChildByName("Image"):addTouchEventListener(function(sender, eventType)
                                            if eventType == self.ccs.TouchEventType.ended then
                                                self:openUI({uiScript=UIHero, ccsFileName="UI/hero_main.json",open_close_effect=false})
                                                self:ChangeState()
                                            end
                                        end)
    self._root_widget:addChild(hero)
    -- 任务
    local mission = temp:clone()
    mission:getChildByName("Image"):setTouchEnabled(true)
    mission:getChildByName("Image"):loadTexture("UI/main_menu/main_task_button.png")
    mission:getChildByName("Image"):addTouchEventListener(function(sender, eventType)
                                            if eventType == self.ccs.TouchEventType.ended then
                                                -- self:openUI({uiScript=UIHero, ccsFileName="UI/hero_main.json",open_close_effect=false})
                                                -- self:ChangeState()
                                            end
                                        end)
    self._root_widget:addChild(mission)

    -- 控制
    self._collect_ctrl = UICollectCtrl.new(self._fold_ctrl)
    self._collect_ctrl:AddItem(mission,"up")
    self._collect_ctrl:AddItem(package,"up")
    self._collect_ctrl:AddItem(hero,"up")

    --
    self:ChangeState()
    --
    self:Listen()
    self:UpdataData()
end
function UIMainMenu:Listen()
    -- for i=1,3 do
    --     -- 1=金币 2=钻石 3=体力
    --     local panel_item=self._root_widget:getChildByName("PanelItem"..i)
    --     local btn = panel_item:getChildByName("ButtonAdd")
    --     btn:addTouchEventListener(function(sender, eventType)
    --                                         if eventType == self.ccs.TouchEventType.ended then
    --                                         print("···touch")
    --                                     end
    --                                 end)
    -- end
end
function UIMainMenu:UpdataData()


end
function UIMainMenu:ChangeState()
    local state = self._collect_ctrl:Activate()
    self:ChangeBtnState(state)
end
function UIMainMenu:ChangeBtnState(state)
    if state == "fold" then
        self._fold_ctrl:loadTexture("UI/main_menu/main_up_button.png")
    elseif state == "unfold" then
        self._fold_ctrl:loadTexture("UI/main_menu/main_down_button.png")
    end

end
function UIMainMenu:ProcessNetResult(params)
    if params.msg_type == "C_UpdataHeroInfo"
        then
            self:UpdataData()
    end
end

return UIMainMenu
