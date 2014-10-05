--
-- Author: Anthony
-- Date: 2014-08-08 16:10:38
-- 关卡 UI
------------------------------------------------------------------------------
local config = require("config.configMgr")
local uiLayerDef =require("app.ac.uiLayerDefine")
------------------------------------------------------------------------------
local M  = class("UIStages", require("app.ac.ui.UIBase"))
M.DialogID=uiLayerDef.ID_Stages
------------------------------------------------------------------------------
function M:ctor(UIManager)
    M.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function M:onExit( )
    M.super.onExit(self)
end
------------------------------------------------------------------------------
-- 编辑阵形UI
function M:init( ccsFileName )
    M.super.init(self,ccsFileName)

    self:CreateSgateSelectBtn()

    self:updateHeroPanel(1)
end
------------------------------------------------------------------------------
function M:CreateSgateSelectBtn()

    local lastbtn = nil
    for i=1,3 do

        local function createBtn( Widget )
            -- 没有时克隆上一个控件
            if Widget == nil then

                Widget= lastbtn:clone()
                Widget:setName("sgateselect_"..i)
                local posX,posY = lastbtn:getPosition()
                Widget:setPosition(ccp(posX+100,posY))
                lastbtn:getParent():addChild(Widget)
                Widget:setSelectedState(false)
            end

            local alert = Widget:getChildByName("Label_btnname")
            if i==1 then
                alert:setText("普通")
                alert:setFontName(self:getFont())
                alert:setFontSize(30)
                alert:setColor(ccc3(255, 160, 66))
            elseif i==2 then
                alert:setText("精英")
                alert:setFontSize(30)
                alert:setColor(display.COLOR_WHITE)
            elseif i==3 then
                alert:setText("团队")
                alert:setFontSize(30)
                alert:setColor(display.COLOR_WHITE)
            end

            -- 绑定监听函数
            local function selectedEvent( sender, eventType )
                local Type = string.split(sender:getName(),"_")
                self:setStageSelect(Type[2])
                if eventType == 0 then -- 选择
                    self:updateHeroPanel(tonumber(Type[2]))
                end
            end
            Widget:addEventListenerCheckBox(selectedEvent)

            lastbtn = Widget
        end
        --
        self:getWidgetByName("sgateselect_"..i,createBtn)
    end

    self:setStageSelect(1)
end
------------------------------------------------------------------------------
function M:setStageSelect( seclected )

    if self.lastSelectStage == nil then self.lastSelectStage = 1 end

    self:getWidgetByName("sgateselect_"..self.lastSelectStage,function( Widget )
        if Widget == nil then return end
        Widget:getChildByName("Label_btnname"):setColor(display.COLOR_WHITE)
        Widget:setSelectedState(false)
    end)

    self:getWidgetByName("sgateselect_"..seclected,function( Widget )
        if Widget == nil then return end
        Widget:getChildByName("Label_btnname"):setColor(ccc3(255, 160, 66))
        Widget:setSelectedState(true)
        self.lastSelectStage = seclected
    end)
end
------------------------------------------------------------------------------
--pageView:    PageView
--pIdx:     该页显示的内容索引(1 ~ pages)
--iIdx:     插入位置
--bClone:   是否克隆, 第一页已存在为false, 否则为true
--callback_: 增加后回调处理函数
function M:addPage(pageView,pIdx, iIdx, bClone,callback_)

    local newPage = pageView:getPage(0)
    -- 没有则退出
    if newPage == nil then return false end
    -- clone
    if bClone then newPage = pageView:getPage(0):clone() end

    -- 回调
    if callback_ and callback_(newPage,pIdx,iIdx) then
        -- 先设置为可用
        newPage:setEnabled(true)
        -- 插入
        pageView:insertPage(newPage, iIdx)

        -- 不为clone，后续不处理
        if not bClone then return end

        --创建页点
        self:getWidgetByName("stageselect_chapter"..pIdx-1,function( selectdot )
            if selectdot == nil then return end
            local selclone = selectdot:clone()
            selclone:setName("stageselect_chapter"..pIdx)
            selclone:setScale(1)
            selclone:setPosition(ccp(30,0))
            selectdot:addChild(selclone)
            selclone:setSelectedState(false)
        end)
    else
        -- 如果为clone的则删除，没有则设置为不可见
        if bClone then newPage:removeSelf()
        else newPage:setEnabled(false)
        end
    end
