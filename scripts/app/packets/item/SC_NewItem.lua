--
-- Author: Anthony
-- Date: 2014-10-22 18:09:26
-- Filename: SC_NewItem.lua
--
------------------------------------------------------------------------------
local item_operator = require("app.mediator.item_operator")
------------------------------------------------------------------------------
local SC_NewItem = {}
------------------------------------------------------------------------------
function SC_NewItem:execute( player, args )
	if args.result == 0 then
		-- printError("create item error! dataid:%d result:%d", args.info.dataId,args.result)
		return
	elseif args.result == 2 then
		return
	end

	item_operator:update( player, args.info)
	printInfo("SC_NewItem update dataId:%d guid:%d num:%d",args.info.dataId,args.info.GUID,args.info.num)
end
------------------------------------------------------------------------------
return SC_NewItem