--
-- Author: Anthony
-- Date: 2014-12-02 11:45:15
-- Filename: SC_EquipEnhance.lua

--[[
	args.result : 	0. 出错
					1. 成功
					2. 找不到英雄
					3. 达到最大强化等级
					4. 金钱不够
					5. 需求物品不足
					6. 没有该强化物品
]]
local ui_helper 	= require("app.ac.ui.ui_helper")
return function ( player, args )
	print("SC_EquipEnhance",args.result)
	if args.result ~= 1 then
		return
	end
	ui_helper:dispatch_event({msg_type="SC_EquipEnhance",args=args})
end