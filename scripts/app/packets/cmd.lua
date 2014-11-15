
--[[
	client:所有cmf都为发向gateserver的包。

	name: 消息名，需跟pb一样。
	handlefile: 执行handle的文件,cmd.lua所在目录为根目录

	CS_XXXX	客户端发向服务端
	SC_XXXX	服务端发向客户端

	CSC_XXXX 客户端和服务端相互发(客户端发起)
	SCS_XXXX 客户端和服务端相互发(服务端发起)
]]

local cmd = {
	{ id=1, name="CSC_SysHeartBeat",	handlefile=".CSC_SysHeartBeat"},
	{ id=2, name="CS_Login", 			handlefile=""},
	{ id=3, name="SC_Login", 			handlefile=".SC_Login"},
	--------------------------------------------------------------------------
	-- hero
	{ id=4, name="CS_AskCreateHero", 	handlefile=""},
	{ id=5, name="SC_FlushHero", 		handlefile=".SC_FlushHero"},
	{ id=6, name="CS_AskHeros", 		handlefile=""},
	{ id=7, name="SC_AskHeros", 		handlefile=".SC_AskHeros"},
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
	{ id=15, name="SC_FlushItem", 		handlefile=".item.SC_FlushItem"},
	--
	-- { id=16, name="CS_UseEquip", 		handlefile=""},
	-- { id=17, name="SC_UseEquip", 		handlefile=".item.SC_UseEquip"},
	{ id=18, name="CS_UseItem", 		handlefile=""},
	{ id=19, name="SC_UseItem", 		handlefile=".item.SC_UseItem"},
	--------------------------------------------------------------------------
}

return cmd
