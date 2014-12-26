--
-- Author: wangshaopei
-- Date: 2014-12-10 11:30:20
--
--
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local item_operator = require("app.mediator.item.item_operator")
local UIListView = require("app.ac.ui.UIListViewCtrl")
------------------------------------------------------------------------------
local UIBattleResult  = class("UIBattleResult", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIBattleResult.DialogID=uiLayerDef.ID_BattleResult
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIBattleResult:ctor(UIManager)
    UIBattleResult.super.ctor(self,UIManager)
    self._lst_ctrl=nil
end
------------------------------------------------------------------------------
-- 退出
function UIBattleResult:onExit( )
    UIBattleResult.super.onExit(self)
end
function UIBattleResult:onEnter()
    UIBattleResult.super.onEnter(self)
end
function UIBattleResult:init( params )
    UIBattleResult.super.init(self,params)
    self._args = params.args
    self:Listen()
    self:UpdataData()
end
function UIBattleResult:Listen()

    local go_main=UIHelper:seekWidgetByName(self._root_widget,"ButtonGoMain")
    go_main:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            switchscene("home",{transitionType = "crossFade", time = 0.5})
                                    end
                                end)
    local go_next=UIHelper:seekWidgetByName(self._root_widget,"ButtonGoNext")
    go_next:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then

                                    end
                                end)

end
function UIBattleResult:UpdataData()
    -- local award = {}
    -- print(count,"..begin - >",args.stageId,args.stars)
    -- for i=1,#args.award do
    --  print(args.award[i].dataId,args.award[i].num)
    --  -- award[i] = {dataId=args.award[i].dataId}
    -- end
    local  result = self:getWidgetByName_(self._root_widget,"LabelResult")
    local starTemp =  self:getWidgetByName_(self._root_widget,"PanelStar")
    starTemp:setEnabled(false)

    if self._args.stars > 0 then -- 胜利
        result:setText("战斗胜利")
        for i=1,3 do
            local star_ = nil
            if i == 1 then
                star_ = starTemp
            else
                star_ = starTemp:clone()
                star_:setPosition(cc.p(starTemp:getPositionX()+(i-1)*starTemp:getContentSize().width,starTemp:getPositionY()))
                starTemp:getParent():addChild(star_)
            end
            star_:setEnabled(true)
            if self._args.stars < i then
                star_:getChildByName("ImageStar"):setEnabled(false)
                -- self:getWidgetByName_(star_,"ImageStar"):setVisible(false)
            end

        end
        local conf_stage = configMgr:getConfig("stages"):getStage(self._args.stageId)
        --
        local lev=self:getWidgetByName("LabelLev")
        -- print("···",PLAYER:get_basedata().level,conf_stage.award_exp,conf_stage)

        lev:setText(string.format("Lev:%d Exp:+%d",PLAYER:get_basedata().level,conf_stage.a_exp))
        --
        self:getWidgetByName("LabelVal1"):setText("+"..conf_stage.a_money)
        -- 物品
        self._lst_ctrl = UIListView.new(UIHelper:seekWidgetByName(self._root_widget, "ScrollView"))
        self._lst_ctrl:InitialItem()

        for i=1,#self._args.award do
            --
            local item=self._lst_ctrl:AddItem(i)
            --
            local conf_data=item_operator:get_conf_mgr(self._args.award[i].dataId)
            local icon = conf_data:get_icon(self._args.award[i].dataId)
            self:getWidgetByName_(item,"LabelName"):setText(conf_data:get_info(self._args.award[i].dataId).name)
            self:getWidgetByName_(item,"Item"):loadTexture(icon)
           --self._args.award[i].num
        end

    else -- 失败
        result:setText("战斗失败")
    end

end

function UIBattleResult:ProcessNetResult(params)
    -- if params.msg_type == "C_UpdataHeroInfo"
    --     then
    --         self:UpdataData()
    -- end
end
------------------------------------------------------------------------------
return UIBattleResult
------------------------------------------------------------------------------