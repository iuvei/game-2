--
-- Author: Anthony
-- Date: 2014-07-16 11:42:01
-- UI 层
------------------------------------------------------------------------------
-- ui 脚本文件
local UIStages      = require("app.ui.UIStages")
-- local UIFormation   = require("app.ui.UIFormationLayer")

local UIResourceInfo     = require("app.ui.UIResourceInfo")
local UIPlayerInfo     = require("app.ui.UIPlayerInfo")
local UIMainMenu     = require("app.ui.UIMainMenu")
local UIChat        = require("app.ui.UIChat")
------------------------------------------------------------------------------
local home_ui_manager  = class("home_ui_manager",require("app.ac.ui.UIManager"))
------------------------------------------------------------------------------
function home_ui_manager:ctor(parent)
    home_ui_manager.super.ctor(self,parent)
end
------------------------------------------------------------------------------
-- 退出
function home_ui_manager:onExit()
    home_ui_manager.super.onExit(self)
end
------------------------------------------------------------------------------
--
function home_ui_manager:init()
    home_ui_manager.super.init(self)
    self:createStagesBtn()
    -- self:createFormationBtn()
    -- self:createPackageBtn()
    self:createRoleInfoDlg()
    local ui_script=nil
    -- 玩家信息
    local ui_script_player=self:openUI({uiScript=UIPlayerInfo, ccsFileName="UI/player_info.json",open_close_effect=false,is_no_modle=true})
    ui_script_player:setPosition(cc.p(0,display.top - ui_script_player._root_widget:getSize().height))
    -- 主菜单
    local ui_script_menu=self:openUI({uiScript=UIMainMenu, ccsFileName="UI/main_menu.json",open_close_effect=false,is_no_modle=true,zorder = 20000})
    ui_script_menu:setPosition(cc.p(display.right - ui_script_menu._root_widget:getSize().width,display.bottom))

    --
    ui_script=self:openUI({uiScript=UIChat, ccsFileName="UI/chat.json",open_close_effect=false,is_no_modle=true})
    -- ui_script:setPosition(cc.p(- ui_script._root_widget:getSize().width + 68,0))

end
----------------------------------------------------------------
--
function home_ui_manager:createRoleInfoDlg()
    local ui_script=self:openUI({uiScript=UIResourceInfo, ccsFileName="UI/resource_info.json",
        open_close_effect=false,
        is_no_modle=true,
        zorder = 0})
    ui_script:setPosition(cc.p(display.right/2-ui_script._root_widget:getSize().width/2,display.top - ui_script._root_widget:getSize().height))

end
-- 进入战场按钮
function home_ui_manager:createStagesBtn()

    cc.ui.UIPushButton.new({normal="scene/home/mission.png",pressed="scene/home/mission_press.png"}, {scale9 = false})
        :onButtonClicked(function()
            if table.nums(PLAYER:get_mgr("formations"):get_data()) <= 0 then
                KNMsg:getInstance():flashShow("请选择上阵英雄")
                return
            end
            self:openUI({uiScript=UIStages, ccsFileName="UI/UIstages_1/UIstages_1.json",open_close_effect=true})
        end)
        :pos(display.right-200, display.bottom+60)
        :addTo(self)
end
----------------------------------------------------------------
-- 编队
function home_ui_manager:createFormationBtn()
    cc.ui.UIPushButton.new("scene/home/my_formation.png", {scale9 = true})
        :onButtonClicked(function()
            -- print("....................open UIHero")
            --self:openUI({uiScript=UIFormation, ccsFileName="UI/FormationUi_1/FormationUi_1.json"})
            self:openUI({uiScript=UIHero, ccsFileName="UI/hero_main.json",open_close_effect=false})
            -- print("....................open UIHero ok ")
        end)
        :pos(display.right-300, display.bottom+60)
        :addTo(self)
end
----------------------------------------------------------------
-- 背包
function home_ui_manager:createPackageBtn()

    cc.ui.UIPushButton.new({normal="scene/home/main_package_button.png",pressed="scene/home/main_package_button_shade.png"}, {scale9 = false})
        :onButtonClicked(function()
            self:openUI({uiScript=UIPackage, ccsFileName="UI/hero_package.json",open_close_effect=false})
        end)
        :pos(display.right-500, display.bottom+60)
        :addTo(self)
end
----------------------------------------------------------------
return home_ui_manager
----------------------------------------------------------------
