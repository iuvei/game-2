
local M = {}

-- 开启
function M:run( restart )

    --package.loaded["config"] = nil

    -- 如果有update.lua自己更新，则重启
    if restart then
        -- --延迟启动
        -- local handle
        -- handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
        --     handle = nil

            print("# ---------------------restart-------------------")
            -- 不知未何，在这里reloadModule("main") 后,CCLuaLoadChunksFromZIP的默认搜索路径变为"res/"了
            -- INIT_FUNCTION.reloadModule("main")
            Game:restart()
        -- end , 1.5 , false)
        return
    end
    require("app.game").new():run()
end
----------------------------------------------------------------
return M
