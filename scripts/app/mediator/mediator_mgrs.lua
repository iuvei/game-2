--
-- Author: Anthony
-- Date: 2014-10-22 11:15:52
-- Filename: mediator_mgrs.lua
--
--[[
	name: 管理器名字
	file: 管理器所在目录， 以client_player为根目录
]]
local mgrs = {
	{name="heros", 		file=".hero.mgr_heros"},
	{name="formations", file=".formation.mgr_formations"},
	{name="equip", 		file=".equip.mgr_equip"},
	{name="item", 		file=".item.mgr_item"},
	{name="gem", 		file=".gem.mgr_gem"},
	{name="debris", 	file=".debris.mgr_debris"},
}

return mgrs