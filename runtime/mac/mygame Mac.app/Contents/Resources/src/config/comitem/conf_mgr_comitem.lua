--
-- Author: Anthony
-- Date: 2014-10-22 17:06:45
-- Filename: conf_mgr_items.lua
--
------------------------------------------------------------------------------
local conf_comitem	= require("config.comitem.comitem")
------------------------------------------------------------------------------
local conf_mgr_comitem = {}
-----------------------------------------
function conf_mgr_comitem:get_info(data_id)
    return conf_comitem[data_id]
end
-----------------------------------------
function conf_mgr_comitem:get_icon(data_id)
	local conf_art    = require("config.comitem.comitem_art")
    return conf_art[conf_comitem[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_comitem