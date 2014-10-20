
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
	{ id=1, name="CSC_SysHeartBeat",	handlefile=".packets.CSC_SysHeartBeat"},
	{ id=2, name="CS_Login", 			handlefile=""},
	{ id=3, name="SC_Login", 			handlefile=".packets.SC_Login"},
	--------------------------------------------------------------------------
	-- hero
	{ id=4, name="CS_AskCreateHero", 	handlefile=""},
	{ id=5, name="SC_AskCreateHero", 	handlefile=".packets.SC_AskCreateHero"},
	{ id=6, name="SC_HerosInfo", 		handlefile=".packets.SC_HerosInfo"},
	{ id=7, name="CS_AskHeros", 		handlefile=""},
	{ id=8, name="SC_AskHeros", 		handlefile=".packets.SC_AskHeros"},
	--------------------------------------------------------------------------
	-- 阵形
	{ id=9, name="CS_AskFormations", 		handlefile=""},
	{ id=10, name="SC_AskFormations", 		handlefile=".packets.formations.SC_AskFormations"},
	{ id=11, name="CS_UpdateFormation", 	handlefile=""},
	{ id=12, name="SC_FormationResult", 	handlefile=".packets.formations.SC_FormationResult"},
	--------------------------------------------------------------------------
}

return cmd
