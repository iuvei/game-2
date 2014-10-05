--
-- Author: Anthony
-- Date: 2014-07-16 11:42:01
-- UI 层
------------------------------------------------------------------------------
-- ui 脚本文件
local UIStages     = import(".UIStages")
local UIFormation  = import(".UIFormationLayer")
local UIHero  = import(".UIHero")
------------------------------------------------------------------------------
local M  = class("HomeUILayer",require("app.ac.ui.UIManager"))
------------------------------------------------------------------------------
function M:ctor(parent)
    M.super.ctor(self,parent)
end
------------------------------------------------------------------------------
-- 退出
function M:onExit()
    M.super.onExit(self)
end
------------------------------------------------------------------------------
--
function M:init()
    M.super.init(self)
    self:createStagesBtn( )
    self:createFormationBtn()
end
----------------------------------------------------------------
-- 进入战场按钮
function M:createStagesBtn()

    cc.ui.UIPushButton.new({normal="scene/home/mission.png",pressed="scene/home/mission_press.png"}, {scale9 = false})
        :onButtonClicked(function()
            self:openUI({uiScript=UIStages, ccsFileName="UI/UIstages_1/UIstages_1.json"})
        end)
        :pos(display.right-100, display.bottom+60)
        :addTo(self)
end
----------------------------------------------------------------
-- 编队
function M:createFormationBtn()
    cc.ui.UIPushButton.new("scene/home/my_formation.png", {scale9 = true})
        :onButtonClicked(function()
            --self:openUI({uiScript=UIFormation, ccsFileName="UI/FormationUi_1/FormationUi_1.json"})
            self:openUI({uiScript=UIHero, ccsFileName="UI/hero_main.json"})
        end)
        :pos(display.right-300, display.bottom+60)
        :addTo(self)
end
----------------------------------------------------------------
return M
----------------------------------------------------------------
