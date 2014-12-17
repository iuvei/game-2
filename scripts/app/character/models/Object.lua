--
-- Author: Anthony
-- Date: 2014-06-24 16:30:19
-- ------------------------------------------------------------------------------
-- -- 全局的行为管理器
-- BehaviorsManager    = import("..controllers.behaviors.BehaviorsManager")

local MapConstants  = require("app.ac.MapConstants")
local CommonDefine  = require("app.ac.CommonDefine")
local math2d        = require("common.math2d")
------------------------------------------------------------------------------
--[[--
”Object“类
]]
------------------------------------------------------------------------------
local BaseObject = import(".BaseObject")
local Object = class("Object", BaseObject)
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
Object.schema["GUID"]              = {"number", 0}
Object.schema["nickname"]          = {"string"}        -- 名字，没有默认值
Object.schema["campId"]            = {"number", 0}     -- 阵营
Object.schema["level"]             = {"number", 1}     -- 等级，默认值 1
Object.schema["hp"]                = {"number", 1}     -- HP
Object.schema["artId"]             = {"number", 1001}  -- 美术ID
Object.schema["formationId"]       = {"number", 1}     -- 武将阵形，策划设定为 性格
Object.schema["ArmId"]             = {"number", 1}     -- 兵种编号
Object.schema["arm"]               = {"table"}
Object.schema["attr"]              = {"table"}         -- 一级 二级 属性
------------------------------------------------------------------------------
function Object:ctor(properties,map)
    Object.super.ctor(self, properties,map)
    self.view_ = nil
    self.intAttrs={}
end
------------------------------------------------------------------------------
-- 类开始处理
------------------------------------------------------------------------------
function Object:init()
    Object.super.init(self)
    -- if self.behaviors_ == nil then
    --     -- 默认绑定AI行为
    --     self.behaviors_  = {"AICharacterBehavior"}
    -- end
    -- BehaviorsManager:initBehaviors(self)
    self:initDestroyedBeh()
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
    -- return self.attack_
    return self.attr_.PhysicsAtk
end
--物理攻击
function Object:getAttackPhysics()
    return self:getBaseAttackPhysics()
end
--战法
function Object:getBaseAttackMagic()
    return self.attr_.MagicAtk
end
--计策
function Object:getBaseAttackTactics()
    return self.attr_.TacticsAtk
end
------------------------------------------------------------------------------
-- 命中值
function Object:getHit()
    return 1 -- 默认命中值为1
end
function Object:getMiss()
    return 0
end
------------------------------------------------------------------------------
-- 基本物理防御
function Object:getBaseDefensePhysics()
    return self.attr_.PhysicsDef
end
-- 物理防御
function Object:getDefensePhysice()
    return self:getBaseDefensePhysics()
end
-- 战法防御
function Object:getBaseDefenseMagic()
    return self.attr_.MagicDef
end
-- 计策防御
function Object:getBaseDefenseTactics()
    return self.attr_.TacticsDef
end
------------------------------------------------------------------------------
--基本最大怒气值
function Object:getBaseMaxRage()
    return self.attr_.MaxRage
end
------------------------------------------------------------------------------
--基本最大Hp值
function Object:getBaseMaxHp()
    -- if self.att_ ~= nil then
    --     return self.att_
    -- end
    return self.attr_.MaxHP
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
    self.attr_.MaxHP = maxHp
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
--  function Object:setMaxRage(maxRage)
--     maxRage = checkint(maxRage)
--     assert(maxRage > 0, string.format("DestroyedBehavior.setMaxRage() - invalid maxRage %s", tostring(maxRage)))
--     self.attr_.MaxRage = maxRage
-- end
----------------------------------------
--
 function Object:getRage()
    return self.rage_
end
----------------------------------------
--
 function Object:setRage(rage)
    rage = checknumber(rage)
    assert(rage >= 0 and rage <= self:getMaxRage(),
           string.format("DestroyedBehavior.setrage() - invalid rage %s", tostring(rage)))
    self.rage_ = rage
end
----------------------------------------
--修改的属性相关
-- 取得人物身上bug的效果值
function Object:getImpactIntAttRefix(roleAttrRefixType)
    local  out_data={value=0}
    self:Impact_GetIntAttRefix(roleAttrRefixType,out_data)
    return out_data.value
end
function Object:getMaxRageRefix()
    local  out_data={value=0}
    self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_MaxRage,out_data)
    return out_data.value
end
function Object:getMaxHpRefix()
    local  out_data={value=0}
    self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_MaxHP,out_data)
    return out_data.value
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