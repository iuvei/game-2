--
-- Author: wangshaopei
-- Date: 2014-09-22 10:19:40
--
local MapConstants    = require("app.ac.MapConstants")
local configMgr       = require("config.configMgr")         -- 配置
------------------------------------------------------------------------------
local HomeBuildView = class("HomeBuildView", require("app.character.views.ObjectView"))
HomeBuildView.ResType_MainImg=1
HomeBuildView.ResType_TitleBg=2
HomeBuildView.ResType_Title=3
HomeBuildView.ResType_LightBg=4
------------------------------------------------------------------------------
function HomeBuildView:ctor(model,params)
    -- 允许显示对象的事件
    self.super.ctor(self,model,params)
    self.elements_={}
    self:init(model,params)
end
------------------------------------------------------------------------------
function HomeBuildView:init(model,params)
    self:GetModel():getScene():getBuildsLayer():addChild(self)
    -- 生成sprite
    local datas = self:GetModel():getDatas()
    for k,data in pairs(datas) do
        local rect=configMgr:getConfig("home"):toRect(data.rect)
        if data.resType == 1 then
            self:setPosition(cc.p(rect.x,rect.y))
            break
        end
    end
    local x,y = self:getPosition()
    for k,data in pairs(datas) do
        local rect=configMgr:getConfig("home"):toRect(data.rect)
        if data.resType == HomeBuildView.ResType_MainImg then
            self.elements_[data.resType]=display.newSprite(data.normal,x,y)
            if data.selected then
                self.elements_[HomeBuildView.ResType_LightBg]=display.newSprite(data.selected,x,y)
                :addTo(self:GetModel():getScene():getBuildsLayer(), data.ZOrder)
                self.elements_[HomeBuildView.ResType_LightBg]:setVisible(false)
            end
        elseif data.resType==HomeBuildView.ResType_Title then
            self.elements_[data.resType]=cc.ui.UILabel.newTTFLabel_({
                            text = self:GetModel():getName(),
                            size = 20,
                            color = display.COLOR_GREEN,
                            align = ui.TEXT_ALIGN_CENTER,
                            valign = ui.TEXT_VALIGN_CENTER,
                            dimensions = CCSize(164, 47)
                        })
                        :pos(rect.x,rect.y)
                       -- :addTo(self:GetModel():getScene():getBuildsLayer())
        elseif data.resType==HomeBuildView.ResType_TitleBg then
            self.elements_[data.resType] = display.newSprite(data.normal,x+rect.x,y+rect.y)
        end
        if data.resType==HomeBuildView.ResType_Title then
            self.elements_[HomeBuildView.ResType_TitleBg]:addChild(self.elements_[data.resType],data.ZOrder)
        else
            self:GetModel():getScene():getBuildsLayer():addChild(self.elements_[data.resType],data.ZOrder)
        end
    end

    --self:GetBatch():addChild(self.sprite_,MapConstants.MAX_OBJECT_ZORDER)
    -- 设置坐标
    --local pt = self:GetModel():getVaildTouchRect().origin
    --self:setPosition(cc.p(pt.x,pt.y))
    --self:updateView()
    return true
end
function HomeBuildView:touchDown()
    local p = self.elements_[HomeBuildView.ResType_LightBg]
    if not p then
        return
    end
    p:setVisible(true)
end
function HomeBuildView:touchUp()
    local p = self.elements_[HomeBuildView.ResType_LightBg]
    if not p then
        return
    end
    p:setVisible(false)
end
------------------------------------------------------------------------------
-- 退出
function HomeBuildView:onExit()
    self.super.onExit(self)
end
------------------------------------------------------------------------------
--
function HomeBuildView:onEnter()
    self.super.onEnter(self)
end
------------------------------------------------------------------------------
function HomeBuildView:contains(worldPos)
    local s = self.elements_[HomeBuildView.ResType_MainImg]

    -- print("HomeBuildView",s:getBoundingBox():getMidX(),s:getBoundingBox():getMidY(),s:getBoundingBox():getMaxX()
    --     ,s:getBoundingBox():getMaxY(),
    --     self:GetModel():getName())
    local rc = self.elements_[HomeBuildView.ResType_TitleBg]:getBoundingBox()
    if cc.rectContainsPoint(rc,worldPos) then
        return true
    end
    rc = self.elements_[HomeBuildView.ResType_MainImg]:getBoundingBox()
    if cc.rectContainsPoint(rc,worldPos) then
        return true
    end
    -- elseif self:GetModel():contains(worldPos) then
    --         return true
    return false
end
------------------------------------------------------------------------------
-- 得到model
function HomeBuildView:GetModel()
    return self.model_
end
------------------------------------------------------------------------------
-- 得到批量渲染
function HomeBuildView:GetBatch(classId)
    -- local model = self:GetModel()
    -- if classId == nil or classId == ""  then
    --     classId = model:getClassId()
    -- end

    -- return model:getMap():GetBatch(classId)
end
------------------------------------------------------------------------------
-- 更新
function HomeBuildView:updateView()
    local sprite = self.sprite_
    sprite:setPosition(cc.p(self:getPosition()))
end
------------------------------------------------------------------------------
return HomeBuildView
------------------------------------------------------------------------------