--
-- Author: Anthony
-- Date: 2014-11-12 16:09:50
-- Filename: item_operator.lua
--
local ipairs = ipairs

local item_helper = require("app.mediator.item.item_helper")
local configMgr = require("config.configMgr")
local game_attr = require("app.ac.game_attr")

local item_operator = {}

function item_operator:get_mgr( player, dataId)
	local class = item_helper.get_serial_classid(dataId)
	if class == 1 then -- equip
		return player:get_mgr("equip")
	elseif class == 2 then
		return player:get_mgr("comitem")
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
				return mgr:remove(info.GUID)
			else
				return mgr:update(info)
			end
		end
	end
end

function item_operator:delete( player, info)
	if info.GUID > 0 then
		local mgr = self:get_mgr(player,info.dataId)
		if mgr then
			return mgr:remove(info.GUID)
		end
	end
end

-- 得到武器的信息，从配置表里得到
function item_operator:get_equip_info( equip_s )
	if equip_s.GUID<=0 or equip_s.dataId <= 0 then
		return nil
	end

    local conf = configMgr:getConfig("equip")
    local equip_info = conf:get_info(equip_s.dataId)

    return {
		dataId      = equip_s.dataId,
		kindId      = item_helper.get_serial_classid(equip_s.dataId),
		GUID        = equip_s.GUID,
		num         = equip_s.num,
		name        = equip_info.name,
		desc        = equip_info.desc,
		quality     = item_helper.get_serial_qualityId(equip_s.dataId),
		equip_point = item_helper.get_serial_type(equip_s.dataId),
		require_level = equip_info.RequireLevel,
		base_price   = equip_info.BasePrice,
		artid       = equip_info.artid,
		icon        = conf:get_icon(equip_s.dataId),
		attr        = game_attr.gen_attr(equip_info),
		elevel 		= equip_s.elevel, -- enhanced level 强化等级
    }
end

function item_operator:get_conf_mgr(dataId)
	local kind = item_helper.get_serial_class(dataId)
	return configMgr:getConfig(kind)
end

-- 合成
function item_operator:compound( player, item_dataId, hero_dataId )

	local info = configMgr:getConfig("compound"):get_info(item_dataId)
	-- if player:get_basedata().money < info.money then
	-- 	KNMsg:getInstance():flashShow("金钱不足")
	-- 	return
	-- end

	for k,v in ipairs(info.stuff_id) do
		-- print(k,v)
		if v > 0 then
			local item = self:get_mgr(player,v):get_by_GUID(v)
			if item == nil or item.num < info.stuff_num[k] then
				-- 物品不够
				KNMsg:getInstance():flashShow("不满足合成条件")
				return
			end
		end
	end
	return player:send("CS_Compound",{item_dataId = item_dataId,hero_dataId=hero_dataId})
end

return item_operator