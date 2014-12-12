--
-- Author: Anthony
-- Date: 2014-12-02 11:45:26
-- Filename: SC_UpdateHeroEquip.lua
--
return function ( player, args )
	-- print("···",args.hero_guid)
	player:get_mgr("heros"):update_equip(args.hero_guid,args.equip)
end