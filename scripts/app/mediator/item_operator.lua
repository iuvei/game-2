--
-- Author: Anthony
-- Date: 2014-11-12 16:09:50
-- Filename: item_operator.lua
--
local item_helper = require("app.mediator.item_helper")
local configMgr = require("config.configMgr")
local game_attr = require("app.ac.game_attr")

local item_operator = {}

function item_operator:get_mgr( player, dataId)
	local class = item_helper.get_serial_classid(dataId)
	if class == 1 then -- equip
		return player:get_mgr("equip")
	elseif class == 2 or class == 3 then
		return player:get_mgr("item")
	elseif class == 4 then
		return player:get_mgr("debris")
	elseif class == 5 then
		return player:get_mgr("gem")
	else
		return nil
	end
end

function item_operator:update( player, info)
	if info.GUID > 0 then
		local mgr = self:get_mgr(player,info.dataId)
		if mgr then
			if info.num == 0 then
				mgr:remove(info.GUID)
			else
				mgr:update(info)
			end
		end
	end
end

function item_operator:delete( player, info)
	if info.GUID > 0 then
		local mgr = self:get_mgr(player,info.dataId)
		if mgr then
			mgr:remove(info.GUID)
		end
	end
end

--
function item_operator:get_equip_info( equip_s )
	if equip_s.GUID<=0 or equip_s.dataId <= 0 then
		return nil
	end

    local conf = configMgr:getConfig("equip")
    local equip_info = conf:get_info(equip_s.dataId)

    local outinfo = {
        dataId      = equip_s.dataId,
        kindId      = item_helper.get_serial_classid(equip_s.dataId),
        GUID        = equip_s.GUID,
        num         = equip_s.num,
        name        = equip_info.name,
        desc        = equip_info.desc,
        quality     = item_helper.get_serial_quality(equip_s.dataId),
        equip_point = item_helper.get_serial_type(equip_s.dataId),
        require_level = equip_info.RequireLevel,
        base_price   = equip_info.BasePrice,
        artid       = equip_info.artid,
        icon        = conf:get_icon(equip_s.dataId),
        attr        = game_attr.gen_attr(equip_info),
    }
    return outinfo
end

return item_operator