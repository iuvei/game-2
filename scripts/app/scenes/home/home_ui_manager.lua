--
-- Author: Anthony
-- Date: 2014-07-16 11:42:01
-- UI 层
------------------------------------------------------------------------------
-- ui 脚本文件
local UIStages      = require("app.ui.UIStages")
local UIFormation   = require("app.ui.UIFormationLayer")
local UIHero        = require("app.ui.UIHero")
local UIPackage     = require("app.ui.UIPackage")
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
    self:createFormationBtn()
    self:createPackageBtn()
end
----------------------------------------------------------------
-- 进入战场按钮
function home_ui_manager:createStagesBtn()

    cc.ui.UIPushButton.new({normal="scene/home/mission.png",pressed="scene/home/mission_press.png"}, {scale9 = false})
        :onButtonClicked(function()
            if table.nums(PLAYER:get_mgr("formations"):get_data()) <= 0 then
                KNMsg:getInstance():flashShow("请选择上阵英雄")
                return
            end
            self:openUI({uiScript=UIStages, ccsFileName="UI/UIstages_1/UIstages_1.json",open_close_effect=false})
        end)
        :pos(display.right-100, display.bottom+60)
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
