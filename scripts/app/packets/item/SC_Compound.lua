--
-- Author: Anthony
-- Date: 2014-11-17 22:43:49
-- Filename: SC_Compound.lua
--
local ipairs = ipairs

local item_operator = require("app.mediator.item.item_operator")
local ui_helper 	= require("app.ac.ui.ui_helper")

return function ( player, args )
	--{result,result_item,stuff}
	-- print("···",args.result)

	if args.result ~= 1 then
		-- print("···",args.result)
		return
	end

	item_operator:update(args.result_item)
	for k,v in ipairs(args.stuff) do
		-- print(k,v)
		item_operator:update(v)
	end
	ui_helper:dispatch_event({msg_type="SC_Compound",args=args})
end