    --
-- Author: Anthony
-- Date: 2014-07-25 16:27:20
--
------------------------------------------------------------------------------
local MapConstants = require("app.controllers.MapConstants")
local SkillDefine=require("app.controllers.skills.SkillDefine")
local DynamicMap=import(".DynamicMap")
local configMgr = require("config.configMgr")
local Formation = require("app.views.Formation")
------------------------------------------------------------------------------
-- 图片资源
------------------------------------------------------------------------------
local PLIST_CESHI        = "actor/ceshi.plist"
local IMG_CESHI          = "actor/ceshi.png"
------------------------------------------------------------------------------
local Map = class("Map", function()
    return display.newLayer()
end)
------------------------------------------------------------------------------
function Map:ctor(id)
    self.id_               = id -- 地图编号
    self.ready_            = false
    self.batch_            = nil
    self.batchBuild_       = nil
    self.dMap_             = nil

    self.ImpactLogicManger_=import("app.controllers.skills.LogicManger").new(SkillDefine.LogicType_Impact)
    self.SkillLogicManger_=import("app.controllers.skills.LogicManger").new(SkillDefine.LogicType_Skill)

    self.ObjectManager_ = import("app.controllers.ObjectManager").new()

    self:setNodeEventEnabled(true)

end
------------------------------------------------------------------------------
function Map:init()

    self.ObjectManager_:init()
    -- 创建视图
    self:createView(self)

    if DEBUG_BATTLE.showDMapInfo then
        for y=1,self:getDMap():getMapSize().height do
            for x=1,self:getDMap():getMapSize().width do
               local cell = self:getDMap():getMapCell(x-1, y-1)
                --local pos_ =
                    local rect = display.newRect(cell.rect.size.width,cell.rect.size.height)
                    rect:setLineColor(ccc4f(1.0, 1.0, 1.0, 1.0))
                    local pos_ = ccp(cell.rect:getMidX(),cell.rect:getMidY())
                    rect:setPosition(ccp(pos_.x,pos_.y))
                    rect:addTo(self)

                    --if DEBUG_BATTLE.showPos then
                        -- 显示tilemap坐标
                        self.idLabel_ = ui.newTTFLabel({
                            text = cell.posX.." , "..cell.posY,
                            size = 15,
                            color = display.COLOR_GREEN,
                        })
                        :pos(rect:getPosition())
                        :addTo(self)
                        -- 显示tilemap坐标的真实坐标
                        self.idLabel_ = ui.newTTFLabel({
                            text = rect:getPositionX().." , "..rect:getPositionY(),
                            size = 15,
                            color = display.COLOR_GREEN,
                        })
                        :pos(rect:getPositionX(),rect:getPositionY()+20)
                        :addTo(self.bgLayer_)
                   -- end
            end
        end
    end

    -- 地图已经准备好
    self.ready_ = true
end
------------------------------------------------------------------------------
function Map:onExit()

    self.ready_ = false

    display.removeSpriteFramesWithFile(PLIST_CESHI, IMG_CESHI)
    display.removeSpriteFramesWithFile(Res.plbuild, Res.imgbuild )

    if self.bgLayer_ then
        self.bgLayer_:removeFromParentAndCleanup(true)
        self.bgLayer_ = nil
    end
end
------------------------------------------------------------------------------
-- 创建视图
function Map:createView(parent)

    display.addSpriteFramesWithFile(Res.plhuoyan , Res.imghuoyan )
    display.addSpriteFramesWithFile(Res.pllanhuo ,  Res.imglanhuo)
    display.addSpriteFramesWithFile(Res.pltaifeng ,  Res.imgtaifeng)
    display.addSpriteFramesWithFile(Res.pldahuoyan , Res.imgdahuoyan )
    display.addSpriteFramesWithFile(Res.plshandian , Res.imgshandian )
    display.addSpriteFramesWithFile(Res.plzhoushao , Res.imgzhoushao )
    display.addSpriteFramesWithFile(Res.plhit , Res.imghit )
    display.addSpriteFramesWithFile(Res.plpoison , Res.imgpoison )
    display.addSpriteFramesWithFile(Res.plstun , Res.imgstun)

    -- 背景
    self.bgLayer_ = require("app.scenes.battle.bgLayer").new(self:getId()):addTo(parent)

    -- 批量渲染
    if self.batch_ == nil then
        display.addSpriteFramesWithFile(PLIST_CESHI, IMG_CESHI)
        self.batch_ = display.newBatchNode(IMG_CESHI):addTo(parent)
    end
    if self.batchBuild_ == nil then
        display.addSpriteFramesWithFile(Res.plbuild , Res.imgbuild )
        self.batchBuild_ = display.newBatchNode(Res.imgbuild):addTo(parent)
    end
    self.dMap_=DynamicMap.new(self,self:getBgMapSize().width,self:getBgMapSize().height)
    -- 生成obj
    self:spawnWithFormation(parent)
end
------------------------------------------------------------------------------
--返回地图的 Id
function Map:getId()
    return self.id_
end
------------------------------------------------------------------------------
--返回地图尺寸
function Map:getTileSize()
    return self.bgLayer_:getTileMapSize()
end
------------------------------------------------------------------------------
--地图大小
function Map:getBgMapSize()
    return self.bgLayer_:getTileMap():getMapSize()
end
------------------------------------------------------------------------------
function Map:getCellCenterPos(x,y)
    return self.bgLayer_:getCellCenterPos(x,y)
