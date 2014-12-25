--
-- Author: wangshaopei
-- Date: 2014-09-19 14:33:40
--
local MapConstants  = require("app.ac.MapConstants")
local homeBuilds    =require("config.home.homeBuild")
local homeRes       =require("config.home.homeRes")
local conf_mgr_home = {}
function conf_mgr_home:getHomeBuilds()
    return homeBuilds
end
function conf_mgr_home:getHomeBuild(buildId)
    return homeBuilds[buildId][1]
end
function conf_mgr_home:getHomeBuildRes(buildId)
    local build = self:getHomeBuild(buildId)
    return homeRes[math.floor(build.resId/1000)][math.floor(build.resId%1000)]
end
function conf_mgr_home:getHomeRes(resType)
    return homeRes[resType]
end
function conf_mgr_home:toRect(strRect)
    local ts = string.split(strRect, ",")
    assert(#ts==4 ,string.format("conf_mgr_home:toRect() - faild !, strRect=%s", strRect))
    local x,y = ts[1],ts[2]
    local w,h = ts[2],ts[3]
    return cc.rect(x,y,w,h)
end
return conf_mgr_home