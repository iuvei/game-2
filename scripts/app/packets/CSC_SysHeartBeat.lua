--
-- Author: Anthony
-- Date: 2014-08-29 14:54:07
-- CSC_SysHeartBeat.lua

return function ( player, args )
	-- print("CSC_SysHeartBeat",args.servertime,os.time())
	player:set_servertime(args.servertime)
end