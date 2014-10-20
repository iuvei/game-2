--
-- Author: wangshaopei
-- Date: 2014-10-09 10:19:31
--
------------------------------------------------------------------------------
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
------------------------------------------------------------------------------
local UIHeroInfo  = class("UIHeroInfo", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIHeroInfo.DialogID=uiLayerDef.ID_HeroInfo
------------------------------------------------------------------------------
function UIHeroInfo:ctor(UIManager)
    UIHeroInfo.super.ctor(self,UIManager)
    self._curShowDlg=nil
end
------------------------------------------------------------------------------
-- 退出
function UIHeroInfo:onExit( )
    UIHeroInfo.super.onExit(self)
end
function UIHeroInfo:onEnter()
    UIHeroInfo.super.onEnter(self)
end
function UIHeroInfo:init( ccsFileName, params )
    self.heroinfo = CLIENT_PLAYER:get_mgr_heros():get_hero_by_GUID(params.GUID)
    UIHeroInfo.super.init(self,ccsFileName)
    self:ListenClose()
    self:ListenHero()
    self:UpdataHero()
end
----------------------------------------------------------------------------------------
--hero
function UIHeroInfo:ListenHero()
    self:getWidgetByName("Panel_bg",function ( ctrlPlanel )
        self.rootHero=ctrlPlanel:getChildByName("Hero")
        self.rootHeroSkill=ctrlPlanel:getChildByName("HeroSkill")
        self.rootHeroArr=ctrlPlanel:getChildByName("HeroArr")
        self.rootHeroSoldierInfo=ctrlPlanel:getChildByName("HeroSoldierKind")
        self.rootHeroEquip=ctrlPlanel:getChildByName("HeroEquip")
        --
        self.rootHeroSkill:setEnabled(false)
        self.rootHeroArr:setEnabled(false)
        self.rootHeroSoldierInfo:setEnabled(false)
        self.rootHeroEquip:setEnabled(false)
        --
        local origin = ccp(self.rootHero:getPositionX(),self.rootHero:getPositionY())
        self.rootHeroSkill:setPosition(origin)
        self.rootHeroArr:setPosition(origin)
        self.rootHeroSoldierInfo:setPosition(origin)
        self.rootHeroEquip:setPosition(origin)
        --
        self:InitHeroSkill()
        --
        self:ShowDlg("Skill")
        end)
    local btn=self.rootHero:getChildByName("BtnEquip")
    btn:addTouchEventListener(function(sender, eventType)
                                if eventType == self.ccs.TouchEventType.ended then
                                self:ShowDlg("Equip",true)
                                end
                            end)
    btn=self.rootHero:getChildByName("ButSkill")
    btn:addTouchEventListener(function(sender, eventType)
                                if eventType == self.ccs.TouchEventType.ended then
                                    self:ShowDlg("Skill",true)
                                end
                            end)
    btn=self.rootHero:getChildByName("ButSoldierKind")
    btn:addTouchEventListener(function(sender, eventType)
                                if eventType == self.ccs.TouchEventType.ended then
                                    self:ShowDlg("SoldierKind",true)
                                end
                            end)
    btn=self.rootHero:getChildByName("ButAtt")
    btn:addTouchEventListener(function(sender, eventType)
                                if eventType == self.ccs.TouchEventType.ended then
                                    self:ShowDlg("Att",true)
                                end
                            end)
end
function UIHeroInfo:ShowDlg(type,isFade)
    if self.isFading then
        return
    end
    --按钮
    local btnSkill=UIButtonCtrl.new(self.rootHero:getChildByName("ButSkill"))
    local btnEquip=UIButtonCtrl.new(self.rootHero:getChildByName("BtnEquip"))
    local btnSolder=UIButtonCtrl.new(self.rootHero:getChildByName("ButSoldierKind"))
    local btnAtt=UIButtonCtrl.new(self.rootHero:getChildByName("ButAtt"))
    btnSkill:SetDisable(false)
    btnEquip:SetDisable(false)
    btnSolder:SetDisable(false)
    btnAtt:SetDisable(false)
    --界面
    -- self.rootHeroSkill:setEnabled(false)
    -- self.rootHeroArr:setEnabled(false)
    --位置
    local origin = ccp(self.rootHero:getBoundingBox():getMinX(),self.rootHero:getBoundingBox():getMaxY())
    -- self.rootHeroSkill:setPosition(origin)
    -- self.rootHeroArr:setPosition(origin)
    local curDlg = self._curShowDlg
    if curDlg then
        if isFade then
            transition.execute(curDlg, CCMoveTo:create(0.5, origin), {
            easing = "exponentialOut",
            onComplete = function()
                curDlg:setEnabled(false)
            end,})
        else
            curDlg:setPosition(origin)
        end
    end
    if type=="Equip" then
        btnEquip:SetDisable(true)
        self.rootHeroEquip:setEnabled(true)
        self.rootHeroEquip:setVisible(true)
        self._curShowDlg=self.rootHeroEquip
        self:UpdataHeroEquip()
    elseif type == "Skill" then
        btnSkill:SetDisable(true)
        self.rootHeroSkill:setEnabled(true)
        self.rootHeroSkill:setVisible(true)
        self._curShowDlg=self.rootHeroSkill
        self:UpdataHeroSkill()
    elseif type=="SoldierKind" then
        btnSolder:SetDisable(true)
        self.rootHeroSoldierInfo:setEnabled(true)
        self.rootHeroSoldierInfo:setVisible(true)
        self:UpdataHeroSoldier()
        self._curShowDlg=self.rootHeroSoldierInfo
    elseif type=="Att" then
        btnAtt:SetDisable(true)
        self.rootHeroArr:setEnabled(true)
        self.rootHeroArr:setVisible(true)
        self:UpdataHeroArr({con=self.heroinfo.Desc})
        self._curShowDlg=self.rootHeroArr
    end
    if not self._curShowDlg then
        return
    end
    local tar = ccp(self.rootHero:getPositionX()+self.rootHero:getSize().width/2+self._curShowDlg:getSize().width/2,
        self._curShowDlg:getPositionY())

    if isFade then
        self.isFading=true
        transition.execute(self._curShowDlg, CCMoveTo:create(0.5, tar), {
            easing = "exponentialOut",
            onComplete = function()
                self.isFading=false
            end,
        })
    else
        self._curShowDlg:setPosition(tar)
    end

end
function UIHeroInfo:ListenClose()
    self:getWidgetByName("Panel_bg",function ( layout )
                        local wg = layout:getChildByName("close")
                            wg:addTouchEventListener(function(sender, eventType)
                                    local ccs = self.ccs
                                    if eventType == ccs.TouchEventType.ended then
                                        self:getUIManager():close(self)
                                    end
                                end)
                        end)
end
function UIHeroInfo:UpdataHero(options)
    local root = self.rootHero
    --名称
    local w = UIHelper:seekWidgetByName(root, "name")
    w:setText(self.heroinfo.nickname)
    --国家
    w=UIHelper:seekWidgetByName(root, "country")
    w:setText(self.heroinfo.countryInfo.name)
    --头像
    w = tolua.cast(UIHelper:seekWidgetByName(root, "Image_head"),"ImageView")
    w:loadTexture(self.heroinfo.headIcon)
    --星级数量
    UIUtil:SetStars(UIHelper:seekWidgetByName(root, "Panel_31"),self.heroinfo.stars)
end
----------------------------------------------------------------------------------------
--英雄技能相关
--初始化
function UIHeroInfo:InitHeroSkill()
    if not self._listSkillTypes then self._listSkillTypes={} end
    local root = self.rootHeroSkill
    local lstCtrlSkillTypes = UIListView.new(UIHelper:seekWidgetByName(root, "ScrollViewSkillListList"))
    local pnlCtrlSkillTypeItem = UIHelper:seekWidgetByName(root, "PanelSkillType")
    pnlCtrlSkillTypeItem:setEnabled(false)
    pnlCtrlSkillTypeItem:setVisible(false)
    for i=1,#self.heroinfo.skills do
        local s=self.heroinfo.skills[i]
        --数据
        local skillId = s.templateId+s.level
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
        local skillIcon = configMgr:getConfig("skills"):GetSkillIcon(skillId)
        --控件
        local skillTypeItem=self:AddSkillTypeItem(i,lstCtrlSkillTypes,pnlCtrlSkillTypeItem)
        local img=UIHelper:seekWidgetByName(skillTypeItem,"Image")
        local lab=UIHelper:seekWidgetByName(skillTypeItem,"Label_92")
        local labLev=UIHelper:seekWidgetByName(skillTypeItem,"LabelLev")
        img:loadTexture(skillIcon.file)
        img:addTouchEventListener(function(sender, eventType)
                                    local ccs = self.ccs
                                    if eventType == ccs.TouchEventType.ended then
                                        self:getUIManager():openUI({uiScript=require("app.ui.home.UIHeroSkillUp"),
                                            ccsFileName="UI/hero_skillup.json",
                                                params={skillId=skillId}})
                                    end
                                end)
        lab:setText(skillTemp.nickname)
        labLev:setText(string.format("lv.%d",skillIns.lev))
        self._listSkillTypes[i]={dlg=skillTypeItem}
    end

end
--反初始化
function UIHeroInfo:UnInitHeroSkill()
    -- body
end
--更新数据
function UIHeroInfo:UpdataHeroSkill()

end
function UIHeroInfo:AddSkillTypeItem(index,listCtrl,tplItem)
    local item=tplItem
    if index>1 then
        item = tplItem:clone()    -- 拷贝C++数据
        listCtrl:insert(item)
    else
        item:setEnabled(true)
        item:setVisible(true)
    end

    return item
end
----------------------------------------------------------------------------------------
--英雄属性界面相关
function UIHeroInfo:UpdataHeroArr(options)
    if options.con then
        local ctrl=UIHelper:seekWidgetByName(self.rootHeroArr, "LabelCon")
        ctrl:setText(options.con)
    end
end
----------------------------------------------------------------------------------------
--兵种界面相关
function UIHeroInfo:UpdataHeroSoldier()
    -- body
end
----------------------------------------------------------------------------------------
--英雄装备相关
function UIHeroInfo:UpdataHeroEquip()
    -- body
end
------------------------------------------------------------------------------
return UIHeroInfo
------------------------------------------------------------------------------