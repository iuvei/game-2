--
-- Author: Anthony
-- Date: 2014-12-11 11:59:14
-- Filename: SC_StageInfo.lua
--
return function ( player, args )
	player:get_mgr( "stage" ):update(args)
end