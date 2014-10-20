--
-- Author: Anthony
-- Date: 2014-10-10 15:34:50
--
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
function M:handle( msg )

	if msg.result == 0 then
		print("create hero error", msg.heroinfo.dataId)
		return
	end

	local heroinfo = msg.heroinfo
	if heroinfo.dataId == nil or heroinfo.dataId == 0 then
		return
	end

	print("SC_AskCreateHero dataId:",heroinfo.dataId,"GUID:",heroinfo.GUID)

	CLIENT_PLAYER:update_hero(heroinfo)
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------