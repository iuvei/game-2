INIT_FUNCTION = {}
----------------------------------------------------------------
local winSize = cc.Director:getInstance():getWinSize()
INIT_FUNCTION.width              = winSize.width
INIT_FUNCTION.height             = winSize.height
INIT_FUNCTION.cx                 = winSize.width / 2
INIT_FUNCTION.cy                 = winSize.height / 2
----------------------------------------------------------------
-- 重新加载某一模块
function INIT_FUNCTION.reloadModule( moduleName )
    package.loaded[moduleName] = nil
    return require(moduleName)
end

----------------------------------------------------------------
--[[--

创建一个层用于检测是否接收了返回键

@param bindApp

]]
function INIT_FUNCTION.AppExistsListener(bindApp)
    if device.platform == "android" then
        -- avoid unmeant back
        bindApp:performWithDelay(function()
            -- -- keypad layer, for android
            local layer = display.newLayer():addTo(bindApp)
            layer:addKeypadEventListener(function(event)
                if event == "back" then
                    -- os.exit()
                    app.exit()
                    -- device.showAlert("Confirm Exit", "Are you sure exit game ?", {"YES", "NO"}, function (event)
                    --     if event.buttonIndex == 1 then
                    --         app.exit()
                    --     else
                    --         device.cancelAlert()
                    --     end
                    -- end)
                end
            end)
            -- bindApp:addChild(layer)

            layer:setKeypadEnabled(true)

            -- layer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            --     -- self.tfUsername:setText(event.key)
            --     -- 返回按键
            --     if event.key == "back" then
            --          device.showAlert("Confirm Exit", "Are you sure exit game ?", {"YES", "NO"}, function(event)
            --              if event.buttonIndex == 1 then
            --                 app:exit()
            --             -- else
            --                -- self.tfUsername:setText("不退出啊")
            --             end
            --         end)
            --     end
            --     -- 菜单键
            --     if event.key == "menu" then

            --     end
            -- end)
        end, 0.5)
    end

    -- if device.platform == "android" then
    --     self.touchLayer = display.newLayer()
    --     self.touchLayer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
    --         if event.key == "back" then
    --             --cc.Director:getInstance():endToLua()
    --             local javaClassName = "com/cocos2dx/testgame/Testgame"
    --             local javaMethodName = "exit"
    --             luaj.callStaticMethod(javaClassName, javaMethodName)
    --         end
    --     end)
    --     self.touchLayer:setKeypadEnabled(true)
    --     self:addChild(self.touchLayer)
    -- end
end
----------------------------------------------------------------
function INIT_FUNCTION.hex(s)
     s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
     return s
end
----------------------------------------------------------------
function INIT_FUNCTION.readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end
----------------------------------------------------------------
function INIT_FUNCTION.removeFile(path)
    -- print("removeFile: "..path)
    io.writefile(path, "")
    if device.platform == "windows" then
        -- os.execute("del " .. string.gsub(path, '/', '\\'))
    else
        os.execute("rm " .. path)
    end
end
----------------------------------------------------------------
function INIT_FUNCTION.checkFile(fileName, cryptoCode)
    -- print("checkFile:", fileName,"cryptoCode:", cryptoCode)

    if not io.exists(fileName) then
        return false
    end

    local data = INIT_FUNCTION.readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode==nil then
        return true
    end

    -- local ms = crypto.md5(INIT_FUNCTION.hex(data))
    local ms = crypto.md5file(fileName)
    -- print("file cryptoCode:", ms)
    if ms==cryptoCode then
        return true
    end

    return false
end
----------------------------------------------------------------
function INIT_FUNCTION.checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    print("# currentdir path: "..oldpath)

     if lfs.chdir(path) then
        lfs.chdir(oldpath)
        print("# path check OK: "..path)
        return true
     end

     if lfs.mkdir(path) then
        print("# path create OK: "..path)
        return true
     end
end
-- ----------------------------------------------------------------
-- --[[

-- 切换场景

-- ** Param **
--  name 场景名
--  temp_data 临时变量，可传递到下一个场景
-- ]]
-- function INIT_FUNCTION.switchScene( name , temp_data )
--      -- 去掉所有未完成的动作
--      cc.Director:getInstance():getActionManager():removeAllActions()

--      local scene_file = "app/scenes/" .. name .. "/scene"

--      local scene = requires(IMG_PATH , scene_file)

--      display.replaceScene( scene:create(temp_data) )
-- end

----------------------------------------------------------------
--设置锚点与位置,x,y默认为0，锚点默认为0
function INIT_FUNCTION.setAnchPos(node,x,y,anX,anY)
    local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
    node:setAnchorPoint(ccp(aX,aY))
    node:setPosition(ccp(posX,posY))
end

-- ----------------------------------------------------------------
-- --[[--

-- Split a string by string.

-- @param string str
-- @param string delimiter
-- @return table

-- ]]
-- function INIT_FUNCTION.split(str, delimiter)
--     if (delimiter=='') then return false end
--     local pos,arr = 0, {}
--     -- for each divider found
--     for st,sp in function() return string.find(str, delimiter, pos, true) end do
--         table.insert(arr, string.sub(str, pos, st - 1))
--         pos = sp + 1
--     end
--     table.insert(arr, string.sub(str, pos))
--     return arr
-- end
-- ----------------------------------------------------------------
-- -- http get
-- function INIT_FUNCTION:httpGet(url , _callback , params)
--     params = params or {}
--     local timeout = params.timeout or 15

