--
-- Author: Anthony
-- Date: 2014-10-12 15:31:05
-- SC_FormationResult.lua
------------------------------------------------------------------------------
local SC_FormationResult = {}
------------------------------------------------------------------------------
function SC_FormationResult:execute( player, msg )
	printInfo("SC_FormationResult",msg.formation.index,msg.formation.GUID,msg.formation.dataId)

end
------------------------------------------------------------------------------
return SC_FormationResult
------------------------------------------------------------------------------