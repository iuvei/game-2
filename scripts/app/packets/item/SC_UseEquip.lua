--
-- Author: Anthony
-- Date: 2014-10-24 14:47:39
-- Filename: SC_UseEquip.lua
--
local item_helper = require("app.mediator.item.item_helper")

return function ( player, args )

	-- print("SC_UseEquip",args.op, args.result, args.GUID, args.HeroGUID)
	-- if args.result == 0 then
	-- 	printError("use equip error! guid:%d hero_guid:%d", args.GUID, args.HeroGUID)
	-- 	return
	-- end

	-- printInfo("SC_UseEquip equip_guid:%d hero_guid:%d", args.GUID, args.HeroGUID)

	-- local hero_mgr = player:get_mgr("heros")
	-- local hero = hero_mgr:get_hero_by_GUID(args.HeroGUID)
	-- if hero == nil then
	-- 	printError("use equip error! don't find hero_guid:%d", args.HeroGUID)
	-- end

	-- local equip = player:get_mgr("equip"):get_by_GUID( args.GUID )
	-- if equip == nil then
	-- 	printError("use equip error! don't find equip_guid:%d", args.GUID)
	-- end

	-- local equip_point = item_helper.get_serial_type( equip.dataId )
	-- if equip_point == nil or equip_point <= 0 then
	-- 	printError("use equip equip_point error! dataid:%d", equip.dataId)
	-- end

	-- if args.op == 0 then
	-- 	-- dump(hero)
	-- 	if hero.equips[equip_point] and hero.equips[equip_point].GUID == equip.GUID then
	-- 		-- print("equips not update")
	-- 	else
	-- 		hero.equips[equip_point] = {GUID=equip.GUID}
	-- 		hero_mgr:update(hero)
	-- 	end
	-- else
	-- 	hero.equips[equip_point] = nil
	-- 	hero_mgr:update(hero)
	-- end

	-- -- flush item effect
 --    hero_mgr:get_hero(args.HeroGUID):flush_item_effect()

	-- local run_scene = display.getRunningScene()
	-- if run_scene then
	-- 	local layers=run_scene.UIlayer:getUiLayers()
	-- 	for i=1,#layers do
	-- 		layers[i]:ProcessNetResult({args=args,msg_type="SC_UseEquip"
	-- 			})
	-- 	end
	-- end
end