--     -- local function createHTTPRequest(callback, url, method)
--     --     if not method then method = "GET" end
--     --     if string.upper(tostring(method)) == "GET" then
--     --         method = kCCHTTPRequestMethodGET
--     --     else
--     --         method = kCCHTTPRequestMethodPOST
--     --     end
--     --     return CCHTTPRequest:createWithUrlLua(callback, url, method)
--     -- end

--     local function sendRequest(url , callback)
--         local request = network.createHTTPRequest(function(event)
--             printf("REQUEST - event.name = %s",event.name)

--             if event.name == "progress" then
--                 if params.progress_callback then
--                     params.progress_callback(event.total , event.now)
--                 end
--                 return
--             end

--             if event.name == "timeout" then
--                 CCLuaLog("===== error: timeout " .. timeout .. "s =====" )
--                 callback( -28 , "网络请求超时" )
--                 return
--             end

--             local request = event.request

--             local error_code = request:getErrorCode()
--             if error_code ~= 0 then
--                 CCLuaLog("===== error: " .. error_code .. " , msg: " .. request:getErrorMessage() .. " =====" )
--                 callback( error_code , request:getErrorMessage() )
--                 return
--             end

--             callback( 0 , request:getResponseData() )
--         end , url , "GET")

--         -- request:setAcceptEncoding(kCCHTTPRequestAcceptEncodingDeflate)
--         request:setTimeout(timeout)
--         request:start()
--     end

--     sendRequest( url , _callback)
-- end


-- -- http post
-- function INIT_FUNCTION:httpPost(url , request_data , _callback , params)
--     params = params or {}
--     local timeout = params.timeout or 30

--     local function http_build_query(data)
--         if type(data) ~= "table" then return "" end

--         local str = ""

--         for k , v in pairs(data) do
--             str = str .. k .. "=" .. v .. "&"
--         end

--         return str
--     end

--     local function createHTTPRequest(callback, url, method)
--         if not method then method = "GET" end
--         if string.upper(tostring(method)) == "GET" then
--             method = kCCHTTPRequestMethodGET
--         else
--             method = kCCHTTPRequestMethodPOST
--         end
--         return CCHTTPRequest:createWithUrlLua(callback, url, method)
--     end

--     local function sendRequest(url , postdata , callback)
--         local request = createHTTPRequest(function(event)
--             if event.name == "progress" then
--                 if params.progress_callback then
--                     params.progress_callback(event.total , event.now)
--                 end
--                 return
--             end

--             if event.name == "timeout" then
--                 CCLuaLog("===== error: timeout " .. timeout .. "s =====" )
--                 callback( -28 , "网络请求超时" )
--                 return
--             end

--             local request = event.request

--             local error_code = request:getErrorCode()
--             if error_code ~= 0 then
--                 CCLuaLog("===== error: " .. error_code .. " , msg: " .. request:getErrorMessage() .. " =====" )
--                 callback( error_code , request:getErrorMessage() )
--                 return
--             end

--             callback( 0 , request:getResponseDataLua() )
--         end , url , "POST")

--         -- request:setAcceptEncoding(kCCHTTPRequestAcceptEncodingDeflate)
--         request:setPOSTData(postdata)
--         request:setTimeout(timeout)
--         request:start()
--     end


--     sendRequest( url , http_build_query(request_data) , _callback)
-- end
----------------------------------------------------------------
-- function refreshCopy(percent)
--  local action
--  action = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
--      local curScene = cc.Director:getInstance():getRunningScene()

--      if INIT_FUNCTION.layer then
-- --           front = layer:getChildByTag(255)
--          INIT_FUNCTION.front:setPercentage(percent or 0)
--          INIT_FUNCTION.label:setString(percent.."%")
--          if percent >= 100 then
--              if INIT_FUNCTION.update then
--                  curScene:removeChild(INIT_FUNCTION.layer, true)
--                  INIT_FUNCTION.update:checkUpdate()
--              end
--          end
--      else
--          INIT_FUNCTION.layer = CCLayer:create()
-- --           layer:setTag(888)

--          local bg = CCSprite:create("image/scene/updata/bar_1.png")
--          bg:setPosition(ccp(240, 120))
--          INIT_FUNCTION.layer:addChild(bg)
--          INIT_FUNCTION.label = CCLabelTTF:create((percent or 0).."%", "Arial", 24)
--          INIT_FUNCTION.label:setPosition(ccp(240, 138))
--          INIT_FUNCTION.label:setAnchorPoint(ccp(0.5, 1))

-- --           INIT_FUNCTION.label:setColor(ccc3(0x2c, 0, 0))
--          INIT_FUNCTION.layer:addChild(INIT_FUNCTION.label, 1)
--          INIT_FUNCTION.front = CCProgressTimer:create(CCSprite:create("image/scene/updata/bar_0.png"))
--          INIT_FUNCTION.front:setTag(255)
--          INIT_FUNCTION.front:setPosition(ccp(240, 120))

--          INIT_FUNCTION.front:setType(kCCProgressTimerTypeBar)
--          INIT_FUNCTION.front:setMidpoint(CCPointMake(0 , 0))--设置进度方向 (0-100)
--          INIT_FUNCTION.front:setAnchorPoint(ccp(0.5 , 0.5)) --设置锚点
--          INIT_FUNCTION.front:setBarChangeRate(CCPointMake(1, 0)) --动画效果值(0或1)
--          INIT_FUNCTION.front:setPercentage(percent or 0) --动画效果值(0或1)

--          INIT_FUNCTION.layer:addChild(INIT_FUNCTION.front)
--          curScene:addChild(INIT_FUNCTION.layer)
--      end
--      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(action)
--  end, 0, false)
-- end
----------------------------------------------------------------
function INIT_FUNCTION:Log(...)
    CCLuaLog(string.format(...))
end
----------------------------------------------------------------