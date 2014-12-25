--
-- Author: Anthony
-- Date: 2014-11-14 11:30:34
-- Filename: ui_helper.lua
--
local ui_helper = {}

function ui_helper:dispatch_event(params)
	-- 发送到所有开着的窗口
	local run_scene = display.getRunningScene()
	if run_scene then
		if run_scene.UIlayer == nil then
			return
		end
		local layers=run_scene.UIlayer:getUiLayers()
        for k,v in pairs(layers) do
            v:ProcessNetResult(params)
        end
		-- for i=1,#layers do
		-- 	layers[i]:ProcessNetResult(params)
		-- end
	end
end

return ui_helper