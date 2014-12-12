--
-- Author: Anthony
-- Date: 2014-11-13 20:12:17
-- Filename: SC_UseItem.lua
--
local item_operator = require("app.mediator.item.item_operator")
local ui_helper 	= require("app.ac.ui.ui_helper")

return function ( player, args )

	if args.result == 0 then
		printError("use item error! dataid:%d result:%d", args.item.dataId,args.result)
		return
	elseif args.result == 2 then
		return
	end

	item_operator:update(args.item)
	printInfo("SC_UseItem update item dataId:%d guid:%d num:%d",args.item.dataId,args.item.GUID,args.item.num)

	-- if args.hero.GUID > 0 then
	-- 	player:get_mgr("heros"):update(args.hero)
	-- end
	ui_helper:dispatch_event({msg_type="SC_UseItem",args=args})
end