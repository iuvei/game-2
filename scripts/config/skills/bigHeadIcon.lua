-- this file is generated by program!
-- don't change it manaully.
-- source file: /Users/wangshaopei/Documents/work_sanguo/code(trunk)/tools/xls2lua/xls_flies/skill.xls
-- created at: Wed Sep 17 07:01:08 2014


local bigHeadIcon = {}

bigHeadIcon.bigHead1s = {}
local bigHead1s = bigHeadIcon.bigHead1s
bigHead1s[1] = {
	TypeId = 1,
	TypeName = "bigHead1",
	id = 1001,
}

bigHeadIcon.type_map = {}
local type_map = bigHeadIcon.type_map
type_map[1] = "bigHead1s" type_map["bigHead1s"] = 1

bigHeadIcon.all_type= {}
local all_type = bigHeadIcon.all_type
all_type[1] = bigHead1s

for i,v in pairs(bigHeadIcon.all_type) do
	local item = v
	for j=1, #item do
		item[j].__index = item[j]
		if j < #item then
			setmetatable(item[j+1], item[j])
		end
	end
end


return bigHeadIcon

