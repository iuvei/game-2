--
-- Author: Your Name
-- Date: 2014-07-29 18:08:13
-- 游戏战斗
local MapConstants = require("app.controllers.MapConstants")
local HeroOperateCommand = require("app.controllers.commands.HeroOperateCommand")
local HeroInSceneCommand = require("app.controllers.commands.HeroInSceneCommand")
local CBattle = class("CBattle")
---------------------------------------
--
function CBattle:ctor(mapEvent)
    self.mapEvent_=mapEvent
    self.map_=mapEvent:getMap()
    self.isStart=false
    self.bout=0
    self.label = ui.newTTFLabel({
                            text = "Bout:"..self.bout,
                            size = 30,
                            color = display.COLOR_GREEN,
                        })
                        :pos(ccp(100,50))
                        :addTo(self.map_)
end
---------------------------------------
--
function CBattle:init_()

    self:updataQueue_(true)
    self:ready_()
end
---------------------------------------
--
function CBattle:ready_()

    self.sprite = display.newSprite("scene/battle/scene_battle_start.png",display.cx,display.cy)
        :addTo(self.map_)
    self.sprite:setOpacity(0)

    local sequence = transition.sequence({
        CCDelayTime:create(0.5),
        CCFadeIn:create(0.5),
        CCDelayTime:create(0.2),
        CCEaseExponentialIn:create(CCFadeOut:create(0.5)),
        CCDelayTime:create(0.5),
    })
    transition.execute( self.sprite,sequence,{
        onComplete = function()
            self:start_()
            self.sprite:removeFromParent()
        end,
    })
end
---------------------------------------
--
function CBattle:start_()
    self.isStart=true
end
---------------------------------------
--
function CBattle:isStart_()
    return self.isStart
end
---------------------------------------
--
function CBattle:end_()
    self.isStart=false
end
---------------------------------------
--
function CBattle:win_()
    self.sprite = display.newSprite("scene/battle/scene_battle_win.png",display.cx,display.cy)
        :addTo(self.map_)

    self.sprite:setOpacity(0)

    local sequence = transition.sequence({
        CCDelayTime:create(0.5),
        CCFadeIn:create(0.5),
    })
    transition.execute( self.sprite,sequence)

    self:end_()
end
---------------------------------------
--
function CBattle:lose_()
    self.sprite = display.newSprite("scene/battle/scene_battle_lose.png",display.cx,display.cy)
        :addTo(self.map_)

    self.sprite:setOpacity(0)

    local sequence = transition.sequence({
        CCDelayTime:create(0.5),
        CCFadeIn:create(0.5),
    })
    transition.execute( self.sprite,sequence)

    self:end_()
end
---------------------------------------
--
function CBattle:pause_()
end
---------------------------------------
--
function CBattle:resume_()

end
---------------------------------------
--
function CBattle:run_()
    if self:isEnd() then
        return
    end
    if CommandManager:isEmpty() then
        self:updataQueue_()
    else
        CommandManager:updata()
    end
end
-----------------------------------------
--
function CBattle:isEnd()
    local isHasSelfBuild = false
    local isHasEnemyBuild = false

    local counter = 0
    for id, object in pairs(self.map_:getAllCampObjects(MapConstants.PLAYER_CAMP)) do
        if object:GetModel():getClassId()=="build" then
            isHasSelfBuild=true
        end
        if object:GetModel():getClassId()=="hero" then
            counter = counter+1
        end
    end
    if counter<=0 then
        self:lose_()
        return true
    end
    counter=0
    for id, object in pairs(self.map_:getAllCampObjects(MapConstants.ENEMY_CAMP)) do
        if object:GetModel():getClassId()=="build" then
            isHasEnemyBuild = true
        end
        if object:GetModel():getClassId()=="hero" then
            counter = counter+1
        end
    end
    if counter<=0 then
        self:win_()
        return true
    end
    if isHasSelfBuild == false then
        self:lose_()
        return true
    end
    if isHasEnemyBuild == false then
        self:win_()
        return true
    end
    return false
end
----------------------------------------------------------------
--更新执行队列
function CBattle:updataQueue_(bInScene)
    local bIn = bInScene or false
    self.implementQueue={}
    for id, object in pairs(self.map_:getAllCampObjects(MapConstants.PLAYER_CAMP)) do
        --self.implementQueue[counter]={}
        if object and not object:GetModel():isDead() then

           table.insert(self.implementQueue,{objId=object:GetModel():getId(),
            objIndex=object:GetModel():getIndex(),
            obj=object
            })
        end
    end
    --索引排列
    if table.nums(self.implementQueue)>0 then
            table.sort(self.implementQueue,
                function(a, b)
                    return a.objIndex < b.objIndex
                end
            )
    end
    --等级排列
    if table.nums(self.implementQueue)>0 then
            table.sort(self.implementQueue,
                function(a, b)
                    return a.obj:GetModel():getLevel() > b.obj:GetModel():getLevel()
                end
            )
    end
    -- for k,v in ipairs(self.implementQueue) do
    --     print("1111updataQueue:"..v.objId)
    -- end
    local enemyQueue={}
    for id, object in pairs(self.map_:getAllCampObjects(MapConstants.ENEMY_CAMP)) do
        if object and not object:GetModel():isDead() then
            table.insert(enemyQueue,{objId=object:GetModel():getId(),
            objIndex=object:GetModel():getIndex(),
            obj=object
            })

        end
    end
    --索引排列
    if table.nums(enemyQueue)>0 then
            table.sort(enemyQueue,
                function(a, b)
                    return a.objIndex < b.objIndex
                end
            )
    end
    --等级排列
    if table.nums(enemyQueue)>0 then
            table.sort(enemyQueue,
                function(a, b)
                    return a.obj:GetModel():getLevel() > b.obj:GetModel():getLevel()
                end
            )
    end

    for i,v in ipairs(enemyQueue) do
        table.insert(self.implementQueue,v)
    end

    CommandManager:destroyAllCommands()
    for k,v in ipairs(self.implementQueue) do
        --print("updataQueue:"..v.objId)
        if v.obj:GetModel():getClassId() == "hero" then
            local opCommand = nil
            if bIn==false then
                opCommand = HeroOperateCommand.new(v.obj,self.map_,self.mapEvent_)
            else
                opCommand=HeroInSceneCommand.new(v.obj,self.map_,self.mapEvent_)
            end
            CommandManager:addCommand(opCommand)
        end
    end
    self.bout=self.bout+1
    self.label:setString("Bout:"..self.bout)
end
---------------------------------------
--
return CBattle