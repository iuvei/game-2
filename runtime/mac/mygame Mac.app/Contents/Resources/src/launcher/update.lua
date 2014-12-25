--
-- Author: Anthony
-- Date: 2014-06-12 18:50:40
--
------------------------------------------------------------------------------
-- 图片资源
------------------------------------------------------------------------------
local IMG_BG            = "scene/login/bg.jpg"
local IMG_LODING_BOX    = "loading/box.png"
local IMG_LODINGBG      = "loading/loading.png"
local IMG_PROGRESS_BAR0 = "scene/updata/bar_0.png"
local IMG_PROGRESS_BAR1 = "scene/updata/bar_1.png"
------------------------------------------------------------------------------
-- 常量
------------------------------------------------------------------------------
local NEEDUPDATE = true     --要不要开启更新
if CHANNEL_ID == "test" then
    NEEDUPDATE = false
end
local server = WEBSERVER_URL
local param = "?dev="..device.platform
local list_filename = "flist.txt"
local downList = {}
------------------------------------------------------------------------------
--define UpdateScene
------------------------------------------------------------------------------
local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
end)
----------------------------------------------------------------
function UpdateScene:ctor()

    print("# -------------------updateBegin-------------------")
    self.path = G_FLIE_PATH

    self.restart = false

    self.layer = display.newLayer():addTo(self)
    -- self:addChild(self.layer)

    local bg = display.newSprite(IMG_BG,display.cx,display.cy):addTo(self.layer)
    -- 屏幕自适应
    local mapcontent = bg:getContentSize()
    bg:setScaleX(INIT_FUNCTION.width/mapcontent.width);
    bg:setScaleY(INIT_FUNCTION.height/mapcontent.height);

    -- local label = cc.ui.UILabel.newTTFLabel_({
    --     text = "Loading...",
    --     size = 64,
    --     x = display.cx,
    --     y = display.cy,
    --     align = ui.TEXT_ALIGN_CENTER
    -- })
    -- self:addChild(label)

    self.curfileCount = 0
end
----------------------------------------------------------------
function UpdateScene:onEnter()
    if NEEDUPDATE then
        self:checkUpdate()
    else
        self:Appentry(false)
    end
end
----------------------------------------------------------------
function UpdateScene:onExit()
    -- 删除资源图片
    display.removeSpriteFrameByImageName(IMG_BG)
    display.removeSpriteFrameByImageName(IMG_LODING_BOX)
    display.removeSpriteFrameByImageName(IMG_LODINGBG)
    display.removeSpriteFrameByImageName(IMG_PROGRESS_BAR0)
    display.removeSpriteFrameByImageName(IMG_PROGRESS_BAR1)
end
----------------------------------------------------------------
-- 创建一个进度条
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
function UpdateScene:checkUpdate()
    print("# check Update...")

    if self.viewLayer then
        self.viewLayer:removeFromParentAndCleanup(true)
        self.viewLayer = nil
    end

    self.viewLayer = CCLayer:create():addTo(self.layer)

    local loading_box = display.newSprite(IMG_LODING_BOX):addTo(self.viewLayer)
    INIT_FUNCTION.setAnchPos( loading_box , INIT_FUNCTION.cx , 50 , 0.5 , 0 )

    local loading = display.newSprite(IMG_LODINGBG):addTo(self.viewLayer)
    INIT_FUNCTION.setAnchPos( loading , INIT_FUNCTION.cx - 120 , 102 , 0.5 , 0.5 )

    -- 永久循环
    transition.execute(loading,
        CCRepeatForever:create( CCRotateBy:create(0.5 , 180) )
        )

    local label = cc.ui.UILabel.newTTFLabel_({
        text = "正在检查新版本,请稍候..." ,
        font = "Thonburi",
        size = 20,
        -- x = INIT_FUNCTION.cx - 65,
        -- y = 85,
        align = cc.ui.TEXT_ALIGN_CENTER
    }):addTo(self.viewLayer)
    INIT_FUNCTION.setAnchPos( label , INIT_FUNCTION.cx - 65 , 85 )
    label:setHorizontalAlignment(0)
    label:setColor( ccc3( 0xff , 0xff , 0xff ) )

    -- 开始处理
    if not INIT_FUNCTION.checkDirOK(self.path) then
        self:Appentry(false)
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

    -- self:performWithDelay(function()
        self.requestCount = 0
        self.requesting = list_filename
        self.newListFile = self.curListFile..".upd"
        self.dataRecv = nil
        self:requestFromServer(self.requesting)
    -- end,0.5)


    --update事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
    self:scheduleUpdate()
