--
-- Author: Anthony
-- Date: 2014-10-12 11:58:52
-- SC_AskFormations.lua
------------------------------------------------------------------------------
local  SC_AskFormations = {}
------------------------------------------------------------------------------
function SC_AskFormations:execute( player, msg )

	CLIENT_PLAYER:get_mgr("formations"):set_data(msg.formations)
	printInfo("ask formation ok")

end
------------------------------------------------------------------------------
return SC_AskFormations
------------------------------------------------------------------------------