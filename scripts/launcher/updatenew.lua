--
-- Author: Anthony
-- Date: 2014-06-12 18:50:40
--
------------------------------------------------------------------------------
require("version")
------------------------------------------------------------------------------
local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
end)
----------------------------------------------------------------
local NEEDUPDATE = true
local server = "http://192.168.0.2:8080/update/"
local param = "?dev="..device.platform
local versionFile = "version.txt"
local list_filename = "flist.txt"
local resourceFile = "update"
----------------------------------------------------------------
function UpdateScene:ctor(  )

    self.path = IMG_PATH
    self:createDownPath(self.path)

    self.layer = CCLayer:create():addTo(self)
    -- self:addChild(self.layer)

    display.newSprite("scene/login/bg.jpg", display.cx, display.cy):addTo(self.layer)

end
----------------------------------------------------------------
function UpdateScene:onEnter(  )
    self:checkUpdate()
end
----------------------------------------------------------------
function UpdateScene:onExit()
    if self.assetsManager then
        self.assetsManager:delete()
        assetsManager = nil
    end
end
----------------------------------------------------------------
function UpdateScene:checkUpdate()
    print("# check Update...")

    if self.viewLayer then
        self.viewLayer:removeFromParentAndCleanup(true)
        self.viewLayer = nil
    end

    self.viewLayer = CCLayer:create():addTo(self.layer)

    local loading_box = display.newSprite("loading/box.png"):addTo(self.viewLayer)
    INIT_FUNCTION.setAnchPos( loading_box , INIT_FUNCTION.cx , 50 , 0.5 , 0 )

    local loading = display.newSprite("loading/loading.png"):addTo(self.viewLayer)
    INIT_FUNCTION.setAnchPos( loading , INIT_FUNCTION.cx - 120 , 102 , 0.5 , 0.5 )

    -- 永久循环
    transition.execute(loading,
        CCRepeatForever:create( CCRotateBy:create(0.5 , 180) )
        )

    local label = ui.newTTFLabel({
        text = "正在检查新版本,请稍候..." ,
        font = "Thonburi",
        size = 20,
        -- x = INIT_FUNCTION.cx - 65,
        -- y = 85,
        align = ui.TEXT_ALIGN_CENTER
    }):addTo(self.viewLayer)

    INIT_FUNCTION.setAnchPos( label , INIT_FUNCTION.cx - 65 , 85 )
    label:setHorizontalAlignment(0)
    label:setColor( ccc3( 0xff , 0xff , 0xff ) )


    -- 开始处理
    if not INIT_FUNCTION.checkDirOK(self.path) then
        -- self:Appentry(false)
        print("没有路径：",self.path)
        return
    end

    self.curListFile =  self.path..list_filename
    self.fileList = nil
    if io.exists(self.curListFile) then
        self.fileList = dofile(self.curListFile)
    end
    if self.fileList==nil then
        self.fileList = {
            ver = "1.0.0.0",
            upver = "1.0.0.0", -- 更新文件的版本
            stage = {},
            remove = {},
        }
    end

    self.requestCount = 0
    self.requesting = list_filename
    self.newListFile = self.curListFile..".upd"
    -- self.dataRecv = nil
    self:requestFromServer(self.requesting)
end
----------------------------------------------------------------
function UpdateScene:Appentry(restart)

    print("# update End")
    -- 如果有update.lua自己更新，则重启
    if self.restart then
        self.restart = false
    end

    INIT_FUNCTION.reloadModule("init.appentry"):run(restart)
end
----------------------------------------------------------------
function UpdateScene:requestFromServer(filename, waittime)

    -- print("requestFromServer")
    local url = server..filename..param
    self.requestCount = self.requestCount + 1
    local index = self.requestCount

    local request = nil
    if NEEDUPDATE then
        request = network.createHTTPRequest(function(event)
            local request = event.request
            printf("# REQUEST %d - event.name = %s", index, event.name)
            if event.name == "completed" then
                printf("# REQUEST %d - getResponseStatusCode() = %d", index, request:getResponseStatusCode())

                if request:getResponseStatusCode() ~= 200 then
                    -- self:endProcess()
                    print("# download error!")
                else
                    printf("# REQUEST %d - getResponseDataLength() = %d", index, request:getResponseDataLength())
                    if dumpResponse then
                        printf("# REQUEST %d - getResponseString() =\n%s", index, request:getResponseString())
                    end

                    self:onEnterFrame(request:getResponseData())
                end
            else
                printf("# REQUEST %d - getErrorCode() = %d, getErrorMessage() = %s", index, request:getErrorCode(), request:getErrorMessage())
                -- self:endProcess()
            end
        end, url, "GET")
    end

    if request then
        request:setTimeout(waittime or 30)
        request:start()
    else
        -- self:endProcess()
        print("createHTTPRequest error!")
    end
