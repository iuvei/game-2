--
-- Author: wangshaopei
-- Date: 2014-10-17 17:40:13
--
------------------------------------------------------------------------------
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIHeroSkillUp  = class("UIHeroSkillUp", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIHeroSkillUp.DialogID=uiLayerDef.ID_HeroSkillUp
------------------------------------------------------------------------------
function UIHeroSkillUp:ctor(UIManager)
    UIHeroSkillUp.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function UIHeroSkillUp:onExit( )
    UIHeroSkillUp.super.onExit(self)
end
function UIHeroSkillUp:onEnter()
    UIHeroSkillUp.super.onEnter(self)
end
function UIHeroSkillUp:init( params )
    UIHeroSkillUp.super.init(self,params)
    --self.heroinfo = PLAYER:get_mgr("heros"):get_hero_by_GUID(params.GUID)
    --self:ListenClose()
    self._skillInfo=configMgr:getConfig("skills"):GetSkillData(params.params.skillId)
    self:Listen()
    local file = configMgr:getConfig("skills"):GetSkillIcon(params.params.skillId).file
    self:Updata({sikllBrief=self._skillInfo.sikllBrief,
        lev=self._skillInfo.lev,
        name=self._skillInfo.nickname,
        iconFile=file})
end
function UIHeroSkillUp:Listen()
    -- body
end
function UIHeroSkillUp:Updata(option)
    local name=self:getWidgetByName("skillName")
    if option.name ~=nil then
        name:setText(option.name)
    end
    local lev=self:getWidgetByName("skillLev")
    if option.lev ~=nil then
        lev:setText(string.format("lv.%d",option.lev))
    end
    local ctrl=self:getWidgetByName("skillLev_1_2")
    if option.sikllBrief ~=nil then
        ctrl:setText(option.sikllBrief)
    end
    local ctrl=self:getWidgetByName("ImgLev")
    if option.iconFile ~=nil then
        ctrl:loadTexture(option.iconFile)
    end

end
------------------------------------------------------------------------------
return UIHeroSkillUp
------------------------------------------------------------------------------