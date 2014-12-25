--
-- Author: Anthony
-- Date: 2014-06-24 16:25:50
--
collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)
------------------------------------------------------------------------------
--
local CommonDefine = require("app.ac.CommonDefine")
local configMgr = require("config.configMgr")
local ui_manager = import(".home_ui_manager")
local base_scene = require("app.scenes.base_scene")
----------------------------------------------------------------
local home_scene = class("home_scene", base_scene)
home_scene.SCROLL_DEACCEL_RATE = 0.95
home_scene.SCROLL_DEACCEL_DIST = 1.0
----------------------------------------------------------------
function home_scene:ctor()
    self.super.ctor(self)
    self.drag = nil
    self.offsetLimit_   = nil
    self.offsetX_=0
    self.offsetY_=0
    self.bgLayer_ = display.newLayer()
    self.buildsLayer_=display.newNode()
    self.builds_={}
    self.selBuildId_=CommonDefine.INVALID_ID
    -- 场景拖动数据
    self.drag = {
            startX  = 0,
            startY  = 0,
            lastX   = 0,
            lastY   = 0,
            offsetX = 0,
            offsetY = 0,
            isDeaccelerate=false,
        }
   -- self.bgLayer_:align(display.LEFT_BOTTOM, 0, 0)
    self:addChild(self.bgLayer_)
    local sceneSize = CCSize(display.width,display.height)
    local bgs=configMgr:getConfig("home"):getHomeRes(CommonDefine.HomeRes_BG)
    local bg_sp = {}
    for i=1,#bgs do
        local rect=configMgr:getConfig("home"):toRect(bgs[i].rect)
         local sp_ = display.newSprite(bgs[i].normal,rect.x,rect.y)
         bg_sp[#bg_sp+1]=sp_
        :addTo(self.bgLayer_,bgs[i].ZOrder)
        -- if self.bgSprite_:getContentSize().width > sceneSize.width then
        --     sceneSize.width=self.bgSprite_:getContentSize().width
        -- end
    end
    sceneSize.width=bg_sp[1]:getContentSize().width+bg_sp[2]:getContentSize().width
    self:setSceneSize(sceneSize)

    --触碰层
    self.touchLayer_ = display.newLayer()
    self:addChild(self.touchLayer_)
    self:resetOffsetLimit()
    --建筑层
    self:addChild(self.buildsLayer_)
    self:createBuilds()

    -- 背景
    --CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    -- self.bgSprite_ = display.newSprite(bgs[1].normal,display.cx,display.cy)
    --     :addTo(self)
    --CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    -- 屏幕自适应
    -- local mapcontent = self.bgSprite_:getContentSize()
    -- self.bgSprite_:setScaleX(INIT_FUNCTION.width/mapcontent.width);
    -- self.bgSprite_:setScaleY(INIT_FUNCTION.height/mapcontent.height);

    -- UI管理层
    self.UIlayer = ui_manager.new(self)

    ------------------------------------------
    -- test
    -- self:test()
    -- test
    ------------------------------------------
end
----------------------------------------------------------------
function home_scene:onEnter()
    printInfo("enter home scene ok")
    INIT_FUNCTION.AppExistsListener(self)

    self.touchLayer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.touchLayer_:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.tick))
    self:scheduleUpdate()

    if self.UIlayer then self.UIlayer:init() end
    --
    self:moveToSceneCenter()
end
----------------------------------------------------------------
function home_scene:onExit()
    if self.UIlayer then
        self.UIlayer:removeFromParent(true)
        self.UIlayer = nil
    end
    CCTextureCache:sharedTextureCache():removeAllTextures()
    -- CCTextureCache:sharedTextureCache():removeUnusedTextures()
