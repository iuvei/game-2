--
-- Author: Anthony
-- Date: 2014-11-26 18:00:30
-- Filename: SC_FightEnd.lua
--
-- count = 1
return function ( player, args )

	-- local award = {}
	-- print("..begin - >",args.stageId,args.stars)
	-- for i=1,#args.award do
	-- 	print(args.award[i].dataId,args.award[i].num)
	-- 	-- award[i] = {dataId=args.award[i].dataId}
	-- end
	-- print("<- end..")

	-- count = count+1
	-- if count>10 then
	-- 	count =1
	-- end

	-- dump(args.award)

	local run_scene = display.getRunningScene()

	-- local sprite
	-- if args.stars > 0 then
	--     sprite = display.newSprite("scene/battle/scene_battle_win.png",display.cx,display.cy)
 --     else
 --     	sprite = display.newSprite("scene/battle/scene_battle_lose.png",display.cx,display.cy)
	-- end

 --    sprite:setOpacity(0)
 --    run_scene:addChild(sprite)

 --    local sequence = transition.sequence({
 --        CCDelayTime:create(0.5),
 --        CCFadeIn:create(0.5),
 --    })
 --    transition.execute(sprite,sequence)
    if run_scene then
        if run_scene.UIlayer == nil then
            return
        end
        local layers=run_scene.UIlayer:createBattleResult(args)
    end
end