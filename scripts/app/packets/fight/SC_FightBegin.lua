--
-- Author: Anthony
-- Date: 2014-11-26 18:00:21
-- Filename: SC_FightBegin.lua
--
return function ( player, args )
	-- print("SC_FightBegin",args.stageId,args.result)
	if args.result == 1 then
		player:set_fight_info(args.stageId,0)
		switchscene("battle",{ tempdata=args.stageId})
	elseif args.result == 2 then
		KNMsg:getInstance():flashShow("关卡未开启")
	elseif args.result == 3 then
		KNMsg:getInstance():flashShow("次数不足")
	elseif args.result == 4 then
		KNMsg:getInstance():flashShow("军令不足")
	end
end