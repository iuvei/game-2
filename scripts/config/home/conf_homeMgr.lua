--
-- Author: wangshaopei
-- Date: 2014-09-19 14:33:40
--
local MapConstants  = require("app.ac.MapConstants")
local homeBuilds    =require("config.home.homeBuild")
local homeRes       =require("config.home.homeRes")
local conf_homeMgr = {}
function conf_homeMgr:getHomeBuilds()
    return homeBuilds.all_type
end
function conf_homeMgr:getHomeBuild(buildId)
    return homeBuilds.all_type[buildId][1]
end
function conf_homeMgr:getHomeBuildRes(buildId)
    local build = self:getHomeBuild(buildId)
    local typeId = math.floor(build.resId/1000)
    local index = math.floor(build.resId%1000)
    return homeRes.all_type[typeId][index]
end
function conf_homeMgr:getHomeRes(resType)
    return homeRes.all_type[resType]
end
function conf_homeMgr:toRect(strRect)
    local ts = string.split(strRect, ",")
    assert(#ts==4 ,string.format("conf_homeMgr:toRect() - faild !, strRect=%s", strRect))
    local x,y = ts[1],ts[2]
    local w,h = ts[2],ts[3]
    return CCRect(x,y,w,h)
end
return conf_homeMgr