end
------------------------------------------------------------------------------
--面板刷新
function M:updateHeroPanel(stageType)

    local chapters = config:getConfig("stages")

    -- self.stageType = 1 -- 1.普通，2.精英，3.团队

    --PageView
    local pvWnd = self:getWidgetByName("PageView",function( Widget )
        --删除原来的页面(第一页保留用于clone)
        for i = Widget:getPages():count() - 1, 1, -1 do
            Widget:removePageAtIndex(i)
        end

        -- 监听事件
        local function pageViewEvent(sender, eventType)
            if eventType == self.ccs.PageViewEventType.turning then
                self:setSelected( Widget:getCurPageIndex()+1 )
            end
        end
        Widget:addEventListenerPageView(pageViewEvent)
    end)

    -- 删除页点
    self:getWidgetByName("stageselect_chapter1",function( selectdot )
        selectdot:removeAllChildren()
        self:setSelected(1)
    end)


    ------------------------------------------------------------------
    -- 根据类型加载背景
    local pos = nil
    -- 先删除上次的
    if self.lastImage_bg == nil then self.lastImage_bg = 1 end
    self:getWidgetByName("Image_bg"..self.lastImage_bg,function( Image_bg )
        if Image_bg == nil then return end
        pos = ccp(Image_bg:getPosition())
        --
        local sequence = transition.sequence({ CCFadeOut:create(0.2)})
        transition.execute( Image_bg,sequence,{
            onComplete = function()
                Image_bg:removeFromParentAndCleanup(true)
            end,
        })
    end)
    self.lastImage_bg = stageType

    -- 再生成新的
    self:getWidgetByName("Panel_bg",function( Panel_bg )

        local function getBgImg( typeId )
            if stageType     == 1 then return "UI/UIstages_1/bg/stage-map-frame.png"
            elseif stageType == 2 then return "UI/UIstages_1/bg/stage-map-guildraid-frame.png"
            elseif stageType == 3 then return "UI/UIstages_1/bg/stage_map_guild_frame.png"
            end
            return ""
        end

        local newImage_bg = self:createUINode("ImageView",{
            name    = "Image_bg"..stageType,
            pos     = pos,
            texture = getBgImg(stageType),
        }):addTo(Panel_bg)
        local sequence = transition.sequence({ CCFadeIn:create(0.1) })
        transition.execute( newImage_bg,sequence)
    end)
    ------------------------------------------------------------------

    -- 创建关卡相关
    local function createStage(newPage,pIdx,iIdx)

        local data = chapters:getChapterData(pIdx,stageType)
        if data == nil then return false end

        -- 新的页面
        newPage:setName("Panel_Page"..pIdx)
        -- newPage:setBackGroundImage(data.chapterRes.Bg)
        newPage:setBackGroundImage("UI/UIstages_1/map_bg/stageselect_map_bg_"..pIdx..".jpg")
        -- 清空
        newPage:removeAllChildren()

        -- -- bg
        -- local Image_PageBg = self:addImageWidget( newPage,{
        --     name = "Image_PageBg"..pIdx,
        --     -- texture = data.chapterRes.Bg1
        --     texture = "UI/UIstages_1/map_bg/stageselect_map_bg_"..pIdx..".jpg"
        -- })

        -- bg1
        self:createUINode("ImageView",{
            name = "Image_Page"..pIdx,
            achorpoint = ccp(0,0),
            -- texture = data.chapterRes.Bg1
            texture = "UI/UIstages_1/map_bg/map"..pIdx..".png",
        }):addTo(newPage)

        -- 根据配置，创建出key
        for i = 1, #data.stages do
            local res = chapters:getStageRes(data.stages[i].stageResId)
            local pos = string.split(res.pos,",")

            -- 增加
            local ButtonUI = self:createUINode("Button",{
                name        = "PButton"..pIdx,
                tag         = data.stages[i].StageId,
                pos         = ccp(pos[1],pos[2]),
                scale       = res.scale/100,
                textures    = {res.normal,res.selected,res.disabled},
                touchEnable = true,
                TouchEvent  = function(widget, eventType)
                    if eventType == self.ccs.TouchEventType.ended then
                        self:openBattleWnd(stageType, widget:getTag() )
                    end
                end,
            })
            -- 需用这种方式，不然会有问题
            newPage:addChild(ButtonUI,res.ZOrder)

            -- local sequence = transition.sequence({ CCFadeIn:create(0.5) })
            -- transition.execute( btn,sequence)
        end
        return true
    end

    local cpCount = chapters:getChaptersCount()
    -- 添加新的页面
    for i=1,cpCount do
        local isClone = true
        if i == 1 then isClone = false end
        --添加新的页面
        self:addPage(pvWnd,i, i-1, isClone,createStage)
    end

    --设置默认
    -- self:setAllDefault()

    self:showHide(true)
end
------------------------------------------------------------------------------
function M:setAllDefault()

    -- 所有页面的按钮不可用
    self:getWidgetByName("PageView",function( pageView )
        for i = 1,pageView:getChildren():count() do
            self:getWidgetByName("Panel_Page"..i,function( pageWnd )
                if pageWnd == nil then return end

                local children = pageWnd:getChildren()
                local cnt = children:count()
                for i=0,cnt-1 do
                    local c = children:objectAtIndex(i)
                    c:setBright(false)
                    c:setTouchEnabled(false)
                end
            end)
        end -- end for
    end)
    -- 默认选中页点
    self:setSelected(1)
    -- 第一关默认可用
    self:setStageBtnEnable(1)
