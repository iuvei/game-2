--
-- Author: Anthony
-- Date: 2014-10-09 21:03:30
-- SC_AskHeros.lua
------------------------------------------------------------------------------
local SC_AskHeros = {}
------------------------------------------------------------------------------
function SC_AskHeros:execute( player, args )

	-- print("SC_AskHeros playerid",args.playerid,args.result)

	if args.result == 1 then
		-- 放到全局英雄数据
		player:get_mgr("heros"):set_data(args.heros)
		printInfo("ask heros ok")
	else
		printInfo("ask heros error")
	end
end
------------------------------------------------------------------------------
return SC_AskHeros
------------------------------------------------------------------------------