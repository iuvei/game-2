    --
-- Author: Anthony
-- Date: 2014-07-25 16:27:20
--
------------------------------------------------------------------------------
local MapConstants  = require("app.ac.MapConstants")
local SkillDefine   = require("app.character.controllers.skills.SkillDefine")
local DynamicMap    = import(".DynamicMap")
local configMgr     = require("config.configMgr")
local Formation     = require("app.character.views.Formation")
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

    self.ImpactLogicManger_=import("app.character.controllers.skills.LogicManger").new(SkillDefine.LogicType_Impact)
    self.SkillLogicManger_=import("app.character.controllers.skills.LogicManger").new(SkillDefine.LogicType_Skill)
    self.SpecialLogicManger_=import("app.character.controllers.skills.LogicManger").new(SkillDefine.LogicType_Special)
    self.ObjectManager_ = import("app.character.ObjectManager").new()

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
                    -- local rect = display.newRect(cell.rect.size.width,cell.rect.size.height)
                    -- rect:setLineColor(ccc4f(1.0, 1.0, 1.0, 1.0))
                    -- local pos_ = cc.p(cc.rectGetMidX(cell.rect),cc.rectGetMidY(cell.rect))
                    -- rect:setPosition(cc.p(pos_.x,pos_.y))
                    -- rect:addTo(self)

                    -- --if DEBUG_BATTLE.showPos then
                    --     -- 显示tilemap坐标
                    --     self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
                    --         text = cell.posX.." , "..cell.posY,
                    --         size = 15,
                    --         color = display.COLOR_GREEN,
                    --     })
                    --     :pos(rect:getPosition())
                    --     :addTo(self)
                    --     -- 显示tilemap坐标的真实坐标
                    --     self.idLabel_ = cc.ui.UILabel.newTTFLabel_({
                    --         text = rect:getPositionX().." , "..rect:getPositionY(),
                    --         size = 15,
                    --         color = display.COLOR_GREEN,
                    --     })
                    --     :pos(rect:getPositionX(),rect:getPositionY()+20)
                    --     :addTo(self.bgLayer_)
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

    display.addSpriteFrames(Res.plhuoyan , Res.imghuoyan )
    display.addSpriteFrames(Res.pllanhuo ,  Res.imglanhuo)
    display.addSpriteFrames(Res.pltaifeng ,  Res.imgtaifeng)
    display.addSpriteFrames(Res.pldahuoyan , Res.imgdahuoyan )
    display.addSpriteFrames(Res.plshandian , Res.imgshandian )
    display.addSpriteFrames(Res.plzhoushao , Res.imgzhoushao )
    display.addSpriteFrames(Res.plhit , Res.imghit )
    display.addSpriteFrames(Res.plpoison , Res.imgpoison )
    display.addSpriteFrames(Res.plstun , Res.imgstun)
    display.addSpriteFrames(Res.pltrap , Res.imgtrap)
    display.addSpriteFrames("effect/shield.plist" , "effect/shield.png")
    display.addSpriteFrames("common/num_red.plist" , "common/num_red.png")
    display.addSpriteFrames("common/num_green.plist" , "common/num_green.png")
    display.addSpriteFrames("common/num_orange.plist" , "common/num_orange.png")

    -- 背景
    self.bgLayer_ = require("app.scenes.battle.bgLayer").new(self:getId()):addTo(parent)

    -- 批量渲染
    if self.batch_ == nil then
        display.addSpriteFrames(PLIST_CESHI, IMG_CESHI)
        self.batch_ = display.newBatchNode(IMG_CESHI):addTo(parent,MapConstants.MAP_Z_1_0)
    end
    if self.batchBuild_ == nil then
        display.addSpriteFrames(Res.plbuild , Res.imgbuild )
        self.batchBuild_ = display.newBatchNode(Res.imgbuild):addTo(parent,MapConstants.MAP_Z_1_0)
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
            return self:getDMap():worldPosToCellPos(cc.p(x,y))
        end
    end
    return nil
end
------------------------------------------------------------------------------
--
function Map:registerImpactEvent(rReceiver,rSender,ownImpact,isCritcalHit)
    -- 设置暴击
    if isCritcalHit then
        ownImpact.is_crt = isCritcalHit
    end
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
        -- 更新保存的目标,挂掉的要清理
        if rSender and rReceiver:isDestroyed() then
            for i,v in ipairs(rSender.targetAndDepleteParams_.targets) do
                 v:GetModel():isDestroyed()
                 rSender.targetAndDepleteParams_.targets[i]=nil
             end
        end
    end
