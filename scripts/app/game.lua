
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
    --[[数据初始化]]
    require("app.data.dataMgr"):init()
    ---------------------------------------
    -- 网络层
    if CHANNEL_ID ~= "test" then
        NETWORK = require("app.net.network")
    end

end

function game:run()
    -- 进入登录场景
    self:enterScene("login.loginscene")
end

return game
