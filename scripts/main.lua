----------------------------------------------------------------
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end
------------------------------------------------------------------------------
-- 全局路径
local function setfilepath()
    local platform = "unknown"
    local model    = "unknown"

    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    if target == kTargetWindows then
        platform = "windows"
    elseif target == kTargetMacOS then
        platform = "mac"
    elseif target == kTargetAndroid then
        platform = "android"
    elseif target == kTargetIphone or target == kTargetIpad then
        platform = "ios"
        if target == kTargetIphone then
            model = "iphone"
        else
            model = "ipad"
        end
    end

    ----------------------------------------------------------------
    -- 资源路径
    G_FLIE_PATH =  CCFileUtils:sharedFileUtils():getWritablePath().."upd/"
    -- 设置SD卡路径
    if platform == "android" then   -- Android
        G_FLIE_PATH = "/mnt/sdcard/projx/"
    end
end

----------------------------------------------------------------
Game = {}
----------------------------------------------------------------
--启动游戏
function Game:start()

    --加载公共模块
    self:requireCommonModule()
    --进入
    Game:go()
end
----------------------------------------------------------------
--重启游戏
function Game:restart()
    --进入
    Game:go()
end
----------------------------------------------------------------
--加载公共模块
function Game:requireCommonModule()
    setfilepath()

    -- 优先搜索IMG_PATH目录下的文件
    CCFileUtils:sharedFileUtils():addSearchPath(G_FLIE_PATH)
    CCFileUtils:sharedFileUtils():addSearchPath("res/")

    --加载下载目录里的脚本
    CCLuaLoadChunksFromZIP("framework_precompiled.zip")
    CCLuaLoadChunksFromZIP("c.p")   -- common
    CCLuaLoadChunksFromZIP("lcr.p") -- launcher
    CCLuaLoadChunksFromZIP("l.p")   -- app 逻辑


    package.loaded["launcher.init"] = nil
    require("launcher.init")
    package.loaded["channel"] = nil
    require("channel")

    -- 创建目录
    Launcher.mkDir(G_FLIE_PATH)

    require("framework.init")
end
----------------------------------------------------------------
-- 进入第一个scene
function Game:go()
    -- 切换到Logo场景
    display.replaceScene(require("launcher.logoScene").new(),"crossFade", 0.5)
end
----------------------------------------------------------------
Game:start()
----------------------------------------------------------------