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
	{ id=2, name="CS_Login", 			handlefile=""},
	{ id=3, name="SC_Login", 			handlefile=".SC_Login"},
	--------------------------------------------------------------------------
	-- hero
	{ id=4, name="CS_AskCreateHero", 	handlefile=""},
	{ id=5, name="SC_NewHero", 			handlefile=".hero.SC_NewHero"},
	{ id=6, name="CS_AskHeros", 		handlefile=""},
	{ id=7, name="SC_AskHeros", 		handlefile=".hero.SC_AskHeros"},
	--------------------------------------------------------------------------
	-- 阵形
	{ id=8,  name="CS_AskFormations", 		handlefile=""},
	{ id=9, name="SC_AskFormations", 		handlefile=".formations.SC_AskFormations"},
	{ id=10, name="CS_UpdateFormation", 	handlefile=""},
	{ id=11, name="SC_FormationResult", 	handlefile=".formations.SC_FormationResult"},
	--------------------------------------------------------------------------
	-- item
	{ id=12, name="CS_AskItemBag", 		handlefile=""},
	{ id=13, name="SC_AskItemBag", 		handlefile=".item.SC_AskItemBag"},
	{ id=14, name="CS_AskCreateItem", 	handlefile=""},
	{ id=15, name="SC_NewItem", 		handlefile=".item.SC_NewItem"},
	{ id=16, name="CS_UseItem", 		handlefile=""},
	{ id=17, name="SC_UseItem", 		handlefile=".item.SC_UseItem"},
	{ id=18, name="CS_Compound", 		handlefile=""},
	{ id=19, name="SC_Compound", 		handlefile=".item.SC_Compound"},
	--------------------------------------------------------------------------
	-- 战斗
	{ id=20, name="CS_FightBegin", 		handlefile=""},
	{ id=21, name="SC_FightBegin", 		handlefile=".fight.SC_FightBegin"},
	{ id=22, name="CS_FightEnd", 		handlefile=""},
	{ id=23, name="SC_FightEnd", 		handlefile=".fight.SC_FightEnd"},
	--------------------------------------------------------------------------
}
