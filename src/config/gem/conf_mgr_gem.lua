--
-- Author: Anthony
-- Date: 2014-10-23 11:06:45
-- Filename: conf_mgr_gem.lua
--
------------------------------------------------------------------------------
local conf	= require("config.gem.gem")
------------------------------------------------------------------------------
local conf_mgr_gem = {}
-- -----------------------------------------
-- function conf_mgr_gem:get_cout()
--     return #conf
-- end
-----------------------------------------
function conf_mgr_gem:get_info(data_id)
    return conf[data_id]
end
-----------------------------------------
function conf_mgr_gem:get_icon(data_id)
	local conf_art    = require("config.gem.gem_art")
    return conf_art[conf[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_gem