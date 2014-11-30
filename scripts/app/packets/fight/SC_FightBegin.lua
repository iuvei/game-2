--
-- Author: Anthony
-- Date: 2014-11-26 18:00:21
-- Filename: SC_FightBegin.lua
--
return function ( player, args )
	print("···",args.stageId,args.begin_time)
	player:set_fight_info(args.stageId,args.begin_time)
	switchscene("battle",{ tempdata=args.stageId})
end