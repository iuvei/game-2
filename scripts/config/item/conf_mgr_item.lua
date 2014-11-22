--
-- Author: Anthony
-- Date: 2014-10-22 17:06:45
-- Filename: conf_mgr_items.lua
--
------------------------------------------------------------------------------
local conf_item	= require("config.item.item")
------------------------------------------------------------------------------
local conf_mgr_item = {}
-----------------------------------------
function conf_mgr_item:get_info(data_id)
    return conf_item[data_id]
end
-----------------------------------------
function conf_mgr_item:get_icon(data_id)
	local conf_art    = require("config.item.item_art")
    return conf_art[conf_item[data_id].artid].icon
end
------------------------------------------------------------------------------
return conf_mgr_item