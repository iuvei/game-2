--
-- Author: Anthony
-- Date: 2014-06-24 16:30:19
--
------------------------------------------------------------------------------
--MapManager= require("app.character.controllers.MapManager")
local configMgr = require("config.configMgr")
CommandManager= require("app.character.controllers.commands.CommandManager")
HeroOperateManager= require("app.character.controllers.commands.HeroOperateManager")
AStarUtil= require("common.astar.AStarUtil")
SkillCore = require("app.character.controllers.skills.skillLogics.SkillCore")
ImpactCore = require("app.character.controllers.skills.impactLogics.ImpactCore")
------------------------------------------------------------------------------
local bgLayer  = class("bgLayer", function()
    return display.newLayer()
end)
------------------------------------------------------------------------------
function bgLayer:ctor(id)
    local config = configMgr:getConfig("stages")
    local stage = config:getStage(id)
    local mapRes = config:getMapResByStageId(stage.mapResId)

    -- 背景
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    self.bgSprite_ = display.newSprite(mapRes.Bg,display.cx,display.cy)
        :addTo(self)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- self.bgSprite_:align(display.LEFT_BOTTOM, 0, 0)

    -- 屏幕自适应
    local mapcontent = self.bgSprite_:getContentSize()
    self.bgSprite_:setScaleX(INIT_FUNCTION.width/mapcontent.width);
    self.bgSprite_:setScaleY(INIT_FUNCTION.height/mapcontent.height);

    -- self.bgSprite_:addNodeEventListener(cc.NODE_EVENT, function(event)
    --     -- 地图对象删除时，自动从缓存里卸载地图材质
    --     if event.name == "exit" then
    --         display.removeSpriteFrameByImageName("scene/battle/bg.jpg")
    --     end
    -- end)

    -- tilemap
    self.TileMap_ = CCTMXTiledMap:create("scene/battle/Level0.tmx"):addTo(self)
    self.TileMap_:setAnchorPoint(cc.p(0, 0))
    self.TileMap_:setVisible(false) --不显示

    -- 屏幕自适应
    local mapcontent = self.TileMap_:getContentSize()
    self.TileMap_:setScaleX(INIT_FUNCTION.width/mapcontent.width);
    self.TileMap_:setScaleY(INIT_FUNCTION.height/mapcontent.height);

    self.tileSize_ = {   width  =  math.round(self.TileMap_:getTileSize().width*self.TileMap_:getScaleX()),
                        height =  math.round(self.TileMap_:getTileSize().height*self.TileMap_:getScaleY())
                    }

    self:ShowTileMapCell()

    CommandManager:init()
    HeroOperateManager:init()

    -- 显示地图名字
    self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
            text = string.format("%s", stage.Name),
            size = 25,
            color = display.COLOR_WHITE,
        })
        :pos(display.left+100, display.top - 20)
        :addTo(self)

end
------------------------------------------------------------------------------
function bgLayer:getTileMap()
    return self.TileMap_
end
------------------------------------------------------------------------------
function bgLayer:getlayergroud()
    return  self.TileMap_:layerNamed("ground")
end
------------------------------------------------------------------------------
function bgLayer:getTileMapSize()
    return self.tileSize_
end
------------------------------------------------------------------------------
function bgLayer:getCellCenterPos(x,y)
    local pos_ = {  x = math.floor(x*self.TileMap_:getScaleX() + self.tileSize_.width/2),
                    y = math.floor(y*self.TileMap_:getScaleY() + self.tileSize_.height/2)
                }
    return pos_
end
------------------------------------------------------------------------------
function bgLayer:ShowTileMapCell()
        -- 显示格子
    if DEBUG_BATTLE.showRect then

        for x=0,self.TileMap_:getMapSize().width-1 do
            for y=0,self.TileMap_:getMapSize().height-1 do
                local pos = self.TileMap_:layerNamed("ground"):positionAt(cc.p(x,y))
                local rect = display.newRect(self.tileSize_.width,self.tileSize_.height)
                rect:setLineColor(ccc4f(1.0, 1.0, 1.0, 1.0))
                local pos_ = self:getCellCenterPos(pos.x,pos.y)
                rect:setPosition(cc.p(pos_.x,pos_.y))
                rect:addTo(self)

                if DEBUG_BATTLE.showPos then
                    -- 显示tilemap坐标
                    -- self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
                    --     text = x.." , "..y,
                    --     size = 15,
                    --     color = display.COLOR_GREEN,
                    -- })
                    -- :pos(rect:getPositionX(),rect:getPositionY())
                    -- :addTo(self)
                    -- -- 显示tilemap坐标的真实坐标
                    -- self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
                    --     text = rect:getPositionX().." , "..rect:getPositionY(),
                    --     size = 15,
                    --     color = display.COLOR_GREEN,
                    -- })
                    -- :pos(rect:getPositionX(),rect:getPositionY()+20)
                    -- :addTo(self)
                end
            end
        end
    end
end
------------------------------------------------------------------------------
return bgLayer
------------------------------------------------------------------------------