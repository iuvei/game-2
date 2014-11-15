--
-- Author: Anthony
-- Date: 2014-08-01 16:24:29
--
------------------------------------------------------------------------------
local configMgr = {}
------------------------------------------------------------------------------
--根据type读取相应的配置文件管理器
function configMgr:getConfig(type)
    local config = nil

    if type == "heros" then
        config = require("config.heros.conf_mgr_heros")
    elseif  type == "stages" then
        config = require("config.stages.conf_mgr_stages")
    elseif  type == "skills" then
        config = require("config.skills.conf_mgr_skills")
    elseif  type == "impacts" then
        config = require("config.skills.conf_mgr_impacts")
    elseif type=="home" then
        config = require("config.home.conf_mgr_home")
    elseif type == "equip" then
        config = require("config.equip.conf_mgr_equip")
    elseif type == "item" then
        config = require("config.item.conf_mgr_item")
    elseif type == "gem" then
        config = require("config.gem.conf_mgr_gem")
    elseif type == "debris" then
        config = require("config.debris.conf_mgr_debris")
    end

    return config
end
------------------------------------------------------------------------------
return configMgr
------------------------------------------------------------------------------