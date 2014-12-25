--
-- Author: wangshaopei
-- Date: 2014-12-10 14:25:17
--
-- 战斗场景 ui管理
------------------------------------------------------------------------------
-- ui 脚本文件
local UIBattleResult     = require("app.ui.UIBattleResult")

------------------------------------------------------------------------------
local battle_ui_manager  = class("battle_ui_manager",require("app.ac.ui.UIManager"))
------------------------------------------------------------------------------
function battle_ui_manager:ctor(parent)
    battle_ui_manager.super.ctor(self,parent)
end
------------------------------------------------------------------------------
-- 退出
function battle_ui_manager:onExit()
    battle_ui_manager.super.onExit(self)
end
------------------------------------------------------------------------------
--
function battle_ui_manager:init()
    battle_ui_manager.super.init(self)

    local ui_script=nil
    -- 战斗信息
    -- ui_script=self:openUI({uiScript=UIPlayerInfo, ccsFileName="UI/battle_info.json",open_close_effect=false,is_no_modle=true})
    -- ui_script:setPosition(cc.p(0,display.top - ui_script._root_widget:getSize().height))

end
----------------------------------------------------------------
--
function battle_ui_manager:createBattleResult(args)
    local ui_script=self:openUI({uiScript=UIBattleResult, ccsFileName="UI/battle_result.json",
        open_close_effect=true,
        is_no_modle=false,
        zorder = 0,
        args = args})

end
----------------------------------------------------------------
return battle_ui_manager
----------------------------------------------------------------