end
------------------------------------------------------------------------------
function M:setSelected( seclectPage )

    if self.lastSelectPage == nil then self.lastSelectPage = 1 end

    -- print("···",self.lastSelectPage,seclectPage)
    self:getWidgetByName("stageselect_chapter"..self.lastSelectPage,function( Widget )
        if Widget then Widget:setSelectedState(false) end
    end)

    self:getWidgetByName("stageselect_chapter"..seclectPage,function( Widget )
        if Widget == nil then return end
        --设置为可用
        Widget:setSelectedState(true)
        self.lastSelectPage = seclectPage

        -- 标签
        self:getWidgetByName("map-tiltle-image",function( Widget )
            if Widget == nil then return end
            Widget:loadTexture("UI/UIstages_1/maptitle_chapter/maptitle-chapter"..seclectPage..".png")
        end)
    end)
end
------------------------------------------------------------------------------
function M:setStageBtnEnable(index)
    self:getWidgetByName("PButton"..index,function ( Widget )
        if Widget == nil then return end
        Widget:setBright(true)
        Widget:setTouchEnabled(true)
    end)
end
------------------------------------------------------------------------------
function M:showHide(isShow)
    -- 隐藏控件
    self:getWidgetByName("Panel_Title",function( Widget )
        if Widget == nil then return end
        Widget:setEnabled(isShow)
    end)
    self:getWidgetByName("stageselect_chapter1",function( Widget )
        if Widget == nil then return end
        Widget:setEnabled(isShow)
    end)

    self:getWidgetByName("Panel_startBg",function( Widget )
        if Widget == nil then return end
        Widget:setEnabled(not isShow)
    end)
end
------------------------------------------------------------------------------
function M:openBattleWnd( stageType,stageId )

    local chapters = config:getConfig("stages")
    local data = chapters:getStage(stageId)

    -- 敌方武将
    local monsters = chapters:getMonstersByStageId( stageId )
    -- 主将
    local MasterId = chapters:getMasterByStageId( stageId )

    -- 隐藏控件
    self:showHide(false)

    -- 返回按钮
    self:getWidgetByName("startBg_back",function(Widget)
        Widget:addTouchEventListener(function( widget, eventType )
            if eventType == self.ccs.TouchEventType.ended then
                self:showHide(true)
            end
        end)
    end)

    -- 开始按钮
    self:getWidgetByName("Button_start",function(Widget)
        Widget:addTouchEventListener(function( widget, eventType )
            if eventType == self.ccs.TouchEventType.ended then
                -- display.replaceScene( INIT_FUNCTION.reloadModule("app.scenes.battle.battleScene").new(stageId))
                switchscene("battle",{ tempdata=stageId,transitionType = "crossFade", time = 0.5})
            end
        end)
    end)

    -- 标题文字
    self:getWidgetByName("Labe_stagetitle",function(Widget)
        Widget:setFontName(self:getFont())
        Widget:setText(data.Name)
    end)

    -- 描述头像
    self:getWidgetByName("Image_stageDes",function(Widget)
        local ha =  config:getConfig("heros"):GetHerosArtById(MasterId)
        Widget:loadTexture(ha.headIcon)
    end)

    -- 描述
    self:getWidgetByName("Label_stageDes",function(Widget)
        Widget:setFontName(self:getFont())
        Widget:setText(data.Desc)
    end)

    -- 消耗
    self:getWidgetByName("Labe_junlingxiaohao",function(Widget)
        Widget:setFontName(self:getFont())
        local deplete = chapters:getDepleteByStageId(stageId)
        Widget:setText(deplete.JunJing)
    end)

    -- 今日次数
    self:getWidgetByName("Labe_jinrixishu",function(Widget)
        Widget:setFontName(self:getFont())
        Widget:setText(data.Count.."/"..data.Count)
    end)

    -- 地方阵形
    self:getWidgetByName("Image_formation",function(Widget)
        Widget:setVisible(true)
        local Fid = chapters:getFormationByStageId( stageId )
        Widget:loadTexture("UI/FormationUi_1/fomation/"..Fid..".png")
    end)

    -- 敌方武将
    local count = 0
    for i=1,#monsters do
        local monster = monsters[i]
        if monster.isMaster == 1 then
            self:getWidgetByName("Image_hero5",function(Widget)
                Widget:setVisible(true)
                local ha =  config:getConfig("heros"):GetHerosArtById(monster.HeorId)
                Widget:loadTexture(ha.headIcon)
            end)
        else
            count = count+1
            self:getWidgetByName("Image_hero"..count,function(Widget)
                Widget:setVisible(true)
                local ha =  config:getConfig("heros"):GetHerosArtById(monster.HeorId)
                Widget:loadTexture(ha.headIcon)
            end)
        end
    end

    -- -- 掉落
    -- self:getWidgetByName("Image_drop1",function(Widget)
    --     -- Widget:setVisible(true)
    --     -- Widget:loadTexture(ha.headIcon)
    -- end)

end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------