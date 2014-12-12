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
-----------------------------------------
-- 得到产出位置
function conf_mgr_equip:get_output(data_id)
	local conf = require("config.equip.equip_output")
    return conf[data_id]
end
-----------------------------------------
-- 得到data_id的强化等级需要的数据
function conf_mgr_equip:get_equip_enhance(enhance_level)
	-- local equip = self:get_info(data_id)
	local conf = require("config.equip_enhance.equip_enhance")
 --    return {
 --    	maxlevel = equip.maxlevel,
 --    	attr = {equip.attr_type1,equip.attr_type2},
 --    	attr_percent = {conf[enhance_level].attr_percent1, conf[enhance_level].attr_percent2},
 --    	money = conf[enhance_level].money,
 --    	stuff_id = conf[enhance_level].stuff_id,
 --    	stuff_num = conf[enhance_level].stuff_num,
	-- }
	return conf[enhance_level]
end
------------------------------------------------------------------------------
return conf_mgr_equip