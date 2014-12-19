--
-- Author: Anthony
-- Date: 2014-08-01 16:24:29
--
------------------------------------------------------------------------------
local config_mgr = {}
------------------------------------------------------------------------------
--根据type读取相应的配置文件管理器
function config_mgr:getConfig(type)
    if type == "heros" then
        return require("config.heros.conf_mgr_heros")
    elseif  type == "stages" then
        return require("config.stages.conf_mgr_stages")
    elseif  type == "skills" then
        return require("config.skills.conf_mgr_skills")
    elseif  type == "impacts" then
        return require("config.skills.conf_mgr_impacts")
    elseif type=="home" then
        return require("config.home.conf_mgr_home")
    elseif type == "equip" then
        return require("config.equip.conf_mgr_equip")
    elseif type == "comitem" then
        return require("config.comitem.conf_mgr_comitem")
    elseif type == "material" then
        return require("config.material.conf_mgr_material")
    elseif type == "gem" then
        return require("config.gem.conf_mgr_gem")
    elseif type == "debris" then
        return require("config.debris.conf_mgr_debris")
    elseif type == "compound" then
        return require("config.item_compound.conf_mgr_item_compound")
    end
end
------------------------------------------------------------------------------
return config_mgr
------------------------------------------------------------------------------