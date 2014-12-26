--
-- Author: wangshaopei
-- Date: 2014-10-20 12:11:30
--

local RichLabel = require("app.ac.ui.RichLabel")
local RichLabelCtrl = class("RichLabelCtrl")
function RichLabelCtrl:ctor(label,options)
    --创建方法
    --[[
        local options = {
            fontName = "Arial",
            fontSize = 30,
            fontColor = ccc3(255, 0, 0),
            dimensions = CCSize(300, 200),
            text = [fontColor=f75d85 fontSize=20 fontName=ArialRoundedMTBold]hello world[/fontColor][image=wsk1.png scale=1.3][/image],
        }

        text 目前支持参数
                文字
                fontName  : font name
                fontSize  : number
                fontColor : 十六进制

                图片
                image : "xxx.png"
                scale : number
    ]]--
    self.ctrl_=label
    label:setText("")
    local curWidth = label:getContentSize().width
    local curHeight = label:getContentSize().height

    options.dimensions = CCSize(curWidth, curHeight)
    options.fontSize=label:getFontSize()
    options.fontName=options.fontName or label:getFontName()

    local testLabel = RichLabel:create(options)
    --local  s=testLabel:getLabelSize()
    label:getVirtualRenderer():addChild(testLabel)

end
function RichLabelCtrl:GetCtrl()
    return self.ctrl_
end
return RichLabelCtrl