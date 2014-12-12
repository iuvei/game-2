--
-- Author: wangshaopei
-- Date: 2014-09-18 17:58:40
--

local configMgr       = require("config.configMgr")         -- 配置
----------------------------------------------
local HomeBuild = class("HomeBuild")
----------------------------------------------
function HomeBuild:ctor(buildId,scene)
    self.buildId_=buildId
    self.scene_=scene

     local buildData = configMgr:getConfig("home"):getHomeBuild(buildId)
    -- local buildRes = configMgr:getConfig("home"):getHomeBuildRes(buildId)
    -- self.rect_=configMgr:getConfig("home"):toRect(buildRes.rect)
    self.name_=buildData.name
    -- self.resTitleId_=
    self.datas_=configMgr:getConfig("home"):getHomeRes(buildId)
    self.info_=buildData
end
function HomeBuild:contains(worldPos)
    if self.rect_:containsPoint(worldPos) then
        return true
    end
    return false
end
function HomeBuild:getDatas()
    return self.datas_
end
function HomeBuild:getVaildTouchRect()
    return self.rect_
end
function HomeBuild:selected()
    --self:getView():selected()
end
function HomeBuild:setScale(scale)
end
function HomeBuild:setEnable(bEnable)
    -- body
end
function HomeBuild:getBuildId()
    return self.buildId_
end
function HomeBuild:getScene()
    return self.scene_
end
function HomeBuild:getName()
    return self.name_
end
function HomeBuild:setView(view)
    self.view_=view
end
function HomeBuild:getView()
    return self.view_
end
function HomeBuild:removeView()
    -- body
end
----------------------------------------------
return HomeBuild
----------------------------------------------