end
------------------------------------------------------------------------------
-- 根据阵型生成我方
function Map:spawnSelf(parent)

    -- 1. 显示我方(左边)
    local Fdata_ = PLAYER:get_mgr("formations"):get_data()
    local buildData = nil
    for key , v in pairs(Fdata_) do
        local info = v:get_info()
        if info.index>0 and info.GUID>0 then --需要有值
            local pos = Formation:indexToPos(info.index, {
                Left = true,
                getValue = function ( position )
                    return self:getDMap():cellPosToWorldPos(position)
                end
            })

            -- 创建武将，从玩家武将数据得到
            local data = PLAYER:get_mgr("heros"):get_hero_by_GUID(info.GUID)
            self.ObjectManager_:newObject( parent, "hero", data,{ -- parent == self
                x = pos.x,
                y = pos.y,
                flipx = true
            })
            buildData = data
        end
    end
    --建筑
    local pt = self:getDMap():cellPosToWorldPos(cc.p(0,5))
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

    local fid = mapMonster.Fid
    -- local fid = math.random(1,10)

    local count = 0
    self.bulidData = nil
    Formation:build( fid, function ( param, index)

        if not param then return end

        count = count + 1
        local monsterid = mapMonster["heroId"..count]
        -- print("···",monsterid,index)
        -- 没有配置
        if monsterid == nil or monsterid == -1 then return end

        -- 得到坐标
        local pos = Formation:indexToPos( index, {
            getValue = function ( position )
                return self:getDMap():cellPosToWorldPos(position)
            end
        })

        -- 创建武将，数据从表里面生成
        local data = configMgr:getConfig("heros"):GetHeroDataById(monsterid)
        data.campId = MapConstants.ENEMY_CAMP
        self.ObjectManager_:newObject( parent, "hero", data,{
            x = pos.x,
            y = pos.y,
            flipx = false
        })
        self.buildData=data
    end)
    --建筑
    local pt = self:getDMap():cellPosToWorldPos(cc.p(self:getDMap():getMapSize().width-1,5))
    local viewParams = {
            x = pt.x,
            y = pt.y,
            flipx = false
        }
        self.ObjectManager_:newObject( parent, "build",self.buildData,viewParams)
end
------------------------------------------------------------------------------
function Map:scan(options) -- options={out_target_views,cell_positions,target_type,sender_obj_id}
    for k,cell_pos in pairs(options.cell_positions) do
        local obj_view=self:getHeroByCellPos(cell_pos,options.target_type)
        if obj_view then
            -- 是否包含发送者
            local check = true
            if options.is_contain_sender == nil or options.is_contain_sender == false then
                if obj_view:GetModel():getId() == options.sender_obj_id then
                    check = false
                end
            end
            if check then
                table.insert(options.out_target_views,obj_view)
            end
        end
    end
