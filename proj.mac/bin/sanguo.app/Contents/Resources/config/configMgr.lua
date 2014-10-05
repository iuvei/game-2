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
        -- 武将配置管理器
        config = require("config.heros.conf_herosMgr")
    elseif  type == "stages" then
        config = require("config.stages.conf_Mgr")
    elseif  type == "skills" then
        config = require("config.skills.conf_skillsMgr")
    elseif  type == "impacts" then
        config = require("config.skills.conf_impactsMgr")
    end

    return config
end
------------------------------------------------------------------------------
return configMgr
------------------------------------------------------------------------------