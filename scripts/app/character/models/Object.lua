--
-- Author: Anthony
-- Date: 2014-06-24 16:30:19
------------------------------------------------------------------------------
-- 全局的行为管理器
BehaviorsManager    = import("..controllers.behaviors.BehaviorsManager")

local MapConstants  = require("app.ac.MapConstants")
local CommonDefine  = require("common.CommonDefine")
local math2d        = require("common.math2d")
------------------------------------------------------------------------------
--[[--
”Object“类
]]
------------------------------------------------------------------------------
local Object = class("Object", cc.mvc.ModelBase)
------------------------------------------------------------------------------
-- 常量
Object.ATTACK_COOLDOWN = 1 -- 攻击冷却时间
------------------------------------------------------------------------------
-- 定义事件
Object.CHANGE_STATE_EVENT    = "CHANGE_STATE_EVENT"
Object.START_EVENT           = "START_EVENT"             -- 待机
Object.MOVE_EVENT            = "MOVE_EVENT"              -- 移动
Object.STOP_EVENT            = "STOP_EVENT"              -- 停止
Object.BEATTACK_EVENT        = "BEATTACK_EVENT"          -- 被攻击
Object.READY_EVENT           = "READY_EVENT"             -- 攻击冷却结束
Object.BEKILL_EVENT          = "BEKILL_EVENT"            -- 被杀死
Object.RELIVE_EVENT          = "RELIVE_EVENT"            -- 重生
Object.HP_CHANGED_EVENT      = "HP_CHANGED_EVENT"        -- HP变化
Object.FINISH_EVENT          = "FINISH_EVENT"
Object.ENTER_ATTACKING       = "ENTER_ATTACKING"         -- 开始进行攻击
Object.ATTACK_EVENT          = "ATTACK_EVENT"            -- 攻击完成
Object.BEFORE_EVENT          = "BEFORE_EVENT"
Object.BEATTACK_OVER_EVENT   = "BEATTACK_OVER_EVENT"
------------------------------------------------------------------------------
-- 定义属性
------------------------------------------------------------------------------
Object.schema = clone(cc.mvc.ModelBase.schema)
Object.schema["nickname"]          = {"string"}        -- 名字，没有默认值
Object.schema["typename"]          = {"string"}        -- 类型
Object.schema["speed"]             = {"number", 1}     -- 移动速度
Object.schema["hit"]               = {"number", 100}   -- 基础命中率
-- Object.schema["dir"]               = {"number", 1}     -- 方向
Object.schema["campId"]            = {"number", 0}     -- 阵营
Object.schema["level"]             = {"number", 1}     -- 等级，默认值 1
Object.schema["hp"]                = {"number", 1}     -- HP
Object.schema["maxHp"]             = {"number", 1}     -- 最大HP
Object.schema["attack"]            = {"number", 1}     -- 攻击力
Object.schema["attackZhanFa"]      = {"number", 1}     -- 战法攻击力
Object.schema["attackJiCe"]        = {"number", 1}     -- 计策力
Object.schema["defense"]           = {"number", 1}     -- 防御力
Object.schema["rng"]               = {"number", 1}     --
Object.schema["artId"]             = {"number", 1001}  -- 美术ID
Object.schema["formationId"]       = {"number", 1}     -- 武将阵形，策划设定为 性格
Object.schema["ArmId"]             = {"number", 1}     -- 兵种编号
Object.schema["maxRage"]           = {"number", 100}   -- 最大怒气值
------------------------------------------------------------------------------
function Object:ctor(properties,map)
    Object.super.ctor(self, properties)
    self.view_ = nil
    self.map_ = map
    self.intAttrs={}
end
------------------------------------------------------------------------------
-- 类开始处理
------------------------------------------------------------------------------
function Object:init()
    if self.behaviors_ == nil then
        -- 默认绑定AI行为
        self.behaviors_  = {"AICharacterBehavior"}
    end
    BehaviorsManager:initBehaviors(self)
