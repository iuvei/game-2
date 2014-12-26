--
-- Author: wangshaopei
-- Date: 2014-10-13 10:40:48
--
local UIButtonCtrl = class("UIButtonCtrl")
function UIButtonCtrl:ctor(btnCtrl,options)
    self.ctrl_=btnCtrl
    if #self:GetCtrl():getChildren()>0 then
        self.lable=self:GetCtrl():getChildren()[1]
        if self.lable then
            btnCtrl:setTitleText("")
        end
    end


    -- local custom_widget = Label:create()
    --custom_widget:setTextVerticalAlignment(kCCTextAlignmentCenter)
    --custom_widget:setTextHorizontalAlignment(kCCVerticalTextAlignmentCenter)
    --custom_widget:setTextAreaSize(btnCtrl:getContentSize())
    --custom_widget:setSize(btnCtrl:getContentSize())
    -- custom_widget:setFontName(btnCtrl:getTitleFontName())
    -- custom_widget:setFontSize(22)
    -- custom_widget:setColor(btnCtrl:getTitleColor())
    -- custom_widget:setText(options.text)
    -- btnCtrl:addChild(custom_widget)


end
function UIButtonCtrl:GetCtrl()
    return self.ctrl_
end
function UIButtonCtrl:SetText(text)
    --local lable=self:GetCtrl():getChildByName("LabelTitle")
    if self.lable then
        self.lable:setText(text)
    end
end
function UIButtonCtrl:SetDisable(b)
    self:GetCtrl():setBright(not b)
    self:GetCtrl():setTouchEnabled(not b)
    --self:GetCtrl():setEnabled(not b)
    if self.lable then
        if not b then
            self.lable:setColor(display.COLOR_WHITE)
        else
            self.lable:setColor(ccc3(128,128,128))
        end
    else
        if not b then
            self:GetCtrl():setTitleColor(display.COLOR_WHITE)
        else
            self:GetCtrl():setTitleColor(ccc3(128,128,128))
        end
    end
end
return UIButtonCtrl