end
------------------------------------------------------------------------------
function Map:getTileMap()
    return self.bgLayer_.TileMap_
end
------------------------------------------------------------------------------
function Map:getlayergroud()
    return  self.bgLayer_:getlayergroud()
end
------------------------------------------------------------------------------
-- 得到对象管理器
function Map:getObjectManager()
    return self.ObjectManager_
end
------------------------------------------------------------------------------
-- 得到所有对象
function Map:getAllObjects()
    return self.ObjectManager_:getAllObjects()
end
------------------------------------------------------------------------------
-- 得到对应阵营的对象集合
function Map:getAllCampObjects(campId)
    return self.ObjectManager_:getObjectsByCamp(campId)
end
------------------------------------------------------------------------------
-- 得到对象
function Map:getObject(objId)
    return self.ObjectManager_:getObject(objId)
end
function Map:getObjectReal(objId)
    local v = self.ObjectManager_:getObject(objId)
    if v then
        return v:GetModel()
    end
    return nil
end
------------------------------------------------------------------------------
-- 删除对象
function Map:removeObject(obj)
    return self.ObjectManager_:removeObject(obj)
end
------------------------------------------------------------------------------
-- 得到批量渲染
function Map:GetBatch(classId)
    if classId == "hero" then
       return self.batch_
    elseif classId == "build" then
        return self.batchBuild_
    else
        return self
    end
end
------------------------------------------------------------------------------
--
function Map:getDMap()
    return self.dMap_
end
------------------------------------------------------------------------------
--
function Map:getHeroByCellPos(cellPos)
    for id, object in pairs(self:getAllObjects()) do
        if object and not object:GetModel():isDead() then
            --if object:GetModel():getId() ~= selfObj:GetModel():getId() then
                local x,y= object:getPosition()
                local pos = self:getDMap():worldPosToCellPos(ccp(x, y))
                if pos.x==cellPos.x and pos.y==cellPos.y then
                    return object
                end
            --end
        end
    end
    return nil
end
------------------------------------------------------------------------------
-- 根据阵型生成
function Map:spawnWithFormation(parent)
    self:spawnSelf(parent)
    self:spawnEnemy(parent)
end
------------------------------------------------------------------------------
--
function Map:getAktBuildByCamp(camp)
    for id, object in pairs(self:getAllCampObjects(camp)) do
        if object and object:GetModel():getClassId()=="build" then
            local x,y = object:getPosition()
            return self:getDMap():worldPosToCellPos(ccp(x,y))
        end
    end
    return nil
end
------------------------------------------------------------------------------
--
function Map:registerImpactEvent(rReceiver,rSender,ownImpact)
    if rSender~=nil then
        ownImpact:setCasterObjId(rSender:getId())
    end
    if rReceiver~=nil then
        if rReceiver:isDestroyed() then
            return
        end
        if rReceiver:isUnbreakable() then
        else
            local ret = rReceiver:onFiltrateImpact(ownImpact)
            if  ret==true then
            else
                rReceiver:Impact_RegisterImpact(ownImpact)
            end
        end
    end
end
------------------------------------------------------------------------------
-- 根据阵型生成我方
function Map:spawnSelf(parent)

    -- 1. 显示我方(左边)
    local Fdata_ = DATA_Formation:get_data()
    local buildData = nil
    for key , v in pairs(Fdata_) do

        local pos = Formation:indexToPos(v.index, {
            Left = true,
            getValue = function ( position )
                return self:getDMap():cellPosToWorldPos(position)
            end
        })

        -- 创建武将
        local data = configMgr:getConfig("heros"):GetHeroDataById(v.dataID,MapConstants.PLAYER_CAMP)
        self.ObjectManager_:newObject( parent, "hero", data,{
            x = pos.x,
            y = pos.y,
            flipx = true
        })
        buildData = data
    end
    --建筑
    local pt = self:getDMap():cellPosToWorldPos(ccp(0,5))
    local viewParams = {
            x = pt.x,
            y = pt.y,
            flipx = true
        }
    self.ObjectManager_:newObject( parent, "build",buildData,viewParams)
end

------------------------------------------------------------------------------
-- 根据配置生成敌方
function Map:spawnEnemy(parent)

    local config = configMgr:getConfig("stages")
    local mapMonster = config:getMonstersByStageId(self:getId())

    local fid = mapMonster[1].Fid
    -- local fid = math.random(1,10)

    local count = 0
    self.bulidData = nil
    Formation:build( fid, function ( param, index)

        if not param then return end

        count = count + 1
        local monster = mapMonster[count]
        -- 没有配置
        if monster == nil then return end

        -- 得到坐标
        local pos = Formation:indexToPos( index, {
            getValue = function ( position )
                return self:getDMap():cellPosToWorldPos(position)
            end
        })

        -- 创建武将
        local data = configMgr:getConfig("heros"):GetHeroDataById(monster.HeorId,MapConstants.ENEMY_CAMP)
        self.ObjectManager_:newObject( parent, "hero", data,{
            x = pos.x,
            y = pos.y,
            flipx = false
        })
        self.buildData=data
    end)
    --建筑
    local pt = self:getDMap():cellPosToWorldPos(ccp(self:getDMap():getMapSize().width-1,5))
    local viewParams = {
            x = pt.x,
            y = pt.y,
            flipx = false
        }
        self.ObjectManager_:newObject( parent, "build",self.buildData,viewParams)
end
------------------------------------------------------------------------------
return Map
------------------------------------------------------------------------------