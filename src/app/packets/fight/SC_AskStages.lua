--
-- Author: Anthony
-- Date: 2014-12-11 11:59:07
-- Filename: SC_AskStages.lua
--
return function ( player, args )
	player:get_mgr("stage"):set_data(args.stages)
	printInfo("ask stages ok")
end