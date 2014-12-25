--
-- Author: Anthony
-- Date: 2014-10-22 17:06:45
-- Filename: conf_mgr_debris.lua
--
------------------------------------------------------------------------------
local conf_debris	= require("config.debris.debris")
------------------------------------------------------------------------------
local conf_mgr_debris = {}
-----------------------------------------
function conf_mgr_debris:get_info(data_id)
    return conf_debris[data_id]
end
-----------------------------------------
function conf_mgr_debris:get_icon(data_id)
	local conf_art    = require("config.debris.debris_art")
    return conf_art[conf_debris[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_debris