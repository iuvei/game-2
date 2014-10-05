--
-- Author: Anthony
-- Date: 2014-06-24 16:25:50
--
------------------------------------------------------------------------------
--
local CommonDefine = require("common.CommonDefine")
local configMgr = require("config.configMgr")
local uiscript = import(".HomeUILayer")
local BaseScene = require("app.scenes.BaseScene")
----------------------------------------------------------------
local MainScene = class("MainScene", BaseScene)
MainScene.SCROLL_DEACCEL_RATE = 0.95
MainScene.SCROLL_DEACCEL_DIST = 1.0
----------------------------------------------------------------
function MainScene:ctor()
    self.super.ctor(self)
    self.drag = nil
    self.offsetLimit_   = nil
    self.offsetX_=0
    self.offsetY_=0
    self.bgLayer_ = display.newLayer()
    self.buildsLayer_=display.newNode()
    self.builds_={}
    self.selBuildId_=CommonDefine.INVALID_ID
   -- self.bgLayer_:align(display.LEFT_BOTTOM, 0, 0)
    self:addChild(self.bgLayer_)
    local sceneSize = CCSize(display.width,display.height)
    local bgs=configMgr:getConfig("home"):getHomeRes(CommonDefine.HomeRes_BG)
    for i=1,#bgs do
        local rect=configMgr:getConfig("home"):toRect(bgs[i].rect)
         self.bgSprite_ = display.newSprite(bgs[i].normal,rect.origin.x,rect.origin.y)
        :addTo(self.bgLayer_,bgs[i].ZOrder)
        if self.bgSprite_:getContentSize().width > sceneSize.width then
            sceneSize.width=self.bgSprite_:getContentSize().width
        end
    end
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
    self.UIlayer = uiscript.new(self)

    ------------------------------------------
    -- test
    --返回登陆界面
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "返回登陆界面"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            -- NETWORK:reset()
            switchscene("login")
        end)
        :pos(display.right - 100, display.top - 30)
        :addTo(self)
    -- test
    ------------------------------------------
end
----------------------------------------------------------------
function MainScene:onTouch(event, x, y)
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
        local worldPos = self:viewPos2worldPos(ccp(x, y))
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
        --self.map_:getCamera():moveOffset(self.drag.offsetX, self.drag.offsetY)
    elseif event == "ended" then
        --self.drag = nil
        self.drag.isDeaccelerate=true
        local worldPos = self:viewPos2worldPos(ccp(x, y))
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

    return
end
function MainScene:tick(dt)
    if self.drag then
        if self.drag.isDeaccelerate then
            self.drag.offsetX = self.drag.offsetX * MainScene.SCROLL_DEACCEL_RATE
            self:moveOffset(self.drag.offsetX, self.drag.offsetY)
            if math.abs(self.drag.offsetX) <= MainScene.SCROLL_DEACCEL_DIST then
                self.drag.isDeaccelerate=false
            end
        end
    end
end
----------------------------------------------------------------
function MainScene:moveOffset(offsetX, offsetY)
    self:setOffset(self.offsetX_ + offsetX, self.offsetY_ + offsetY)
end
----------------------------------------------------------------
function MainScene:setOffset(x, y, movingSpeed, onComplete)
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
        self:setPos(ccp(x, y))
         self.bgLayer_:setPosition(x, y)
         self.buildsLayer_:setPosition(x, y)
        --self:setPosition(x, y)
    end
end
----------------------------------------------------------------
function MainScene:resetOffsetLimit()
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
function MainScene:onEnter()
    INIT_FUNCTION.AppExistsListener(self)

    self.touchLayer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.touchLayer_:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.tick))
    self:scheduleUpdate()

    if self.UIlayer then self.UIlayer:init() end
end
----------------------------------------------------------------
function MainScene:onExit()
    if self.UIlayer then
        self.UIlayer:removeFromParentAndCleanup(true)
        self.UIlayer = nil
    end
    CCTextureCache:sharedTextureCache():removeAllTextures()
    -- CCTextureCache:sharedTextureCache():removeUnusedTextures()
end
----------------------------------------------------------------
--场景建筑相关
function MainScene:onTouchBuilding(worldPos)
    for i=1,#self.builds_ do
        local bv = self.builds_[i]:getView()
        if bv and bv:contains(worldPos) then
            return bv:GetModel()
        end
    end
    return nil
end
function MainScene:isContainsBySelBuildId(worldPos)
    if self.selBuildId_ == CommonDefine.INVALID_ID then
        return false
    end
    local b = self.builds_[self.selBuildId_]
    if b and b:getView():contains(worldPos) then
        return true
    end
end
function MainScene:createBuilds()
    local builds=configMgr:getConfig("home"):getHomeBuilds()
    for i=1,#builds do
        local build =require("app.scenes.home.HomeBuild").new(i,self)
        local buildView =require("app.scenes.home.HomeBuildView").new(build,nil)
        self.builds_[i]=build
    end
end
function MainScene:getBuildsLayer()
    return self.buildsLayer_
end
----------------------------------------------------------------
return MainScene
----------------------------------------------------------------
