--
-- Author: Anthony
-- Date: 2014-08-29 11:41:44
--
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
function M:handle( msg )
	-- print("S2C_Login",msg.success, msg.errCode, msg.errMsg)

	if msg.success then

		DATA_User:set(msg.content)

		tab = DATA_User:get("createTime")
		tab = os.date("*t",tab)
		print("createtime",tab.year.."-"..tab.month.."-"..tab.day.."-"..tab.hour.."-"..tab.min.."-"..tab.sec)

		-- 成功 进入主页
    	switchscene("home",{ transitionType = "crossFade", time = 0.5})
	end
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------