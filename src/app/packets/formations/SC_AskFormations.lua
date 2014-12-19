--
-- Author: Anthony
-- Date: 2014-10-12 11:58:52
-- SC_AskFormations.lua

return function ( player, msg )

	PLAYER:get_mgr("formations"):set_data(msg.formations)
	printInfo("ask formation ok")

end