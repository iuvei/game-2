--
-- Author: wangshaopei
-- Date: 2014-10-16 11:17:59
--
local UIUtil = {}
function UIUtil:SetStars(wgStars,num)
    for i=1,5 do
        local star=wgStars:getChildByName("star_"..i)
        if num>=i then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end
end
return UIUtil