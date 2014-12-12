--
-- Author: Anthony
-- Date: 2014-10-21 17:00:07
-- Filename: SC_AskItemBag.lua

return function ( player, args )
	-- print("SC_AskItemBag",args.playerid)

	-- if args.result == 1 then
		-- 放到全局装备数据
		player:get_mgr("equip"):set_data(args.items.equips)
		player:get_mgr("comitem"):set_data(args.items.comitems)
		player:get_mgr("gem"):set_data(args.items.gems)
		player:get_mgr("debris"):set_data(args.items.debris)
		player:get_mgr("material"):set_data(args.items.material)
	-- end

	-------------------------------
	printInfo("ask itembag ok")

	-------------------------------
	-- 成功 进入主页
	printInfo("change to homescene")
	switchscene("home",{ transitionType = "crossFade", time = 0.5})
	-------------------------------
end