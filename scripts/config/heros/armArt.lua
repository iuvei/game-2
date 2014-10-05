-- this file is generated by program!
-- don't change it manaully.
-- source file: /Users/wangshaopei/Documents/work_sanguo/code(trunk)/tools/xls2lua/xls_flies/arms.xls
-- created at: Wed Sep 17 00:25:18 2014


local armArt = {}

armArt.gongbings = {}
local gongbings = armArt.gongbings
gongbings[1] = {
	TypeId = 3,
	TypeName = "gongbing",
	file = "gongbing-wait.png",
	enemyPrefix = "d-",
}
gongbings[2] = {
	file = "gongbing-dead.png",
}
gongbings[3] = {
	file = "gongbing-move%d.png",
}
gongbings[4] = {
	file = "gongbing-atk%d.png",
}
gongbings[5] = {
	file = "gongbing-underatk.png",
}

armArt.qibings = {}
local qibings = armArt.qibings
qibings[1] = {
	TypeId = 2,
	TypeName = "qibing",
	file = "qibing-wait.png",
	enemyPrefix = "d-",
}
qibings[2] = {
	file = "qibing-dead.png",
}
qibings[3] = {
	file = "qibing-move%d.png",
}
qibings[4] = {
	file = "qibing-atk%d.png",
}
qibings[5] = {
	file = "qibing-underatk.png",
}

armArt.bubings = {}
local bubings = armArt.bubings
bubings[1] = {
	TypeId = 1,
	TypeName = "bubing",
	file = "bubing-wait.png",
	enemyPrefix = "d-",
}
bubings[2] = {
	file = "bubing-dead.png",
}
bubings[3] = {
	file = "bubing-move%d.png",
}
bubings[4] = {
	file = "bubing-atk%d.png",
}
bubings[5] = {
	file = "bubing-underatk.png",
}

armArt.gongchengches = {}
local gongchengches = armArt.gongchengches
gongchengches[1] = {
	TypeId = 4,
	TypeName = "gongchengche",
	file = "gongchengche-wait.png",
	enemyPrefix = "d-",
}
gongchengches[2] = {
	file = "gongchengche-dead.png",
}
gongchengches[3] = {
	file = "gongchengche-move%d.png",
}
gongchengches[4] = {
	file = "gongchengche-atk%d.png",
}
gongchengches[5] = {
	file = "gongchengche-underatk.png",
}

armArt.type_map = {}
local type_map = armArt.type_map
type_map[3] = "gongbings" type_map["gongbings"] = 3
type_map[2] = "qibings" type_map["qibings"] = 2
type_map[1] = "bubings" type_map["bubings"] = 1
type_map[4] = "gongchengches" type_map["gongchengches"] = 4

armArt.all_type= {}
local all_type = armArt.all_type
all_type[3] = gongbings
all_type[2] = qibings
all_type[1] = bubings
all_type[4] = gongchengches

for i,v in pairs(armArt.all_type) do
	local item = v
	for j=1, #item do
		item[j].__index = item[j]
		if j < #item then
			setmetatable(item[j+1], item[j])
		end
	end
end


return armArt