end
----------------------------------------------------------------
function UpdateScene:onEnterFrame(dt)
    -- print("onEnterFrame")
    if self.dataRecv then
        if self.requesting == list_filename then
            io.writefile(self.newListFile, self.dataRecv)
            self.dataRecv = nil

            self.fileListNew = dofile(self.newListFile)
            if self.fileListNew==nil then
                print(self.newListFile..": Open Error!")
                self:endProcess()
                return
            end

            -- 检测本地得到需要下载的文件数据,只要有一个文件的md5不对就更新
            local isUpdate  = false
            self.fileCount = 0
            for i,v in ipairs(self.fileListNew.stage) do
                if not INIT_FUNCTION.checkFile(self.path..v.name, v.code) then
                    self.fileCount = self.fileCount + 1
                    print("# need download file",self.path..v.name,v.code)
                    isUpdate = true
                end
            end

            if isUpdate and self.fileCount == 0 then
                self.fileCount = #self.fileListNew.stage
            end
            print("# need download count",self.fileCount)

            -- 检测游戏版本
            print("# oldver",self.fileList.ver,"newver",self.fileListNew.ver)
            if self.fileListNew.ver == self.fileList.ver then
                if not isUpdate then
                    print("# No Version Update")
                    self:endProcess()
                    return
                end
            end

            --检测更新模块版本
            print("# oldupver",self.fileList.upver,"newupver",self.fileListNew.upver)
            if self.fileListNew.upver ~= self.fileList.upver then
                self.restart = true
            end

            ----------------------------------------------------------------------------
            -- 进度条
            if self.viewLayer then
                self.viewLayer:removeFromParentAndCleanup(true)
                self.viewLayer = nil
            end

            self.viewLayer = CCLayer:create():addTo(self.layer)

            self.updateProgress = self:newProgressTimer(IMG_PROGRESS_BAR1,IMG_PROGRESS_BAR0):addTo(self.viewLayer)
            INIT_FUNCTION.setAnchPos(self.updateProgress , INIT_FUNCTION.cx, 136 , 0.5 , 0)

            self.progressLabel = cc.ui.UILabel.newTTFLabel_({
                text = "更新..." ,
                font = "Thonburi",
                size = 20,
                -- x = INIT_FUNCTION.cx - 65,
                -- y = 85,
                -- align = ui.TEXT_ALIGN_CENTER
            }):addTo(self.viewLayer)

            INIT_FUNCTION.setAnchPos( self.progressLabel ,  410 , 93 , 1 , 0 )
            self.progressLabel:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )

            local update_filename = cc.ui.UILabel.newTTFLabel_({
                text = self.fileCount ,
                font = "Thonburi",
                size = 20,
                -- x = INIT_FUNCTION.cx - 65,
                -- y = 85,
                -- align = ui.TEXT_ALIGN_CENTER
            }):addTo(self.viewLayer)
            INIT_FUNCTION.setAnchPos(update_filename , 500 , 93)
            update_filename:setColor(ccc3( 0x2c , 0x00 , 0x00 ))
            ----------------------------------------------------------------------------

            -- self:performWithDelay(function()
            --     -- 开始下载
            --     self:downIndexedVersion()
            -- end,0.1)

            -- 开始下载
            self.numFileCheck = 0
            self.requesting = "files"
            self:reqNextFile()
            return
        end

        if self.requesting == "files" then

            -- 创建目录
            local temp = string.split(self.curStageFile.name , '/')
            local dir = ""
            for i = 1 , #temp-1 do
                if temp[i] ~= "" then
                    dir = dir .. temp[i] .. "/"

                    local tempDir =  self.path..dir
                    -- print("字符串",tempDir)
                    INIT_FUNCTION.checkDirOK(tempDir)
                end
            end

            local fn = self.path..self.curStageFile.name..".upd"
            -- 写入文件
            io.writefile(fn, self.dataRecv)
            self.dataRecv = nil
            if INIT_FUNCTION.checkFile(fn, self.curStageFile.code) then

                -- 更新进度条
                self.curfileCount = self.curfileCount + 1
                local pos = math.floor(self.curfileCount*100 / self.fileCount)
                self.progressLabel:setString("已更新"..pos.."%")
                self.updateProgress.progressTimer:setPercentage(pos)


                --继续下一个
                table.insert(downList, fn)
                self:reqNextFile()
            else
                if self.restart then
                    self.restart = false --防止无限重启
                end
                print("file error!",fn)
                -- self:endProcess()
            end
            return
        end
        return
    end