end
------------------------------------------------------------------------------
-- id由 类型:递增编号 组成,例："hero:1","hero:2"
function Object:getId()
    return self.id_
end
------------------------------------------------------------------------------
--
function Object:getClassId()
    local classId, index = unpack(string.split(self.id_, ":"))
    return classId
end
------------------------------------------------------------------------------
-- 递增编号
function Object:getIndex()
    local classId, index = unpack(string.split(self.id_, ":"))
    return tonumber(index)
end
------------------------------------------------------------------------------
function Object:getType()
    return self.typename_
end
------------------------------------------------------------------------------
function Object:getArmId()
    return self.ArmId_
end
------------------------------------------------------------------------------
-- 名字，没有默认值
function Object:getNickname()
    return self.nickname_
end
------------------------------------------------------------------------------
function Object:getLevel()
    return self.level_
end
------------------------------------------------------------------------------
--攻击
--基本物理攻击
function Object:getBaseAttackPhysics()
    return self.attack_
end
--物理攻击
function Object:getAttackPhysics()
    return self:getBaseAttackPhysics()
end
--战法
function Object:getBaseAttackZhanFa()
    return self.attackZhanFa_
end
--计策
function Object:getBaseAttackJiCe()
    return self.attackJiCe_
end
------------------------------------------------------------------------------
--防御
function Object:getBaseDefensePhysics()
    return self.defense_
end
--物理防御
function Object:getDefensePhysice()
    return self:getBaseDefensePhysics()
end
------------------------------------------------------------------------------
--基本最大怒气值
function Object:getBaseMaxRage()
    return self.maxRage_
end
------------------------------------------------------------------------------
--基本最大Hp值
function Object:getBaseMaxHp()
    return self.maxHp_
end
------------------------------------------------------------------------------
function Object:setFullHp()
    self.hp_ = self:getMaxHp()
    return self.hp_
end
----------------------------------------
--
 function Object:getMaxHp()
    local value = self:getBaseMaxHp() + self:getMaxHpRefix()
    return value
end
----------------------------------------
--
 function Object:setMaxHp( maxHp)
    maxHp = checkint(maxHp)
    assert(maxHp > 0, string.format("DestroyedBehavior.setMaxHp() - invalid maxHp %s", tostring(maxHp)))
    self.maxHp_ = maxHp
end
----------------------------------------
--
 function Object:getHp()
    return self.hp_
end
----------------------------------------
--
 function Object:setHp(hp)
    hp = checknumber(hp)
    assert(hp >= 0 and hp <= self:getMaxHp(),
           string.format("DestroyedBehavior.setHp() - invalid hp %s", tostring(hp)))
    self.hp_ = hp
    self:dispatchEvent({name = self.HP_CHANGED_EVENT})
    self.hp__ = nil
end
----------------------------------------
--
 function Object:getMaxRage()
    local value = self:getBaseMaxRage() + self:getMaxRageRefix()
    return value
end
----------------------------------------
--
 function Object:setMaxRage(maxRage)
    maxRage = checkint(maxRage)
    assert(maxRage > 0, string.format("DestroyedBehavior.setMaxRage() - invalid maxRage %s", tostring(maxRage)))
    self.maxRage_ = maxRage
end
----------------------------------------
--
 function Object:getRage()
    return self.rage_
end
----------------------------------------
--
 function Object:setRage(rage)
    rage = checknumber(rage)
    assert(rage >= 0 and rage <= self.maxRage_,
           string.format("DestroyedBehavior.setrage() - invalid rage %s", tostring(rage)))
    self.rage_ = rage
end
----------------------------------------
--修改的属性相关
function Object:getMaxRageRefix()
    local b,value = self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Max_Rage)
    return value
end
function Object:getMaxHpRefix()
    local b,value = self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Max_Hp)
    return value
