--
-- Author: Anthony
-- Date: 2014-06-24 16:25:50
--
collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)
------------------------------------------------------------------------------
--
local MapConstants   = require("app.ac.MapConstants")
local EffectChangeHP = require("common.effect.ChangeHP")
local HeroBoutUseSkillCommand = require("app.character.controllers.commands.HeroBoutUseSkillCommand")
local ui_manager = import(".battle_ui_manager")
------------------------------------------------------------------------------
local battle_scene = class("battle_scene", function()
    return display.newScene("battle_scene")
end)
------------------------------------------------------------------------------
function battle_scene:ctor(id_)

    ---------------插入layer---------------------
    -- -- mapLayer 包含地图的整个视图
    self.mapLayer_  = require("app.scenes.battle.map.Map").new(id_)
    self.mapLayer_:init()
    self:addChild(self.mapLayer_)
    -- 开始执行地图
    self.MapRuntime_ = require("app.scenes.battle.map.MapRuntime").new(self.mapLayer_)
    self.MapRuntime_:init()
    self.mapLayer_:addChild(self.MapRuntime_)
    ---------------------------------------------

    -- 注册帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.tick))
    self:scheduleUpdate()

    -- -- UI管理层
    self.UIlayer = ui_manager.new(self)

    self:test()
    -- self.labeltest={}
    -- for i=1,10 do
    --     self.labeltest[#self.labeltest+1]=cc.ui.UILabel.newTTFLabel_({
    --                         text = string.format("tttttttttttt"),
    --                         size = 15,
    --                         color = display.COLOR_GREEN,
    --                     })
    --                     :pos(display.cx,display.cy)
    --                     :addTo(self.mapLayer_,MapConstants.MAP_Z_1_0)
    -- end

end
------------------------------------------------------------------------------
function battle_scene:onExit()

    if self.MapRuntime_ then
        self.MapRuntime_:removeFromParentAndCleanup(true)
        self.MapRuntime_ = nil
    end

    if self.mapLayer_ then
        self.mapLayer_:removeFromParentAndCleanup(true)
        self.mapLayer_ = nil
    end

    cc.TextureCache:getInstance():removeAllTextures()
end
------------------------------------------------------------------------------
function battle_scene:onEnter()
    INIT_FUNCTION.AppExistsListener(self)

end
------------------------------------------------------------------------------
-- 心跳
function battle_scene:tick(dt)

    if self.MapRuntime_ then
        self.MapRuntime_:tick(dt)
    end

end
------------------------------------------------------------------------------
-- 测试相关
function battle_scene:test()
    ------------------------------------------
    --测试按钮
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 30)
        :setButtonLabel(cc.ui.UILabel.new({text = "home"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            -- display.replaceScene( INIT_FUNCTION.reloadModule("app.scenes.home.MainScene").new(),"crossFade", 0.5)
            switchscene("home",{transitionType = "crossFade", time = 0.5})
        end)
        :pos(display.right - 100, display.top - 15)
        :addTo(self)
    cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 30)
        :setButtonLabel(cc.ui.UILabel.new({text = "add skill"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()

            for i, object in pairs(self.mapLayer_:getAllObjects()) do
                print("···",object:GetModel():getId())
                self.mapLayer_:removeObject(object)
                break
            end
            -- local  cmds =CommandManager:getCmds()
            -- local skill_id = 91001--97001--95001--92001--93001--92001--31001
            -- table.insert(cmds,2,HeroBoutUseSkillCommand.new(CommandManager:getFrontCommand().opObj_,self.mapLayer_,skill_id))
            -- self.labeltest:removeSelf()

            -- for i,v in ipairs(self.labeltest) do
            --     print(i,v)
            --     v:removeSelf()
            -- end

        end)
        :pos(display.right - 300, display.top - 15)
        :addTo(self)
    self.btn = cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        :setButtonSize(160, 30)
        :setButtonLabel(cc.ui.UILabel.new({text = "pause"}))
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            if not is_pause then
                display.pause()
                is_pause = true
                self.btn:setButtonLabelString("resume")
            else
                self.btn:setButtonLabelString("pause")
                display.resume()
                is_pause = false
            end

        end)
        :pos(display.right - 500, display.top - 15)
        :addTo(self)
        ------------------------------------------
        -- cc.ui.UIPushButton.new("actor/Button01.png", {scale9 = true})
        -- :setButtonSize(160, 30)
        -- :setButtonLabel(cc.ui.UILabel.new({text = "test"}))
        -- :onButtonPressed(function(event)
        --     event.target:setScale(1.1)
        -- end)
        -- :onButtonRelease(function(event)
        --     event.target:setScale(1.0)
        -- end)
        -- :onButtonClicked(function()
        --     local o = self.mapLayer_:getAllCampObjects(MapConstants.PLAYER_CAMP)
        --     local k = nil
        --     for k,v in pairs(o) do
        --         o=v
        --     end

        --    -- print("44444",v)
        --     EffectChangeHP:run(o,10)
        -- end)
        -- :pos(display.right - 200, display.top - 15)
        -- :addTo(self)
    ------------------------------------------
end
------------------------------------------------------------------------------
return battle_scene
------------------------------------------------------------------------------