end
function Map:scanByTargetLogic(options) -- options={out_target_views,cell_positions,use_target_type,is_contain_sender,sender_obj}
    local target_camp ="enemy"
    local target_count = nil
    if options.use_target_type == 1 then -- 搜索为单个敌人
        if options.sender_obj:getCampId() == MapConstants.ENEMY_CAMP then
            target_camp = "player"
        end
    elseif options.use_target_type == 2 then -- 搜索对全体敌人
        if options.sender_obj:getCampId() == MapConstants.ENEMY_CAMP then
            target_camp = "player"
        end
        target_count=-1
    elseif options.use_target_type == 3 then -- 搜索为单个队友
        if options.sender_obj:getCampId() == MapConstants.PLAYER_CAMP then
            target_camp = "player"
        end
    elseif options.use_target_type == 4 then -- 搜索为全体队友
       if options.sender_obj:getCampId() == MapConstants.PLAYER_CAMP then
            target_camp = "player"
        end
        target_count=-1
    elseif options.use_target_type == 5 then -- 全场
        target_camp = "all"
        target_count=-1
    elseif options.use_target_type == 0 then -- 自己
        table.insert(options.out_target_views,options.sender_obj:getView())
        return true
    elseif options.use_target_type == 7 then
        if options.sender_obj:getCampId() == MapConstants.ENEMY_CAMP then
            target_camp = "player"
        end
    end
    assert(target_camp~=nil,"scanByTarget() faild!")
    assert(#options.cell_positions>0,"options.cell_positions == 0")
    -- －1＝阵营的所有目标
    if target_count == -1 then
        -- options.out_target_views = self:getHeros(target_camp)
         local object_views = self:getHeros(target_camp)
         for k,obj_view in pairs(object_views) do
            local obj = obj_view:GetModel()
            -- 是否包含发送者
            local check = true
            if options.is_contain_sender == nil or options.is_contain_sender == false then
                if obj:getId() == options.sender_obj:getId() then
                    check = false
                end
            end
            if check and obj:getClassId() == "hero" and not obj:isDead() then
                table.insert(options.out_target_views,obj_view)
            end
         end
    else
        -- 根据位置找到对应的目标
        for k,cell_pos in pairs(options.cell_positions) do
            local obj_view =self:getHeroByCellPos(cell_pos,target_camp)
            if obj_view then
                local obj = obj_view:GetModel()
                -- 是否包含发送者
                local check = true
                if options.is_contain_sender == nil or options.is_contain_sender == false then
                    if obj:getId() == options.sender_obj:getId() then
                        check = false
                    end
                end
                -- 数量
                -- if target_count == 0 then
                --     break
                -- end
                if check then
                    -- target_count = target_count - 1
                    table.insert(options.out_target_views,obj_view)
                end
            end
        end
    end

end
function Map:getCampTypeByTargetLogic(target_logic,camp_id)
    local target_camp ="enemy"
    if target_logic== 1 then -- 搜索为单个敌人
        if camp_id == MapConstants.ENEMY_CAMP then
            target_camp = "player"
        end
    elseif target_logic == 2 then -- 搜索对全体敌人
        if camp_id == MapConstants.ENEMY_CAMP then
            target_camp = "player"
        end
    elseif target_logic == 3 then -- 搜索为单个队友
        if camp_id == MapConstants.PLAYER_CAMP then
            target_camp = "player"
        end
    elseif target_logic == 4 then -- 搜索为全体队友
       if camp_id == MapConstants.PLAYER_CAMP then
            target_camp = "player"
        end
    elseif target_logic == 5 then -- 全场
        target_camp = "all"
    elseif target_logic == 0 then -- 自己
        target_camp = "self"
    end
    return target_camp
end
function Map:getHeroByCellPos(cellPos,target_type)
    local objects = self:getHeros(target_type)
    for id, object in pairs(objects) do
        if object and object:GetModel():getClassId() == "hero" and not object:GetModel():isDead() then
            --if object:GetModel():getId() ~= selfObj:GetModel():getId() then
                local x,y= object:getPosition()
                local pos = self:getDMap():worldPosToCellPos(cc.p(x, y))
                if pos.x==cellPos.x and pos.y==cellPos.y then
                    return object
                end
            --end
        end
    end
    return nil
end
function Map:getHeros(camp_type)
    local objects = self:getAllObjects()
    camp_type = camp_type or "all"
    if camp_type == "player" then -- 目标为自己阵营
        objects = self:getAllCampObjects(MapConstants.PLAYER_CAMP)
    elseif camp_type == "enemy" then -- 目标为敌方阵营
        objects = self:getAllCampObjects(MapConstants.ENEMY_CAMP)
    end
    return objects
end
------------------------------------------------------------------------------
function Map:updataSpecialObj()
    local remove_objs = {}
    local objects = self.ObjectManager_:getObjectsByClassId("special_obj")
    for k,v in pairs(objects) do
        local obj= v:GetModel()
        if obj:IsActiveObj() then
            obj:OnUpdata()
            if not obj:IsActiveObj() then
                table.insert(remove_objs,v)
            end
        else
            table.insert(remove_objs,v)
        end
    end
    for i,v in ipairs(remove_objs) do
        self.ObjectManager_:removeObject(v)
    end
end
function Map:updataTrigger(obj)
    local objects = self.ObjectManager_:getObjectsByClassId("special_obj")
    for k,v in pairs(objects) do
        v:GetModel():OnUpdataAndTriggerObj(obj)
    end
end
------------------------------------------------------------------------------
return Map
------------------------------------------------------------------------------