--
-- Author: Anthony
-- Date: 2014-08-29 11:41:44
--
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
function M:handle( msg )
    local PLAYER = CLIENT_PLAYER

	if msg.success then

		-------------------------------
		-- 玩家基础数据
        msg.content.playerid = msg.playerid
        PLAYER:init_basedata(msg.content)
        print("login gameserver success",PLAYER:get_playerid() )

        -- dump(PLAYER:get_basedata())

		-------------------------------
		-- 请求得到英雄数据
		print("ask heros")
        PLAYER:send("CS_AskHeros",{
        	playerid = PLAYER:get_playerid()
        })
        -------------------------------
        --请求得到阵形数据
        print("ask formation")
        PLAYER:send("CS_AskFormations",{
        	playerid = PLAYER:get_playerid()
        })
		-------------------------------
		-- 成功 进入主页
		print("change to homescene")
    	switchscene("home",{ transitionType = "crossFade", time = 0.5})
    	-------------------------------
    else
        KNMsg.getInstance():boxShow("登录失败", {
            confirmFun = function()
                switchscene("login")
            end
        })
	end
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------