end
----------------------------------------------------------------
function UpdateScene:newProgressTimer( bgBarImg,progressBarImg )
    local bg = display.newSprite(bgBarImg)
    local progressTimer = CCProgressTimer:create(display.newSprite(progressBarImg))
    bg.progressTimer = progressTimer
    progressTimer:setType(kCCProgressTimerTypeBar)
    progressTimer:setPercentage(0)
    progressTimer:setMidpoint(ccp(0,0))
    progressTimer:setBarChangeRate(ccp(1, 0))
    progressTimer:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2))
    bg:addChild(progressTimer, 140)
    return bg
end
----------------------------------------------------------------
function UpdateScene:onEnterFrame(dataRecv)
    -- print("onEnterFrame")
    if dataRecv then
        if self.requesting == list_filename then
            io.writefile(self.newListFile, dataRecv)
            dataRecv = nil

            self.fileListNew = dofile(self.newListFile)
            if self.fileListNew==nil then
                print(self.newListFile..": Open Error!")
                self:endProcess()
                return
            end

            -- 检测游戏版本
            print("# oldver",self.fileList.ver,"newver",self.fileListNew.ver)
            if self.fileListNew.ver == self.fileList.ver then
                print("# No Version Update")
                self:endProcess()
                return
            end

            --检测更新模块版本
            print("# oldupver",self.fileList.upver,"newupver",self.fileListNew.upver)
            if self.fileListNew.upver ~= self.fileList.upver then
                self.restart = true
            end


            self.numFileCheck = 1
            self.maxVerNum = 0
            -- 在新的list里面找出以前的版本，记录数量
            for i,v in ipairs(self.fileListNew.stage) do
                if v.ver == self.fileList.ver then
                    -- self.numFileCheck = self.numFileCheck + 1
                    break
                end
                self.numFileCheck = self.numFileCheck + 1
            end

            for i,v in ipairs(self.fileListNew.stage) do
                if v.ver == self.fileListNew.ver then
                    break
                end
                self.maxVerNum = self.maxVerNum + 1
            end

            if self.maxVerNum == 0 then
                self.maxVerNum = #self.fileListNew.stage
            end

            -- self.beginIndex = self.numFileCheck + 1
            -- print("开始：",self.beginIndex ,"最大",self.maxVerNum,"当前",self.numFileCheck)
            self.requesting = "files"
            -- print("..................",self.beginIndex)

            ----------------------------------------------------------------------------
            if self.viewLayer then
                self.viewLayer:removeFromParentAndCleanup(true)
                self.viewLayer = nil
            end

            self.viewLayer = CCLayer:create():addTo(self.layer)

            self.updateProgress = self:newProgressTimer("scene/updata/bar_1.png","scene/updata/bar_0.png"):addTo(self.viewLayer)
            INIT_FUNCTION.setAnchPos(self.updateProgress , INIT_FUNCTION.cx, 136 , 0.5 , 0)

            self.progressLabel = ui.newTTFLabel({
                text = "更新..." ,
                font = "Thonburi",
                size = 20,
                -- x = INIT_FUNCTION.cx - 65,
                -- y = 85,
                align = ui.TEXT_ALIGN_CENTER
            }):addTo(self.viewLayer)

            INIT_FUNCTION.setAnchPos( self.progressLabel ,  410 , 93 , 1 , 0 )
            self.progressLabel:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )
            ----------------------------------------------------------------------------

            self:performWithDelay(function()
                -- 开始下载
                self:downIndexedVersion()
            end,0.1)

            return
        end

        return
    end
end
----------------------------------------------------------------
function UpdateScene:endProcess()
    -- print("# UpdateScene:endProcess")
    if self.viewLayer then
        self.viewLayer:removeFromParentAndCleanup(true)
        self.viewLayer = nil
    end

    local checkOK = true

    if self.fileList and self.fileList.stage then

        -- for i,v in ipairs(self.fileList.stage) do
        --     if not INIT_FUNCTION.checkFile(self.path..v.name, v.code) then
        --         print("# Check Files Error")
        --         checkOK = false
        --         break
        --     end
        -- end

        if checkOK then
            -- remove
            for i,v in ipairs(self.fileList.remove) do
                print("···",self.path..v)
                INIT_FUNCTION.removeFile(self.path..v)
            end
        else
            INIT_FUNCTION.removeFile(self.curListFile)
        end
    end

    if checkOK then
        VERSION = self.fileList.ver
        --启动
        self:Appentry(self.restart)
    end
