--
-- Author: Anthony
-- Date: 2014-08-29 14:54:07
-- CSC_SysHeartBeat.lua
-- local socket = require "socket"
return function ( player, args )
	-- print("CSC_SysHeartBeat",args.servertime,os.time())
	-- print("···",math.floor((socket.gettime() - player.network.pingstartvalue)*1000) )
	player:set_servertime(args.servertime)
end