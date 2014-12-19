--
-- Author: Anthony
-- Date: 2014-11-12 16:09:50
-- Filename: item_operator.lua
--
local ipairs = ipairs

local item_helper = require("app.mediator.item.item_helper")
local configMgr = require("config.configMgr")
local game_attr = require("app.ac.game_attr")
local CommonDefine = require("app.ac.CommonDefine")

local item_operator = {}

function item_operator:get_mgr(dataId)
	local player = PLAYER
	local class = item_helper.get_serial_classid(dataId)
	if class == 1 then -- equip
		return player:get_mgr("equip")
	elseif class == 2 then
		return player:get_mgr("comitem")
	elseif class == 3 then
		return player:get_mgr("material")
	elseif class == 4 then
		return player:get_mgr("debris")
	elseif class == 5 then
		return player:get_mgr("gem")
	else
		return nil
	end
end

function item_operator:get_item(dataId)
	return self:get_mgr(dataId):get_by_GUID(dataId)
end

function item_operator:update(info)
	if info.GUID > 0 then
		local mgr = self:get_mgr(info.dataId)
		if mgr then
			if info.num == 0 then
				return mgr:remove(info.GUID)
			else
				return mgr:update(info)
			end
		end
	end
end

function item_operator:delete(info)
	if info.GUID > 0 then
		local mgr = self:get_mgr(info.dataId)
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
		require_level = equip_info.Level,
		base_price   = equip_info.BasePrice,
		artid       = equip_info.artid,
		icon        = conf:get_icon(equip_s.dataId),
		attr        = game_attr.gen_attr(equip_info),
		elevel 		= equip_s.elevel, -- enhanced level 强化等级
    }
end

-- 返回装备计算后的属性
function item_operator:get_equip_attr(equip_info,attr_name)
	local conf_enhance=configMgr:getConfig("equip"):get_equip_enhance(equip_info.elevel)
	if conf_enhance then
		local t=equip_info.attr[attr_name]
		if t == -1 then t=0 end
		return t + self:calc_equip_enhance(t,conf_enhance.attr_percent1)
	end
	return 0
end

--计算装备强化附加值
function item_operator:calc_equip_enhance(attr_val,percent1)
	if attr_val == -1 then attr_val=0 end
	return math.floor(attr_val*percent1/CommonDefine.RATE_LIMITE_100)
end

function item_operator:get_conf_mgr(dataId)
	local kind = item_helper.get_serial_class(dataId)
	return configMgr:getConfig(kind)
end

-- 取得道具个数
function item_operator:get_num_by_dataId(dataId)
	local datas = self:get_mgr(dataId):get_data()
	for k,v in pairs(datas) do
		if v:get_info().GUID == dataId then
			return v:get_info().num
		end
	end
	return 0
end

--重组物品编号，quality 减少增加由q参数控制
-- q 为负数则为减少
function item_operator:new_quality_itemid( item_dataId, q )
	local class = item_helper.get_serial_classid( item_dataId )
	local quality = item_helper.get_serial_qualityId( item_dataId )
	local type = item_helper.get_serial_type( item_dataId )
	local index = item_helper.get_serial_index(item_dataId)
	return item_helper.gen_serial(class,quality+q,type,index)
end
-- 合成，item_dataId为合成后的物品编号
function item_operator:compound( hero_dataId, item_dataId)
	local player = PLAYER

	local info = configMgr:getConfig("compound"):get_info(item_dataId)
	if info == nil then
		return KNMsg:getInstance():flashShow("没有该物品")
	end
	-- if info.money > 0 and player:get_basedata().money < info.money then
	-- 	return KNMsg:getInstance():flashShow("金钱不足")
	-- end

	if info.elevel >= 0 then
		-- 判断上一品质的物品的强化等级
		local t = self:new_quality_itemid(item_dataId,-1)
		t = player:get_mgr("heros"):get_equip(hero_dataId,t)
		if t == nil or t.elevel < info.elevel then
			return KNMsg:getInstance():flashShow("强化等级不满足")
		end
	end

	-- 判断需求物
	for k,v in ipairs(info.stuff_id) do
		-- print(k,v)
		if v > 0 then
			local item = self:get_mgr(v):get_by_GUID(v)
			if item == nil or item.num < info.stuff_num[k] then
				-- 物品不够
				return KNMsg:getInstance():flashShow("不满足合成条件")
			end
		end
	end
	return player:send("CS_Compound",{item_dataId=item_dataId,hero_dataId=hero_dataId})
end

-- 强化
function item_operator:enhance( hero_dataId, equip_dataId )
	local player = PLAYER

	local bd = player:get_basedata()
	local equip_info = player:get_mgr("heros"):get_equip(hero_dataId,equip_dataId)
	local next_level = equip_info.elevel+1
	local cofn_equip = configMgr:getConfig("equip"):get_info(equip_dataId)

	local info = configMgr:getConfig("equip"):get_equip_enhance(next_level)
	if info == nil then
		print("enhance table not",next_level)
		return
	end
	if next_level > cofn_equip.maxlevel then
		return KNMsg:getInstance():flashShow("已经强化为最高级")
	end
	-- if bd.money < info.money  then
	-- 	return KNMsg:getInstance():flashShow("金钱不足")
	-- end

	local item = self:get_item(info.stuff_id)
	if item == nil or item.num < info.stuff_num then
		return KNMsg:getInstance():flashShow("需求物品不足")
	end

	return player:send("CS_EquipEnhance",{hero_guid = hero_dataId, equip_guid = equip_dataId})
end

return item_operator