end
function home_scene:test()
    ------------------------------------------
    --重启
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "重启"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            -- switchscene("login")
            Game:restart()
        end)
        :pos(display.cx, display.top - 30)
        :addTo(self)

    --创建英雄
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "创建英雄"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            if g_heortemp == nil then
                g_heortemp = 1
            end
            PLAYER:send("CS_Command",{
                content = "createhero "..g_heortemp.."001"
            })
            if g_heortemp < 6 then
                g_heortemp = g_heortemp+1
            else
                g_heortemp = 1
            end
        end)
        :pos(display.right - 300, display.top - 30)
        :addTo(self)

    --创建物品
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "创建物品"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            -- local t = {10103000,
            --             10104000,
            --             10105000}
            -- local t = {
            --     -- 40101000,
            --     -- 40101001,
            --     -- 40201000,
            --     -- 40202000,
            --     -- 10102000,
            --     -- 10101000,
            --     -- 30100000,
            --     -- 30100001,
            --     -- 30100002,
            -- }
            -- local t = { 10101000,10102000,10103000,10104000,10105000,10106000,10101001 }
            -- local t = {20101000,20102000,20103000}
            -- local t = { 10101000,10102000,10103000,10104000,10105000,10106000, }
            -- local t = {20101000,20102000,20103000,20104000,20105000}
            local t = {30100000,30100001,30100002}
            for i=1,#t do
                PLAYER:send("CS_Command",{
                        content = "createitem "..t[i]
                    })
            end

        end)
        :pos(display.right - 150, display.top - 30)
        :addTo(self)

    --使用物品
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "使用物品"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            -- local item_operator = require("app.mediator.item.item_operator")
            -- item_operator:compound(1001,10202000)

            -- PLAYER:send("CS_UseItem",{
            --     GUID    = 20103000,
            --     HeroGUID = 4001,
            -- })

            for i=1,10 do
                           PLAYER:send("CS_FightEnd",{
                    stageId      = 101,
                    win          = 1,
                    cbegin_time  = os.time(),
                    cend_time    = os.time(),
                    round_count  = 5,
                    count        = 5,
                    all_hp       = 10,
                })
            end

            -- item_operator:enhance( 2001, 10102000 )

        end)
        :pos(display.cx - 320, display.top - 30)
        :addTo(self)

    -- test
    ------------------------------------------
end
----------------------------------------------------------------
function home_scene:onTouch(event, x, y)
    if event == "began" then
        self.drag = {
            startX  = x,
            startY  = y,
            lastX   = x,
            lastY   = y,
            offsetX = 0,
            offsetY = 0,
            isDeaccelerate=false,
        }
        local worldPos = self:viewPos2worldPos(cc.p(x, y))
        local b=self:onTouchBuilding(worldPos)
        if b then
            self.selBuildId_=b:getBuildId()
            b:getView():touchDown()
--            printf("onTouch() - began ,buildId=%d,buildName=%s",b:getBuildId(),b:getName())
        end
        return true
    end

    if event == "moved" then
        self.drag.offsetX = x - self.drag.lastX
        self.drag.offsetY = y - self.drag.lastY
        self.drag.lastX = x
        self.drag.lastY = y
        self:moveOffset(self.drag.offsetX, self.drag.offsetY)
    elseif event == "ended" then
        --self.drag = nil
        self.drag.isDeaccelerate=true
        local worldPos = self:viewPos2worldPos(cc.p(x, y))
        if self:isContainsBySelBuildId(worldPos) then
            self.builds_[self.selBuildId_]:selected()
        end
        local b=self.builds_[self.selBuildId_]
        if b then
            b:getView():touchUp()
        end

        self.selBuildId_ = CommonDefine.INVALID_ID
    else -- "ended" or CCTOUCHCANCELLED
        self.drag = nil
    end

    return true
end
function home_scene:tick(dt)
    if self.drag then
        if self.drag.isDeaccelerate then
            self.drag.offsetX = self.drag.offsetX * home_scene.SCROLL_DEACCEL_RATE
            self:moveOffset(self.drag.offsetX, self.drag.offsetY)
            if math.abs(self.drag.offsetX) <= home_scene.SCROLL_DEACCEL_DIST then
                self.drag.isDeaccelerate=false
            end
        end
    end
