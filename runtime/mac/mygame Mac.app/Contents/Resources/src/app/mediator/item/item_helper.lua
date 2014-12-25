--
-- Author: Anthony
-- Date: 2014-10-21 18:46:10
-- Filename: item_helper.lua
--
local math = math

local item_helper = {}

-- 得到物品大类
function item_helper.get_serial_class( serial )
	local class = math.floor(serial/10000000)
	if class == 1 then -- 装备
		return "equip"
	elseif class == 2 then -- 消耗品
		return "comitem"
	elseif class == 3 then -- 原料
		return "material"
	elseif class == 4 then -- 碎片
		return "debris"
	elseif class == 5 then -- 宝石
		return "gem"
	else
		return "unknown"
	end
end
-- 得到物品大类
function item_helper.get_serial_classid( serial )
	return math.floor(serial/10000000)
end

-- 得到品质
function item_helper.get_serial_quality( serial )
	local quality = math.floor((serial%10000000)/100000)

	--白色，绿色，蓝色，紫色，橙色。
	if quality == 1 then
		return "white"
	elseif quality == 2 then
		return "green"
	elseif quality == 3 then
		return "blue"
	elseif quality == 4 then
		return "purple"
	elseif quality == 5 then
		return "orange"
	else
		return "unknown"
	end
end
--
function item_helper.get_serial_qualityId( serial )
	return math.floor((serial%10000000)/100000)
end
-- 得到物品类型
function item_helper.get_serial_type( serial )
	return math.floor((serial%100000)/1000)
end

function item_helper.get_serial_index(serial)
	return  math.floor(serial%1000)
end

function item_helper.gen_serial(class,quality,type,index)
	return class*10000000+quality*100000+type*1000+index
end
return item_helper