end
----------------------------------------------------------------
function UpdateScene:updateFiles()
    local data = INIT_FUNCTION.readFile(self.newListFile)
    io.writefile(self.curListFile, data)
    self.fileList = dofile(self.curListFile)
    if self.fileList==nil then
        self:endProcess()
        return
    end
    INIT_FUNCTION.removeFile(self.newListFile)
    -- 删除文件
    -- INIT_FUNCTION.removeFile(device.writablePath.."UserDefault.xml")

    if self.assetsManager then
        self.assetsManager:deleteVersion()
    end

    -- for i,v in ipairs(downList) do
    --     data = INIT_FUNCTION.readFile(v)
    --     local fn = string.sub(v, 1, -5)
    --     print("# updateFiles",i,v,"fn: ", fn)
    --     io.writefile(fn, data)
    --     INIT_FUNCTION.removeFile(v)
    -- end
    self:endProcess()
end
----------------------------------------------------------------
function UpdateScene:downIndexedVersion(  )
    if self.updateProgress then
        self.updateProgress.progressTimer:setPercentage(0)
    end

    if self.numFileCheck <= self.maxVerNum then
        self.numFileCheck = self.numFileCheck+1

        self.curStageFile = self.fileListNew.stage[self.numFileCheck]
        if self.curStageFile and self.curStageFile.link and self.curStageFile.verlink then
            -- print("下载号",self.numFileCheck,"下载路径:",self.curStageFile.link)

            if self.assetsManager then
                self.assetsManager:setVersionFileUrl(self.curStageFile.verlink)
                self.assetsManager:setPackageUrl(self.curStageFile.link)
            else

                self.assetsManager = AssetsManager:new(self.curStageFile.link,--资源包路径
                                                        self.curStageFile.verlink,--代码号路径
                                                        self.path)  --存储路径
                self.assetsManager:registerScriptHandler(handler(self, self.downHandler))
            end

            if NEEDUPDATE then
                if self.assetsManager:checkUpdate() then
                    self.assetsManager:update()
                    return
                end
            end
        end
    end

    self:updateFiles()
end
----------------------------------------------------------------
function UpdateScene:downHandler( event )
    -- print("···",event)
    if event == "success" then
        -- 开始下载
        self:downIndexedVersion()
    elseif string.sub(event,1,5) == "error"then
        local text = ""
        if event == "errorNetwork" then
            text = "网络出错！"
        end
        if event == "errorNoNewVersion" then
            if self.updateProgress then
                self.updateProgress.progressTimer:setPercentage(100)
            end
            text = "已是最新"
        end
        if event == "errorUncompress" then
            text = "解压出错"
        end
        if event == "errorUnknown" then
            text = "未知错误"
        end

        self.progressLabel:setString(text)
        -- self:performWithDelay(function ( )
        --     game.startup()
        -- end,2)
    else

        -- local alreadyDownPercent = (self.numFileCheck - self.beginIndex)*100/(self.maxVerNum  - self.beginIndex + 1)
        -- print("alreadyDownPercent:",alreadyDownPercent,self.numFileCheck,self.beginIndex,self.maxVerNum)
        -- alreadyDownPercent = alreadyDownPercent + event/(self.maxVerNum - self.beginIndex + 1)
        -- alreadyDownPercent = math.floor(alreadyDownPercent)
        -- self.progressLabel:setString("已更新"..alreadyDownPercent.."%")
        -- self.updateProgress.progressTimer:setPercentage(alreadyDownPercent)

        self.progressLabel:setString("已更新"..event.."%")
        self.updateProgress.progressTimer:setPercentage(event)
    end
end
----------------------------------------------------------------
function UpdateScene:createDownPath( path )
    if not INIT_FUNCTION.checkDirOK(path) then
        print("更新目录创建失败，直接开始游戏")
        -- game.startup()
        return
    else
        print("更新目录存在或创建成功")
    end
end
----------------------------------------------------------------
return UpdateScene
----------------------------------------------------------------