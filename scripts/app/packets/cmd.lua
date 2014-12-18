--cmd.lua
--[[
	client:所有cmf都为发向gateserver的包。

	name: 消息名，需跟pb一样。
	handlefile: 执行handle的文件,cmd.lua所在目录为根目录

	CS_XXXX	客户端发向服务端
	SC_XXXX	服务端发向客户端

	CSC_XXXX 客户端和服务端相互发(客户端发起)
	SCS_XXXX 客户端和服务端相互发(服务端发起)
]]

return  {
	{ id=1, name="CSC_SysHeartBeat",	handlefile=".CSC_SysHeartBeat"},
	{ id=2, name="CS_Login",},
	{ id=3, name="SC_Login", 			handlefile=".SC_Login"},
	{ id=4, name="CS_AskInfo",},
	--------------------------------------------------------------------------
	-- hero
	{ id=5, name="SC_NewHero", 			handlefile=".hero.SC_NewHero"},
	{ id=6, name="SC_AskHeros", 		handlefile=".hero.SC_AskHeros"},
	--------------------------------------------------------------------------
	-- 阵形
	{ id=7,  name="SC_AskFormations", 	handlefile=".formations.SC_AskFormations"},
	{ id=8,  name="CS_UpdateFormation"},
	{ id=9,  name="SC_FormationResult", handlefile=".formations.SC_FormationResult"},
	--------------------------------------------------------------------------
	-- item
	{ id=10, name="SC_AskItemBag", 		handlefile=".item.SC_AskItemBag"},
	{ id=11, name="SC_NewItem", 		handlefile=".item.SC_NewItem"},
	{ id=12, name="CS_UseItem",},
	{ id=13, name="SC_UseItem", 		handlefile=".item.SC_UseItem"},
	-- 合成
	{ id=14, name="CS_Compound",},
	{ id=15, name="SC_Compound", 		handlefile=".item.SC_Compound"},
	-- 强化装备
	{ id=16, name="CS_EquipEnhance",},
	{ id=17, name="SC_EquipEnhance", 	handlefile=".item.SC_EquipEnhance"},
	{ id=18, name="SC_UpdateHeroEquip", handlefile=".item.SC_UpdateHeroEquip"},
	--------------------------------------------------------------------------
	{ id=19, name="SC_UpdateKeys",		handlefile=".SC_UpdateKeys"},
	--------------------------------------------------------------------------
	{ id=20, name="CS_Command",},
	{ id=21, name="SC_MSG", 			handlefile=".chat.SC_MSG"},
	{ id=22, name="SC_BroadCast", 		handlefile=".chat.SC_BroadCast"},
	--------------------------------------------------------------------------
	-- 关卡
	{ id=23, name="SC_AskStages", 		handlefile=".fight.SC_AskStages"},
	{ id=24, name="SC_StageInfo", 		handlefile=".fight.SC_StageInfo"},
	-- 战斗
	{ id=25, name="CS_FightBegin",},
	{ id=26, name="SC_FightBegin", 		handlefile=".fight.SC_FightBegin"},
	{ id=27, name="CS_FightEnd",},
	{ id=28, name="SC_FightEnd", 		handlefile=".fight.SC_FightEnd"},
	--------------------------------------------------------------------------
}
