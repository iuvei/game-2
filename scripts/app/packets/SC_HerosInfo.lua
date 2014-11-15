--
-- Author: Anthony
-- Date: 2014-10-09 21:03:22
-- SC_HerosInfo.lua
------------------------------------------------------------------------------
local SC_HerosInfo = {}
------------------------------------------------------------------------------
function SC_HerosInfo:execute( player, args )

	if args.dataId == nil or args.dataId == 0 then
		return
	end

	printInfo("SC_HerosInfo dataid:%d, guid:%d",args.dataId,args.GUID)
	player:get_mgr( "heros" ):update_hero(args)
end
------------------------------------------------------------------------------
return SC_HerosInfo
------------------------------------------------------------------------------