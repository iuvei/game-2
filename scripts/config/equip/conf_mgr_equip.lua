--
-- Author: Anthony
-- Date: 2014-10-20 15:59:56
-- conf_mgr_equip
------------------------------------------------------------------------------
local conf_equip        = require("config.equip.equip")
------------------------------------------------------------------------------
local conf_mgr_equip = {}
-----------------------------------------
function conf_mgr_equip:get_info(data_id)
    return conf_equip[data_id]
end
-----------------------------------------
function conf_mgr_equip:get_icon(data_id)
	local conf_equip_art    = require("config.equip.equip_art")
    return conf_equip_art[conf_equip[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_equip