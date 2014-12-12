--
-- Author: Anthony
-- Date: 2014-11-17 21:24:16
-- Filename: conf_mgr_item_compound.lua
--
------------------------------------------------------------------------------
local item_compound	= require("config.item_compound.item_compound")
------------------------------------------------------------------------------
local conf_mgr_item_compound = {}
-----------------------------------------
function conf_mgr_item_compound:get_info(dataId)
    local conf = item_compound[dataId]
    if conf == nil then
        return
    end
	return {
        dataId = dataId,
		elevel = conf.elevel,
    	money = conf.money,
    	stuff_id = {
			conf.stuff_id1,
			conf.stuff_id2,
			conf.stuff_id3,
			conf.stuff_id4,
			conf.stuff_id5,
    	},
    	stuff_num = {
			conf.stuff_num1,
			conf.stuff_num2,
			conf.stuff_num3,
			conf.stuff_num4,
			conf.stuff_num5,
    	}
	}
end
-- 根据当前id取得下一等级的合成信息
function conf_mgr_item_compound:get_next_info(dataId)
    local next_lev = math.floor(math.floor(dataId/100000)%10)+1
    local next_dataid = math.floor(dataId/1000000) * 1000000 + (next_lev * 100000) + math.floor(dataId%100000)
    return self:get_info(next_dataid)
end
------------------------------------------------------------------------------
return conf_mgr_item_compound