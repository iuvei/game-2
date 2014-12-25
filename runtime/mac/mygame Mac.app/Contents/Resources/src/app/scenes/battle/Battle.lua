--
-- Author: Your Name
-- Date: 2014-07-29 18:08:13
-- 游戏战斗
local MapConstants       = require("app.ac.MapConstants")
local HeroOperateCommand = require("app.character.controllers.commands.HeroOperateCommand")
local HeroInSceneCommand = require("app.character.controllers.commands.HeroInSceneCommand")
local CommonDefine = require("app.ac.CommonDefine")
local CBattle = class("CBattle")
---------------------------------------
--
function CBattle:ctor(mapEvent)
    self.mapEvent_=mapEvent
    self.map_=mapEvent:getMap()
    self.isStart=false
    self.bout=0
    self.label = cc.ui.UILabel.newTTFLabel_({
                            text = "Bout:"..self.bout,
                            size = 30,
                            color = display.COLOR_GREEN,
                        })
                        :pos(100,50)
                        :addTo(self.map_,MapConstants.MAP_Z_3_0)
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
        :addTo(self.map_,MapConstants.MAP_Z_3_0)
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

local function send_fight_end( win, round_count, hero_count, all_hp )
    local fight_info = PLAYER:get_fight_info()
    PLAYER:send("CS_FightEnd",{
        stageId      = fight_info.stageId,
        win          = win,
        cbegin_time  = os.time(),
        cend_time    = os.time(),
        round_count  = round_count,
        count        = hero_count,
        all_hp       = all_hp,
    })
end
---------------------------------------
--
function CBattle:win_()
    -- self.sprite = display.newSprite("scene/battle/scene_battle_win.png",display.cx,display.cy)
    --     :addTo(self.map_,MapConstants.MAP_Z_3_0)

    -- self.sprite:setOpacity(0)

    -- local sequence = transition.sequence({
    --     CCDelayTime:create(0.5),
    --     CCFadeIn:create(0.5),
    -- })
    -- transition.execute( self.sprite,sequence)
    send_fight_end(1,10,5,10)

    self:end_()
end
---------------------------------------
--
function CBattle:lose_()
    -- self.sprite = display.newSprite("scene/battle/scene_battle_lose.png",display.cx,display.cy)
    --     :addTo(self.map_,MapConstants.MAP_Z_3_0)

    -- self.sprite:setOpacity(0)

    -- local sequence = transition.sequence({
    --     CCDelayTime:create(0.5),
    --     CCFadeIn:create(0.5),
    -- })
    -- transition.execute( self.sprite,sequence)
    send_fight_end(0,15,0,0)

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
        self.map_:updataSpecialObj()
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
    for id, object_view in pairs(self.map_:getAllCampObjects(MapConstants.PLAYER_CAMP)) do
        --self.implementQueue[counter]={}
        local object = object_view:GetModel()
        if object:getClassId() == "hero" and not object:isDead() then
           table.insert(self.implementQueue,{objId=object:getId(),
            objIndex=object:getIndex(),
            object_view=object_view,
            speed=object:getAttr1(CommonDefine.RoleAttr_Speed),
            })
        end
    end
    -- 速度排列
    -- if #self.implementQueue > 0 then
    --         table.sort(self.implementQueue,
    --             function(a, b)
    --                 return a.speed > b.speed
    --             end
    --         )
    -- end
    --索引排列
    -- if table.nums(self.implementQueue)>0 then
    --         table.sort(self.implementQueue,
    --             function(a, b)
    --                 return a.objIndex < b.objIndex
    --             end
    --         )
    -- end
    --等级排列
    -- if table.nums(self.implementQueue)>0 then
    --         table.sort(self.implementQueue,
    --             function(a, b)
    --                 return a.obj:GetModel():getLevel() > b.obj:GetModel():getLevel()
    --             end
    --         )
    -- end
    -- for k,v in ipairs(self.implementQueue) do
    --     print("1111updataQueue:"..v.objId)
    -- end
    local enemyQueue={}
    for id, object_view in pairs(self.map_:getAllCampObjects(MapConstants.ENEMY_CAMP)) do
        if object_view and object_view:GetModel():getClassId() == "hero" and not object_view:GetModel():isDead() then
            table.insert(enemyQueue,{objId=object_view:GetModel():getId(),
            objIndex=object_view:GetModel():getIndex(),
            object_view=object_view,
            speed=object_view:GetModel():getAttr1(CommonDefine.RoleAttr_Speed),
            })

        end
    end
    -- 速度排列
    -- if #enemyQueue>0 then
    --         table.sort(enemyQueue,
    --             function(a, b)
    --                 return a.speed > b.speed
    --             end
    --         )
    -- end
    --索引排列
    -- if table.nums(enemyQueue)>0 then
    --         table.sort(enemyQueue,
    --             function(a, b)
    --                 return a.objIndex < b.objIndex
    --             end
    --         )
    -- end
    --等级排列
    -- if table.nums(enemyQueue)>0 then
    --         table.sort(enemyQueue,
    --             function(a, b)
    --                 return a.obj:GetModel():getLevel() > b.obj:GetModel():getLevel()
    --             end
    --         )
    -- end

    for i,v in ipairs(enemyQueue) do
        table.insert(self.implementQueue,v)
    end
    -- 速度排列
    if #self.implementQueue > 0 then
            table.sort(self.implementQueue,
                function(a, b)
                    return a.speed > b.speed
                end
            )
    end

    CommandManager:destroyAllCommands()
    for k,v in ipairs(self.implementQueue) do
        --print("updataQueue:"..v.objId)
        if v.object_view:GetModel():getClassId() == "hero" then
            local opCommand = nil
            if bIn==false then
                opCommand = HeroOperateCommand.new(v.object_view,self.map_,self.mapEvent_)
            else
                opCommand=HeroInSceneCommand.new(v.object_view,self.map_,self.mapEvent_)
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