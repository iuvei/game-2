--
-- Author: Anthony
-- Date: 2014-06-27 18:42:44
--
------------------------------------------------------------------------------
local MapConstants      = require("app.ac.MapConstants")
local eventHandlerModule = import(".MapEventHandler")

GameTimer = require("app.ac.GameTimer").new()
------------------------------------------------------------------------------
local MapRuntime = class("MapRuntime", function()
    return display.newNode()
end)
------------------------------------------------------------------------------
function MapRuntime:ctor(map)

    self.map_                  = map
    self.time_                 = 0 -- 地图已经运行的时间
    self.lastSecond_           = 0 --

    -- local eventHandlerModuleName = string.format("app.character.controllers.%sEvents", getId())

    self.handler_ = eventHandlerModule.new(self, map)

    -- 启用节点事件，确保 onExit 时停止
    self:setNodeEventEnabled(true)

end
------------------------------------------------------------------------------
function MapRuntime:onExit()

end
function MapRuntime:onEnter()
    -- body
end
------------------------------------------------------------------------------
function MapRuntime:init()
    local handler = self.handler_
    handler:init()
end
------------------------------------------------------------------------------
function MapRuntime:tick(dt)
    -- 执行所有的事件
    local handler = self.handler_

    self.time_ = self.time_ + dt
    GameTimer:update(dt)
    local secondsDelta = self.time_ - self.lastSecond_
    -- if secondsDelta >= 0.5 then
    --     self.lastSecond_ = self.lastSecond_ + secondsDelta
    --     if not self.over_ then
    --         handler:time(self.time_, secondsDelta)
    --     end
    -- end
    handler:time(self.time_, secondsDelta)

    -- 更新所有对象
    local maxZOrder = MapConstants.MAX_OBJECT_ZORDER
    for i, object in pairs(self.map_:getAllObjects()) do
        if object:GetModel().tick then
            object:GetModel():tick(dt,self.map_)
        end

        if object:GetModel().fastUpdateView then
            object:GetModel():fastUpdateView()
        end
    end
end
------------------------------------------------------------------------------
return MapRuntime
------------------------------------------------------------------------------