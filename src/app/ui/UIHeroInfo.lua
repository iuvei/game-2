--
-- Author: wangshaopei
-- Date: 2014-10-09 10:19:31
--
local pairs = pairs
------------------------------------------------------------------------------
local UIListView = require("app.ac.ui.UIListViewCtrl")
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local item_operator = require("app.mediator.item.item_operator")
local item_helper = require("app.mediator.item.item_helper")
local hero_helper = require("app.mediator.hero.hero_helper")
------------------------------------------------------------------------------
local UIHeroInfo  = class("UIHeroInfo", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIHeroInfo.DialogID=uiLayerDef.ID_HeroInfo
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIHeroInfo:ctor(UIManager)
    UIHeroInfo.super.ctor(self,UIManager)
    self._cur_show_dlg=nil
    self._equip_solts={}
end
------------------------------------------------------------------------------
-- 退出
function UIHeroInfo:onExit( )
    UIHeroInfo.super.onExit(self)
end
function UIHeroInfo:onEnter()
    UIHeroInfo.super.onEnter(self)
end
function UIHeroInfo:init( params )
    self.heroinfo = PLAYER:get_mgr("heros"):get_hero_by_GUID(params.params.GUID)
    UIHeroInfo.super.init(self,params)

    --self:ListenClose()
    self:ListenHero()

    self:ListenEquip()
    self:UpdataHero()
    -- default show
    self:ShowDlg("Equip")
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
        local origin = cc.p(self.rootHero:getPositionX(),self.rootHero:getPositionY())
        self.rootHeroSkill:setPosition(origin)
        self.rootHeroArr:setPosition(origin)
        self.rootHeroSoldierInfo:setPosition(origin)
        self.rootHeroEquip:setPosition(origin)
        --
        self:InitHeroSkill()
        --

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
    local origin = cc.p(cc.rectGetMinX(self.rootHero:getBoundingBox()),cc.rectGetMinY(self.rootHero:getBoundingBox()))
    -- self.rootHeroSkill:setPosition(origin)
    -- self.rootHeroArr:setPosition(origin)
    local curDlg = self._cur_show_dlg
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
        self._cur_show_dlg=self.rootHeroEquip
        self:UpdataHeroEquip()
    elseif type == "Skill" then
        btnSkill:SetDisable(true)
        self.rootHeroSkill:setEnabled(true)
        self.rootHeroSkill:setVisible(true)
        self._cur_show_dlg=self.rootHeroSkill
        self:UpdataHeroSkill()
    elseif type=="SoldierKind" then
        btnSolder:SetDisable(true)
        self.rootHeroSoldierInfo:setEnabled(true)
        self.rootHeroSoldierInfo:setVisible(true)
        self:UpdataHeroSoldier()
        self._cur_show_dlg=self.rootHeroSoldierInfo
    elseif type=="Att" then
        btnAtt:SetDisable(true)
        self.rootHeroArr:setEnabled(true)
        self.rootHeroArr:setVisible(true)
        self:UpdataHeroArr({con=self.heroinfo.Desc})
        self._cur_show_dlg=self.rootHeroArr
    end
    if not self._cur_show_dlg then
        return
    end
    local tar = cc.p(self.rootHero:getPositionX()+self.rootHero:getContentSize().width/2+self._cur_show_dlg:getContentSize().width/2,
        self._cur_show_dlg:getPositionY())

    if isFade then
        self.isFading=true
        transition.execute(self._cur_show_dlg, CCMoveTo:create(0.5, tar), {
            easing = "exponentialOut",
            onComplete = function()
                self.isFading=false
            end,
        })
    else
        self._cur_show_dlg:setPosition(tar)
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
    w = UIHelper:seekWidgetByName(root, "Image_head")
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
                                        self:getUIManager():openUI({uiScript=require("app.ui.UIHeroSkillUp"),
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
function UIHeroInfo:InitEquip()

end
function UIHeroInfo:ListenEquip()
    --for i=0,self.rootHeroEquip:getChildrenCount()-1 do
    for i=1,6 do
        local slot = self.rootHeroEquip:getChildByName("EquipBg_"..i)
        slot:getChildByName("sign"):setVisible(false)
        slot.state = 0 -- 0 ＝ 无可穿装备，1 ＝ 可穿装备，2 ＝ 已装备
        slot.equip_pos = i
        self._equip_solts[i]=slot

        slot:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                            self:openUI({
                                                        uiScript=require("app.ui.UIEquipUse"),
                                                        ccsFileName="UI/equip_use.json",
                                                        params={state=slot.state,equip_slot=slot,hero_guid=self.heroinfo.GUID}
                                                    })

                                    end
                                end)
    end
    local btn = self.rootHeroEquip:getChildByName("BtnStre")
    btn:addTouchEventListener(function(sender, eventType)
                                    if eventType == self.ccs.TouchEventType.ended then
                                            self:openUI({
                                                        uiScript=require("app.ui.UIEquipMake"),
                                                        ccsFileName="UI/equip_make.json",
                                                        params={hero_info=self.heroinfo}
                                                    })

                                    end
                                end)
end
function UIHeroInfo:UpdataHeroEquip()

    -- 已装备的道具
    self.heroinfo = PLAYER:get_mgr("heros"):get_hero_by_GUID(self.heroinfo.GUID)

    local function get_equip( equips, point )
        for k,v in ipairs(equips) do
            if point == item_helper.get_serial_type(v.dataId) then
                return v
            end
        end
    end

    for k,v in ipairs(self._equip_solts ) do
        v:getChildByName("sign"):setVisible(false)
        -- 0 ＝ 无可穿装备，1 ＝ 可穿装备，2 ＝ 已装备
        local equip_info = get_equip( self.heroinfo.equips, k )
        if v.state == 0 or v.state == 1 then
            if equip_info then -- 已有装备
                equip_info = item_operator:get_equip_info( equip_info )
                v.equip_info = equip_info--equip_info
                v.state = 2
                local s=self:createUINode("ImageView",{
                        name    = "EquipImg"..k,
                        texture = equip_info.icon,
                        pos     = cc.p(0,0),
                    }):addTo(v)

            else
                -- 默认显示图片
                local equip_id = hero_helper:getconf_require_equip( self.heroinfo.dataId )[k]
                equip_info = item_operator:get_equip_info({dataId = equip_id,GUID = equip_id,num = 0})
                v.equip_info = equip_info
                v.state = 0

               self:createUINode("ImageView",{
                        name    = "EquipImg"..k,
                        texture = equip_info.icon,
                        pos     = cc.p(0,0),
                }):addTo(v):setColor(ccc3(299, 587, 114))

                -- 检测是否有可以穿戴的装备
                equip_info = self:GetCanUseEquipByPos(v.equip_pos)
                if equip_info then -- can use
                    v.equip_info = equip_info
                    v.state = 1
                    v:getChildByName("sign"):setVisible(true)
                end

                -- 检测是否可合成则可穿戴
                -- TODO
            end
        -- 如果已是装备状态就更新
        elseif v.state == 2 then
            local equip_img = v:getChildByName("EquipImg"..k)
            if equip_img and equip_info then
                equip_info = item_operator:get_equip_info( equip_info )
                equip_img:loadTexture(equip_info.icon)
            end
        end
    end
end
function UIHeroInfo:GetCanUseEquipByPos(equip_pos)

    local data_ = PLAYER:get_mgr("equip"):get_data()
    for k,v in pairs(data_) do
        local info=v:get_info()
        if info.equip_point == equip_pos and hero_helper:check_require_equip( self.heroinfo.dataId, info.dataId ) then
            return info
        end
    end
    return nil
end
function UIHeroInfo:ProcessNetResult(params)
    if params.msg_type == "SC_UseItem"
        or params.msg_type == "SC_Compound"
        or params.msg_type == "SC_EquipEnhance"
        then
        if params.args.result ~= 0 then
            self:ListenEquip()
            self:UpdataHeroEquip()
        end
    end
end
------------------------------------------------------------------------------
return UIHeroInfo
------------------------------------------------------------------------------