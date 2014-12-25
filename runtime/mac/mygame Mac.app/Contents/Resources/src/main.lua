----------------------------------------------------------------
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end
package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
------------------------------------------------------------------------------
-- 全局路径
local function getfilepath()
    -- 资源路径
    local path =  cc.FileUtils:getInstance():getWritablePath().."upd/"
    -- Android 设置SD卡路径
    local sharedApplication = cc.Application:getInstance()
    if sharedApplication:getTargetPlatform() == kTargetAndroid then
        path = "/mnt/sdcard/projx/"
    end
    return path
end

-- 设定优先搜索路径
G_FLIE_PATH = getfilepath()
-- 优先搜索IMG_PATH目录下的文件
-- cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath(G_FLIE_PATH)
cc.FileUtils:getInstance():addSearchPath("res")

----------------------------------------------------------------
Game = {}
----------------------------------------------------------------
--启动游戏
function Game:start()
    --系统初始化
    self:init()
    --加载公共模块
    self:requireCommonModule()
    --进入
    Game:go()
end
----------------------------------------------------------------
--重启游戏
function Game:restart()
    if NETWORK then
        NETWORK:reset()
    end

    CCTextureCache:sharedTextureCache():removeAllTextures()
    -- 清除缓存，不然CCLuaLoadChunksFromZIP加载不了新路径下的文件
    CCFileUtils:sharedFileUtils():purgeCachedEntries()

    --(1)清理所有已经加载的模块
    self:unrequireAllUserModules()

    --(2)重新执行本文件
    -- Game = nil
    -- local path = CCFileUtils:sharedFileUtils():fullPathForFilename("scripts/main.lua")
    -- -- print("···",path)
    -- dofile(path)

    Game:start()
end
----------------------------------------------------------------
--系统初始化
function Game:init()

    --app config
    -- package.loaded["config"] = nil
    require("config")
    -- 接口转换
    require("cocos.init")
    -- framework
    -- CCLuaLoadChunksFromZIP("framework_precompiled.zip")
    require("framework.init")

    --系统模块列表，在游戏重启清除所有加载的模块时系统模块被保留
    -- framework 模块也保留，不然后进游戏会有 scheduleUpdate_ 错误
    self.systemModuleList={}
    for k,v in pairs(package.loaded) do
        -- print("·s··",k)
        self.systemModuleList[k] = v
    end
    self.presystemModuleList = {}
    for k,v in pairs(package.preload) do
        -- print("·pres··",k)
        self.presystemModuleList[k] = v
    end
end
----------------------------------------------------------------
--删除所有游戏层加载的模块
function Game:unrequireAllUserModules()

    for k,v in pairs(package.loaded) do
        if not self.systemModuleList[k] then
            package.loaded[k] = nil
        end
    end

    for k,v in pairs(package.preload) do
        if not self.presystemModuleList[k] then
            package.preload[k] = nil
        end
    end
end

----------------------------------------------------------------
--加载公共模块
function Game:requireCommonModule()

    -- --app config
    -- package.loaded["config"] = nil
    -- require("config")
    -- -- framework
    -- CCLuaLoadChunksFromZIP("framework_precompiled.zip")
    -- require("framework.init")

    --加载下载目录里的脚本
    -- CCLuaLoadChunksFromZIP("c.p")   -- common
    -- CCLuaLoadChunksFromZIP("lcr.p") -- launcher
    -- CCLuaLoadChunksFromZIP("l.p")   -- app 逻辑

    --
    require("channel")
    --服务器配置
    require("serverconfig")

    ------------------------------
   -- 创建目录
    require("lfs")
    local function mkDir(path)
        if not CCFileUtils:sharedFileUtils():isFileExist(path) then
            return lfs.mkdir(path)
        end
        return true
    end
    mkDir(G_FLIE_PATH)
    ------------------------------

    --  for k,v in pairs(package.preload) do
    --     print("···",k)
    -- end
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