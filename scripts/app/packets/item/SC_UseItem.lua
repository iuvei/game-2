--
-- Author: Anthony
-- Date: 2014-11-13 20:12:17
-- Filename: SC_UseItem.lua
--
------------------------------------------------------------------------------
local item_operator = require("app.mediator.item_operator")
------------------------------------------------------------------------------
local SC_UseItem = {}
------------------------------------------------------------------------------
function SC_UseItem:execute( player, args )

	if args.result == 0 then
		printError("use item error! dataid:%d result:%d", args.item.dataId,args.result)
		return
	elseif args.result == 2 then
		return
	end

	item_operator:update( player, args.item)
	printInfo("SC_UseItem update item dataId:%d guid:%d num:%d",args.item.dataId,args.item.GUID,args.item.num)

	if args.hero.GUID > 0 then
		-- flush item effect
		local hero_mgr = player:get_mgr("heros")
		hero_mgr:update(args.hero)
	   	hero_mgr:get_hero(args.hero.GUID):flush_item_effect()

		local run_scene = display.getRunningScene()
		if run_scene then
			local layers=run_scene.UIlayer:getUiLayers()
			for i=1,#layers do
				layers[i]:ProcessNetResult({args=args,msg_type="SC_UseItem"
					})
			end
		end
	end


end
------------------------------------------------------------------------------
return SC_UseItem