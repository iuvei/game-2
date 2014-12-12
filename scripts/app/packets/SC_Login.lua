--
-- Author: Anthony
-- Date: 2014-08-29 11:41:44
-- SC_Login.lua

return function ( player, args )

	if args.success then

		-------------------------------
		-- 玩家基础数据
        args.content.playerid = args.playerid
        player:init_basedata(args.content)
        printInfo("login gameserver success, playerid:%d",player:get_playerid() )
        -- dump(player:get_basedata())
		-------------------------------
		-- 请求得到英雄数据
		printInfo("ask heros")
        player:send("CS_AskInfo",{ type = 1 })
        -------------------------------
        --请求得到背包
        printInfo("ask itembag")
        player:send("CS_AskInfo",{ type = 2 })
        -------------------------------
        --请求得到阵形数据
        printInfo("ask formation")
        player:send("CS_AskInfo",{ type = 3 })
        -------------------------------
        -- 关卡数据
        printInfo("ask stage")
        player:send("CS_AskInfo",{ type = 4 })

        -------------------------------
        -- test
            PLAYER:send("CS_Command",{
                content = "createhero 1001"
            })
            PLAYER:send("CS_Command",{
                content = "createhero 2001"
            })
            PLAYER:send("CS_Command",{
                content = "createhero 3001"
            })
            PLAYER:send("CS_Command",{
                content = "createhero 4001"
            })
            PLAYER:send("CS_Command",{
                content = "createhero 5001"
            })
            PLAYER:send("CS_Command",{
                content = "createhero 6001"
            })
        -- test
        -------------------------------

        -- -------------------------------
        -- -- 成功 进入主页
        -- printInfo("change to homescene")
        -- switchscene("home",{ transitionType = "crossFade", time = 0.5})
        -- -------------------------------
    else
        KNMsg.getInstance():boxShow("登录失败", {
            confirmFun = function()
                switchscene("login")
            end
        })
	end
end