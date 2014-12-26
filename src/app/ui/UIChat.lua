--
-- Author: wangshaopei
-- Date: 2014-12-11 14:29:57
--
local UIButtonCtrl = require("app.ac.ui.UIButtonCtrl")
local UIUtil = require("app.ac.ui.UIUtil")
local configMgr = require("config.configMgr")
local StringData = require("config.zhString")
local item_operator = require("app.mediator.item.item_operator")
local UIListView = require("app.ac.ui.UIListViewCtrl")
------------------------------------------------------------------------------
local UIChat  = class("UIChat", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIChat.DialogID=uiLayerDef.ID_Chat
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function UIChat:ctor(UIManager)
    UIChat.super.ctor(self,UIManager)
    self._lst_ctrl=nil
end
------------------------------------------------------------------------------
-- 退出
function UIChat:onExit( )
    UIChat.super.onExit(self)
end
function UIChat:onEnter()
    UIChat.super.onEnter(self)
end
function UIChat:init( params )
    UIChat.super.init(self,params)
    self._args = params.args
    self._is_open=true
    self._editbox = nil
    self._lst_ctrl = UIListView.new(UIHelper:seekWidgetByName(self._root_widget, "ScrollView"))
    self._lst_ctrl:InitialItem()
    self._content={}
    self:Listen()
    self:UpdataData()
    self:Activate()

end
function UIChat:Listen()
    local open=UIHelper:seekWidgetByName(self._root_widget,"ButtonOpen")
    open:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            self:Activate()
                                    end
                                end)

    local send=UIHelper:seekWidgetByName(self._root_widget,"ButtonSend")
    send:addTouchEventListener(function(sender, eventType)
                                        if eventType == self.ccs.TouchEventType.ended then
                                            self:AddContent(self._editbox:getText())
                                            local s= self._editbox:getText()

                                            local arr = string.split(s," ")

                                            if arr[1] == "cmd" then
                                                -- if arr[2] == "createitem" then
                                                --     for i=3,#arr do
                                                --         PLAYER:send("CS_Command",{
                                                --             content = "createitem "..arr[i]
                                                --         })
                                                --     end
                                                -- end
                                                -- print("···",arr[1],arr[2],arr[3])
                                                PLAYER:send("CS_Command",{
                                                     content = arr[2].." "..arr[3]
                                                })
                                            end
                                    end
                                end)
    local bg=UIHelper:seekWidgetByName(self._root_widget,"ImageInputBg")
    bg:setEnabled(false)

    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            print("began")
        elseif event == "changed" then
            -- 输入框内容发生变化
            -- print("changed:"..editbox:getText())
        elseif event == "ended" then
            -- 输入结束
            print("ended")
        elseif event == "return" then
            -- 从输入框返回
            print("return")
        end
    end
    local editbox = ui.newEditBox({
        image = "UI/chat/chat_input_2.png",
        listener = onEdit,
        size = CCSize(499, 40)
    })
    self:GetTouchGroup():addChild(editbox,1)
    -- editbox:setPosition(cc.p(147,307))
    editbox:setFontName("Paint Boy" )
    editbox:setFontSize(28)
    editbox:setFontColor(display.COLOR_RED)
    editbox:setPlaceHolder("GM命令:cmd createitem 物品Id")
    editbox:setPlaceholderFontColor(display.COLOR_WHITE)
    editbox:setMaxLength(128)
    -- editbox:setReturnType(kKeyboardReturnTypeDone)
    self._editbox=editbox
-------
end
function UIChat:Activate()
    if self._is_open then
        self:setPosition(-self._root_widget:getContentSize().width+68, 0)
        self._editbox:setPosition(cc.p(291-self._root_widget:getContentSize().width+68,520))
        self._is_open=false
    else
        self:setPosition(0, 0)
        self._editbox:setPosition(cc.p(291,520))
        self._is_open=true
    end
end
function UIChat:AddContent(content)
    -- local count = self._lst_ctrl:getCount()
    local item = nil
    self._content[#self._content+1]=content
    if #self._content > 1 then
        item=self._lst_ctrl:AddItem(#self._content+1)
    else
        item=self._lst_ctrl:AddItem(1)
    end
    item:getChildByName("LabelContent"):setText(content)

end
function UIChat:UpdataData()
        -- self._lst_ctrl = UIListView.new(UIHelper:seekWidgetByName(self._root_widget, "ScrollView"))
        -- self._lst_ctrl:InitialItem()
end

function UIChat:ProcessNetResult(params)
    -- if params.msg_type == "C_UpdataHeroInfo"
    --     then
    --         self:UpdataData()
    -- end
end
------------------------------------------------------------------------------
return UIChat
------------------------------------------------------------------------------