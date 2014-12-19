--
-- Author: Anthony
-- Date: 2014-12-03 15:47:41
-- Filename: conf_mgr_meterial.lua
--
------------------------------------------------------------------------------
local conf_material	= require("config.material.material")
------------------------------------------------------------------------------
local conf_mgr_material = {}
-----------------------------------------
function conf_mgr_material:get_info(data_id)
    return conf_material[data_id]
end
-----------------------------------------
function conf_mgr_material:get_icon(data_id)
	local conf_art    = require("config.material.material_art")
    return conf_art[conf_material[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_material