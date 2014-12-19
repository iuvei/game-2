--
-- Author: Anthony
-- Date: 2014-10-21 17:00:38
-- Filename: SC_CreateEquip.lua

return function ( player, args )
	if args.result == 0 then
		printError("create equip error! dataid:%d result:%d", args.info.dataId,args.result)
		return
	elseif args.result == 2 then
		return
	end

	local info = args.info
	if info.dataId == nil or info.dataId == 0 then
		return
	end

	printInfo("SC_CreateEquip dataId:%d GUID:%d",info.dataId,info.GUID)

	player:get_mgr("equip"):update(info)
end