end
----------------------------------------------------------------
-- 场景移动相关
function home_scene:moveToSceneCenter()
    self.drag.offsetX=0
    self.drag.offsetY=0
    self:moveOffset(math.floor(display.width/2 - self:getSceneSize().width/2) ,0)
end
function home_scene:moveOffset(offsetX, offsetY)
    self:_setOffset(self.offsetX_ + offsetX, self.offsetY_ + offsetY)
end
----------------------------------------------------------------
function home_scene:_setOffset(x, y, movingSpeed, onComplete)
    --if self.zooming_ then return end

    if x < self.offsetLimit_.minX then
        x = self.offsetLimit_.minX
    end
    if x > self.offsetLimit_.maxX then
        x = self.offsetLimit_.maxX
    end
    if y < self.offsetLimit_.minY then
        y = self.offsetLimit_.minY
    end
    if y > self.offsetLimit_.maxY then
        y = self.offsetLimit_.maxY
    end

    self.offsetX_, self.offsetY_ = x, y

    if type(movingSpeed) == "number" and movingSpeed > 0 then
        --transition.stopTarget(self.bgLayer_)
        -- transition.stopTarget(self.batch_)
        -- transition.stopTarget(self.marksLayer_)
        -- local cx, cy = self.bgLayer_:getPosition()
        -- cx, cy = math.abs(cx),math.abs(cy)
        -- local mtx = cx / movingSpeed
        -- local mty = cy / movingSpeed
        -- local movingTime
        -- if mtx > mty then
        --     movingTime = mtx
        -- else
        --     movingTime = mty
        -- end
        -- transition.moveTo(self.bgLayer_, {
        --     x = x,
        --     y = y,
        --     time = movingTime,
        --     onComplete = onComplete
        -- })
        -- transition.moveTo(self.batch_, {x = x, y = y, time = movingTime})
        -- transition.moveTo(self.marksLayer_, {x = x, y = y, time = movingTime})
    else
        self:setPos(cc.p(x, y))
         self.bgLayer_:setPosition(x, y)
         self.buildsLayer_:setPosition(x, y)
        --self:setPosition(x, y)
    end
end
----------------------------------------------------------------
function home_scene:resetOffsetLimit()
    --local mapWidth, mapHeight = self.map_:getSize()
   -- local s = self.bgLayer_:
   local size = self:getSceneSize()
    self.offsetLimit_ = {
        minX = display.width - size.width,
        maxX = 0,
        minY = display.height - size.height,
        maxY = 0,
    }
end

----------------------------------------------------------------
--场景建筑相关
function home_scene:onTouchBuilding(worldPos)
    -- for i=1,#self.builds_ do
    --     local bv = self.builds_[i]:getView()
    --     if bv and bv:contains(worldPos) then
    --         return bv:GetModel()
    --     end
    -- end
    -- print("toouch world pos :",worldPos.x,worldPos.y)
    for k,v in pairs(self.builds_) do
        local bv = v:getView()
        if bv and bv:contains(worldPos) then
            return v
        end
    end
    return nil
end
function home_scene:isContainsBySelBuildId(worldPos)
    if self.selBuildId_ == CommonDefine.INVALID_ID then
        return false
    end
    local b = self.builds_[self.selBuildId_]
    if b and b:getView():contains(worldPos) then
        return true
    end
end
function home_scene:createBuilds()
    local builds=configMgr:getConfig("home"):getHomeBuilds()
    for build_id,v in pairs(builds) do
        if v[1].isOpen then
            local build =require("app.scenes.home.HomeBuild").new(build_id,self)
            local buildView =require("app.scenes.home.HomeBuildView").new(build,nil)
            self.builds_[build_id]=build
        end
    end
end
function home_scene:getBuildsLayer()
    return self.buildsLayer_
end
----------------------------------------------------------------
return home_scene
----------------------------------------------------------------
