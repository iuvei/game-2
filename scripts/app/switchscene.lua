--[[

切换场景

** Param **
	name 场景名
	tempdata 临时变量，可传递到下一个场景
	callback 回调函数

]]
function switchscene( name , params)
--	local cur_scene = display.getRunningScene()
--	if cur_scene and cur_scene["name"] == name then return end

	if params == nil then params ={} end

	-- 不联网版本
	if CHANNEL_ID ~= "test" then
		if name == "login" then
			-- 是login，则重置网络
			NETWORK:reset()
		end
	end

	-- 去掉所有未完成的动作
	CCDirector:sharedDirector():getActionManager():removeAllActions()

	local scene_file = "app.scenes."..name.."."..name.."scene"

	-- echoLog("Scene" , "Load Scene [" .. name .. "]")
	display.replaceScene( require(scene_file).new(params.tempdata),params.transitionType, params.time)

	if type(params.callback) == "function" then
		-- 必须延迟，不然会在替换场景之前执行
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			params.callback()
		end , 0.1 , false)

	end
end

function pushscene(name,params)
	local scene = require("app.scenes."..name..".scene")

	CCDirector:sharedDirector():pushScene(scene:new(params))
end

function popscene()
	CCDirector:sharedDirector():popScene()
end

