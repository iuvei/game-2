--
-- Author: Anthony
-- Date: 2014-10-09 21:03:30
--
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
function M:handle( msg )

	print("SC_AskHeros playerid",msg.playerid,msg.result)

	if msg.result == 1 then
		-- 放到全局英雄数据
		CLIENT_PLAYER:set_heros(msg.heros)
	end

	print("ask heros ok")
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------