--
-- Author: Anthony
-- Date: 2014-12-04 14:39:55
-- Filename: SC_UpdateKeys.lua
--
--[[
		hero_guid
		kvs
			key
			value
]]
----------------------------------------------------------------
local ui_helper 	= require("app.ac.ui.ui_helper")
----------------------------------------------------------------
return function ( player, args )
	-- print("SC_UpdateKeys",args.hero_guid)
	if args.hero_guid > 0 then
		local hero = player:get_mgr("heros"):get_hero(args.hero_guid)
		for i,v in ipairs(args.kvs) do
			-- print(i,v.key,v.value)
			-- if hero:get( v.key ) ~= v.value then
				hero:setkey(v.key,v.value)
			-- end
		end
	else
		-- 玩家属性
		for i,v in ipairs(args.kvs) do
			-- print("..",i,v.key,v.value)
			player:set_basedata(v.key, v.value)
		end
		-- 更新人物信息
		ui_helper:dispatch_event({msg_type = "C_UpdataHeroInfo"})
	end

end