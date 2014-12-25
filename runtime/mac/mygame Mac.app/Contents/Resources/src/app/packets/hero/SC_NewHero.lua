--
-- Author: Anthony
-- Date: 2014-10-10 15:34:50
-- SC_NewHero

return function ( player, args )

	if args.result == 0 then
		printError("create hero error! dataid:%d result:%d", args.heroinfo.dataId,args.result)
		return
	elseif args.result == 2 then
		return
	end


	local heroinfo = args.heroinfo
	if heroinfo.dataId == nil or heroinfo.dataId == 0 then
		return
	end

	printInfo("SC_NewHero dataId:%d guid:%d",heroinfo.dataId,heroinfo.GUID)

	player:get_mgr( "heros" ):update(heroinfo)
end