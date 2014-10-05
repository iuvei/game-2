
--[[
	 handlefile: 执行handle的文件,cmd.lua所在目录为根目录
]]

local cmd = {
	{ id=1, name="C2S_SysHeartBeat", handlefile=".packets.C2S_SysHeartBeat"},
	{ id=2, name="C2S_Login", handlefile=""},
	{ id=3, name="S2C_Login", handlefile=".packets.S2C_Login"},
	--{ id=4, name="C2S_Logout", handlefile="C2S_Logout" },
	--{ id=5, name="S2C_Logout", handlefile="S2C_Logout" },
}

return cmd