end
----------------------------------------------------------------
function UpdateScene:endProcess()
    -- print("# UpdateScene:endProcess")

    local checkOK = true

    if self.fileList and self.fileList.stage then

        for i,v in ipairs(self.fileList.stage) do
            if not INIT_FUNCTION.checkFile(self.path..v.name, v.code) then
                print("# Check Files Error",self.path..v.name,v.code)
                checkOK = false
                break
            end
        end

        if checkOK then
            -- Load lua
            for i,v in ipairs(self.fileList.stage) do
                if v.act=="load" then
                    -- print("load",self.path)
                    CCLuaLoadChunksFromZIP(self.path..v.name)
                end
            end
            -- remove
            for i,v in ipairs(self.fileList.remove) do
                -- print("···",self.path..v)
                INIT_FUNCTION.removeFile(self.path..v)
            end
        else
            INIT_FUNCTION.removeFile(self.curListFile)
        end
    end

    if self.updateProgress then
        self.updateProgress.progressTimer:setPercentage(100)
    end


    if checkOK then
        VERSION = self.fileList.ver
        --启动
        self:Appentry(self.restart)
    end
end
----------------------------------------------------------------
function UpdateScene:Appentry(restart)

    -- 如果有update.lua自己更新，则重启
    if self.restart then
        self.restart = false
    end

    -- 延迟启动，不然进度条，不会显示完全
    self:performWithDelay(function()
        INIT_FUNCTION.reloadModule("launcher.appentry"):run(restart)
        print("# ---------------------appentryOk-------------------")
    end,0.5)
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

    for i,v in ipairs(downList) do
        data = INIT_FUNCTION.readFile(v)
        local fn = string.sub(v, 1, -5)
        -- print("# updateFiles",i,v,"fn: ", fn)
        io.writefile(fn, data)
        INIT_FUNCTION.removeFile(v)
    end
    self:endProcess()
end
----------------------------------------------------------------
function UpdateScene:reqNextFile()
    self.numFileCheck = self.numFileCheck+1
    self.curStageFile = self.fileListNew.stage[self.numFileCheck]
    if self.curStageFile and self.curStageFile.name then
        local fn = self.path..self.curStageFile.name
        if INIT_FUNCTION.checkFile(fn, self.curStageFile.code) then
            self:reqNextFile()
            return
        end
        fn = fn..".upd"
        if INIT_FUNCTION.checkFile(fn, self.curStageFile.code) then
            table.insert(downList, fn)
            self:reqNextFile()
            return
        end
        self:requestFromServer(self.curStageFile.name)
        return
    end

    self:updateFiles()
end
----------------------------------------------------------------
function UpdateScene:requestFromServer(filename, waittime)

    -- print("requestFromServer")
    local url = server..filename..param
    self.requestCount = self.requestCount + 1
    local index = self.requestCount

    local request = nil
    request = network.createHTTPRequest(function(event)
        local request = event.request
        printf("# REQUEST %d - event.name = %s", index, event.name)
        if event.name == "completed" then
            printf("# REQUEST %d - getResponseStatusCode() = %d", index, request:getResponseStatusCode())
            --printf("REQUEST %d - getResponseHeadersString() =\n%s", index, request:getResponseHeadersString())

            if request:getResponseStatusCode() ~= 200 then
                -- self:endProcess()
                print("# download error!")
            else
                -- printf("# REQUEST %d - getResponseDataLength() = %d", index, request:getResponseDataLength())
                if dumpResponse then
                    printf("# REQUEST %d - getResponseString() =\n%s", index, request:getResponseString())
                end
                self.dataRecv = request:getResponseData()

                -- self:onEnterFrame(0)
            end
        elseif event.name == "progress" then
            return
        else
            printf("# REQUEST %d - getErrorCode() = %d, getErrorMessage() = %s", index, request:getErrorCode(), request:getErrorMessage())
            -- self:endProcess()
        end
    end, url, "GET")

    if request then
        request:setTimeout(waittime or 30)
        request:start()
    else
        -- self:endProcess()
        print("createHTTPRequest error!")
    end
end
----------------------------------------------------------------
return UpdateScene
----------------------------------------------------------------