end
----------------------------------------
--
function Object:getIntAttr(roleAttrType)
    local value=self.intAttrs[roleAttrType]
    if not value then return 0 end
    return value
end
function Object:setIntAttr(roleAttrType,value)
    self.intAttrs[roleAttrType]=value
end
function Object:getBoolAttr(roleAttrType)
    local value=self.intAttrs[roleAttrType]
    if not value then return false end
    return value
end
function Object:setBoolAttr(roleAttrType,value)
    self.intAttrs[roleAttrType]=value
end
------------------------------------------------------------------------------
-- 基础命中率
function Object:getHit()
    return self.hit_
end
------------------------------------------------------------------------------
-- 美术资源
function Object:getArtId()
    return self.artId_
end
------------------------------------------------------------------------------
-- 美术资源
function Object:getFormationId()
    return self.formationId_
end
------------------------------------------------------------------------------
--人物视图数据
function Object:setView(objView)
     self.view_=objView
end
function Object:getView()
    return self.view_
end
function Object:getDir()
    if self:getView():isFlipX() then
        return MapConstants.DIR_R
    else
        return MapConstants.DIR_L
    end
end
function Object:setDir(dir)
    if MapConstants.DIR_R == dir then
        self:getView():flipX(true)
    elseif MapConstants.DIR_L==dir then
        self:getView():flipX(false)
    end
end
------------------------------------------------------------------------------
--人物所在地图
function Object:getMap()
    return self.map_
end
------------------------------------------------------------------------------
-- maths
-- ------------------------------------------------------------------------------
-- -- 让Object移动posX，posY的距离
-- function Object:move(Object,posX,posY,_callback,isMoveto)

--     if self:canDoEvent("move") then -- 能做移动动作
--         print("----------")
--         local tx, ty = Object:getPosition()
--         local t
--         if isMoveto then
--             -- 时间 = 路程/速度
--             t = math.abs(math2d.dist(tx, ty, posX, posY))/self:getSpeed()
--         else
--             t = math.abs(math2d.dist(tx, ty, tx+posX, ty+posY))/self:getSpeed()
--         end

--         -- 执行Move事件
--         self:doMoveEvent(t)

--         if isMoveto then
--             -- print("···to",posX,posY,t)
--             transition.moveTo(Object, {x = posX, y = posY ,time = t,
--                 onComplete = function()
--                     -- 停止
--                     self:doStopEvent(t,_callback)
--                 end,
--             })
--         else
--             -- print("···by",posX,posY,t)
--             transition.moveBy(Object, {x = posX, y = posY ,time = t,
--                 onComplete = function()
--                     -- 停止
--                     self:doStopEvent(t,_callback)
--                 end,
--             })
--         end
--     end
-- end

-- ------------------------------------------------------------------------------
-- -- 创建视图，如果其他 Behavior 有绑定，则会一起执行。
-- function createView(object, batch)

-- end
------------------------------------------------------------------------------
-- 移除视图，如果其他 Behavior 有绑定，则会一起执行
function removeView(object)

end
------------------------------------------------------------------------------
-- 更新，如果其他 Behavior 有绑定，则会一起执行
function Object:updateView()
    -- local sprite = objectView.sprite_
    -- sprite:setPosition(objectView:getPosition())
     -- objectView:updateView()
end
------------------------------------------------------------------------------
-- 快速更新，如果其他 Behavior 有绑定fastUpdateView，则会一起执行。
function Object:fastUpdateView()
    --print("fastUpdateView",1)
    -- local sprite = objectView.sprite_

    -- sprite:setPosition(objectView:getPosition())
    -- -- sprite:setFlipX(self.flipSprite_)
     -- self.cx_ = objectView:getPositionX()
     -- self.cy_ = objectView:getPositionY()

    if self:isMoving() then -- 只在移动时更新
     self.view_:fastUpdateView()
    end
end
------------------------------------------------------------------------------
return Object
------------------------------------------------------------------------------