
-- require("config")
require("framework.init")
local game = class("game", cc.mvc.AppBase)

function game:ctor()
    game.super.ctor(self)

    -- randomseed
    math.newrandomseed()

   --加载config
    CCLuaLoadChunksFromZIP("c.c")


    require("app.switchscene")


    -- common
    require("common.CommonFunction")

    -- 常用组件
    require("common.UI.KNButton")
    -- require("common.UI.KNBtn")
    require("common.UI.KNMsg")
    require("common.UI.KNProgress")
    -- require("common.UI.KNScrollView")

    require("common.UI.KNFileManager")

    ---------------------------------------
    -- 资源
    Res= require("common.resourceDefine")

    ---------------------------------------
    if CHANNEL_ID ~= "test" then
        -- 网络层
        NETWORK = require("app.net.network")
    end

    -- 全局的玩家单例
    CLIENT_PLAYER = require("app.mediator.client_player").new()

end

function game:run()
    -- 进入登录场景
    self:enterScene("login.loginscene")
end

return game
