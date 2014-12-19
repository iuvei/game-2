
ui = require("framework.ui")
local game = class("game", cc.mvc.AppBase)

function game:ctor()
    game.super.ctor(self)

    -- randomseed
    math.newrandomseed()

   --加载config
    -- CCLuaLoadChunksFromZIP("c.c")

    require("app.switch_scene")


    -- common
    require("common.CommonFunction")

    -- 常用组件
    require("common.UI.KNBtn")
    require("common.UI.KNMsg")

    require("common.UI.KNFileManager")

    ---------------------------------------
    -- 资源
    Res= require("common.resourceDefine")

    ---------------------------------------
    -- token
    token = {
        -- server = "gs101",
        -- user = "hello",
        -- pass = "password",
        -- gs_host = "127.0.0.1",
        -- gs_port = "8888",
    }
    if CHANNEL_ID ~= "test" then
        -- 网络层
        NETWORK = require("app.ac.net.network")
    end
    -- 全局的玩家单例
    PLAYER = require("app.mediator.player").create(NETWORK)

end

function game:run()
    -- 进入登录场景
    self:enterScene("login.login_scene")
end

return game
