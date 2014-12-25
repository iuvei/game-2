--
-- Author: Anthony
-- Date: 2014-06-24 16:30:19
--
------------------------------------------------------------------------------
--[[--

“英雄”类

从“角色”类继承，增加了经验值等属性

]]
------------------------------------------------------------------------------
local configMgr     = require("config.configMgr")         -- 配置
local CommonDefine  = require("app.ac.CommonDefine")

local Object = import(".Object")
local Hero = class("Hero", Object)
------------------------------------------------------------------------------
Hero.EXP_CHANGED_EVENT = "EXP_CHANGED_EVENT"
Hero.LEVEL_UP_EVENT = "LEVEL_UP_EVENT"
------------------------------------------------------------------------------
-- 升到下一级需要的经验值
Hero.NEXT_LEVEL_EXP = 50

------------------------------------------------------------------------------
-- properties
------------------------------------------------------------------------------
Hero.schema = clone(Object.schema)
Hero.schema["exp"]          = {"number", 0}
Hero.schema["quality"]      = {"number", 1}     -- 品质
-- Hero.schema["MovDis"]       = {"number", 1}     -- 移动距离，格子数
-- Hero.schema["AtkDis"]       = {"number", 1}     -- 攻击距离，格子数
Hero.schema["SkillRule"]    = {"number", 0}     -- 技能规则
Hero.schema["skills"]       = {"table"}         -- 英雄技能数据
------------------------------------------------------------------------------
--
function Hero:ctor(properties,map)

    -- 没有配置行为，则默认添加AI
    if properties.behaviors == nil then
        self.behaviors_ = {"AICharacterBehavior"}
    end

    -- 父类
    Hero.super.ctor(self, properties,map)

    -- dump(self)
end
function Hero:init()
    Hero.super.init(self)

    self:initSkill()

    -- mark all flag
    self:MarkAllAttrDirtyFlag()
end
------------------------------------------------------------------------------
function Hero:getExp()
    return self.exp_
end
------------------------------------------------------------------------------
-- 物理攻击属性
function Hero:getDefensePhysice()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsDef)==true then
        local base_attr = self:getBaseDefensePhysics()
        local value = 0
        local item_point_refix = 0

        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响人物物理防御的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_PhysicsDef)
        end
        --技能和效果对属性的影响
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttr_PhysicsDef)
        local impact_and_skillrefix = self:getDefensePhysicsRefix()
        value = base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_PhysicsDef,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsDef)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_PhysicsDef)
end
function Hero:getBaseDefensePhysics()
    return Hero.super.getBaseDefensePhysics(self)
end
function Hero:getAttackPhysics()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsAtk)==true then
        local  base_attr = self:getBaseAttackPhysics()
        local value = 0
        local item_point_refix = 0
        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响物理攻击的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_PhysicsAtk)
        end

        -- the influence of skill and impact to attributes
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttr_PhysicsAtk)
        local impact_and_skillrefix = self:getAttackPhysicsRefix()
        value= base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_PhysicsAtk,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_PhysicsAtk)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_PhysicsAtk)
end
function Hero:getBaseAttackPhysics()
    return Hero.super.getBaseAttackPhysics(self)
end
------------------------------------------------------------------------------
-- 战法属性
function Hero:getAttackMagic()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_MagicAtk)==true then
        local  base_attr = self:getBaseAttackMagic()
        local value = 0
        local item_point_refix = 0
        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响物理攻击的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_MagicAtk)
        end

        -- the influence of skill and impact to attributes
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttrRefix_MagicAtk)
        local impact_and_skillrefix = self:getImpactIntAttRefix(CommonDefine.RoleAttrRefix_MagicAtk)
        value= base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_MagicAtk,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_MagicAtk)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_MagicAtk)
end
function Hero:getDefenseMagic()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_MagicDef)==true then
        local  base_attr = self:getBaseDefenseMagic()
        local value = 0
        local item_point_refix = 0
        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响物理攻击的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_MagicDef)
        end

        -- the influence of skill and impact to attributes
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttrRefix_MagicDef)
        local impact_and_skillrefix = self:getImpactIntAttRefix(CommonDefine.RoleAttrRefix_MagicDef)
        value= base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_MagicDef,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_MagicDef)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_MagicDef)
end
------------------------------------------------------------------------------
-- 计策属性
function Hero:getAttackTactics()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_TacticsAtk)==true then
        local base_attr = self:getBaseAttackTactics()
        local value = 0
        local item_point_refix = 0
        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响物理攻击的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_PhysicsAtk)
        end
        -- the influence of skill and impact to attributes
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttrRefix_TacticsAtk)
        local impact_and_skillrefix = self:getImpactIntAttRefix(CommonDefine.RoleAttrRefix_TacticsAtk)
        value= base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_TacticsAtk,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_TacticsAtk)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_TacticsAtk)
end
function Hero:getDefenseTactics()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_TacticsDef)==true then
        local  base_attr = self:getBaseDefenseTactics()
        local value = 0
        local item_point_refix = 0
        -- the influence of equipment to attributes
        local data = PLAYER:get_mgr("heros"):get_hero(self.GUID_)
        if data then
            -- 获取装备中影响物理攻击的值
            item_point_refix = data:get_item_value(CommonDefine.ItemAttrType_TacticsDef)
        end
        -- the influence of skill and impact to attributes
        local passive_skill_point_refix = self:Skill_RefixItemAttr(CommonDefine.RoleAttrRefix_TacticsDef)
        local impact_and_skillrefix = self:getImpactIntAttRefix(CommonDefine.RoleAttrRefix_TacticsDef)
        value= base_attr + impact_and_skillrefix + item_point_refix + passive_skill_point_refix

        self:setIntAttr(CommonDefine.RoleAttr_TacticsDef,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_TacticsDef)
    end
    return self:getIntAttr(CommonDefine.RoleAttr_TacticsDef)
end
------------------------------------------------------------------------------
--
function Hero:getMaxHp()
    if self:GetAttrDirtyFlag(CommonDefine.RoleAttr_MaxHP)==true then
        local value = 0
        local impact_and_skillrefix=0
        local passiveSkillPointRefix = 0
        local itemPointRefix = 0
        local itemRateRefix = 0

        local baseAttr = self:getBaseMaxHp()
        -- --对属性点的影响
        -- local e = self:itemEffect(CommonDefine.itemAttrType_Point_MaxHp)
        -- if e and e.isActive then
        --     itemPointRefix=e.value
        -- end
        -- --对属性百分比的影响
        -- e = self:itemEffect(CommonDefine.itemAttrType_Rate_MaxHp)
        -- if e and e.isActive then
        --     itemRateRefix=math.floor(baseAttr*e.value/CommonDefine.RATE_LIMITE)
        -- end
        -- 被动技能对属性值的影响
        passiveSkillPointRefix=self:Skill_RefixItemAttr(CommonDefine.RoleAttr_MaxHP)

        --技能对属性的影响
        impact_and_skillrefix = self:getMaxHpRefix()
        value = impact_and_skillrefix+baseAttr+itemPointRefix+itemRateRefix+passiveSkillPointRefix
        self:setIntAttr(CommonDefine.RoleAttr_MaxHP,value)
        self:ClearAttrDirtyFlag(CommonDefine.RoleAttr_MaxHP)
        --if self:getHp()>value then
            self:setHp(value)
        --end
    end
    return self:getIntAttr(CommonDefine.RoleAttr_MaxHP)
end
------------------------------------------------------------------------------
-- 二级属性
function Hero:getAttr2(role_attr_type)
    if self:GetAttrDirtyFlag(role_attr_type) == true then
        local value = 0
        local impact_and_skill_refix=0
        local passive_skill_point_refix = 0
        local item_point_refix = 0
        local base_attr = 0
        if role_attr_type == CommonDefine.RoleAttr_Hit then
            base_attr = self.attr_.Hit
        elseif role_attr_type == CommonDefine.RoleAttr_Evd then
            base_attr = self.attr_.Evd
        elseif role_attr_type == CommonDefine.RoleAttr_Crt then
            base_attr = self.attr_.Crt
        elseif role_attr_type == CommonDefine.RoleAttr_Crtdef then
            base_attr = self.attr_.Crtdef
        elseif role_attr_type == CommonDefine.RoleAttr_DecDef then
            base_attr = self.attr_.DecDef
        elseif role_attr_type == CommonDefine.RoleAttr_DecDefRed then
            base_attr = self.attr_.DecDefRed
        end
        -- 被动技能影响值
        passive_skill_point_refix=self:Skill_RefixItemAttr(role_attr_type)
        -- 技能和效果影响值
        impact_and_skill_refix = self:getImpactIntAttRefix(role_attr_type)
        value = base_attr+impact_and_skill_refix+item_point_refix+passive_skill_point_refix
        self:setIntAttr(role_attr_type,value)
        self:ClearAttrDirtyFlag(role_attr_type)
    end
    return self:getIntAttr(role_attr_type)
end
------------------------------------------------------------------------------
--
function Hero:getAttr1(role_attr_type)
    if self:GetAttrDirtyFlag(role_attr_type) == true then
        local value = 0
        local passive_skill_point_refix = 0
        local base_attr = 0
        if role_attr_type == CommonDefine.RoleAttr_Speed then
            base_attr = self.attr_.Speed
        end
        -- 被动技能影响值
        passive_skill_point_refix=self:Skill_RefixItemAttr(role_attr_type)

        value = base_attr + passive_skill_point_refix
        self:setIntAttr(role_attr_type,value)
        self:ClearAttrDirtyFlag(role_attr_type)
    end
    return self:getIntAttr(role_attr_type)
end
------------------------------------------------------------------------------
--属性修改
function Hero:getAttackPhysicsRefix()
    local  out_data={value=0}
    self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_PhysicsAtk,out_data)
    return out_data.value
end
function Hero:getDefensePhysicsRefix()
    local  out_data={value=0}
    self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_PhysicsDef,out_data)
    return out_data.value
end
------------------------------------------------------------------------------
-- 移动距离
function Hero:getMoveDistance()
    return self.arm_.MovDis
end
------------------------------------------------------------------------------
function Hero:getSkillRule()
    return self.SkillRule_
end
------------------------------------------------------------------------------
-- 基础命中值
function Hero:getHit()
    return self:getAttr2(CommonDefine.RoleAttr_Hit)
end
function Hero:getMiss()
    return self:getAttr2(CommonDefine.RoleAttr_Evd)
end
------------------------------------------------------------------------------
--物品相关

------------------------------------------------------------------------------
-- maths
------------------------------------------------------------------------------
-- 增加经验值，并升级
function Hero:increaseEXP(exp)
    -- assert(not self:isDead(), string.format("hero %s:%s is dead, can't increase Exp", self:getId(), self:getNickname()))
    -- assert(exp > 0, "Hero:increaseEXP() - invalid exp")

    -- self.exp_ = self.exp_ + exp
    -- -- 简化的升级算法，每一个级别升级的经验值都是固定的
    -- while self.exp_ >= Hero.NEXT_LEVEL_EXP do
    --     self.level_ = self.level_ + 1
    --     self.exp_ = self.exp_ - Hero.NEXT_LEVEL_EXP
    --     self:setFullHp() -- 每次升级，HP 都完全恢复
    --     self:dispatchEvent({name = Hero.LEVEL_UP_EVENT})
    -- end
    -- self:dispatchEvent({name = Hero.EXP_CHANGED_EVENT})

    return self
end
------------------------------------------------------------------------------
--
function Hero:canMove()
    local out_data = {value=nil}
    if self:Impact_GetBoolAttRefix(CommonDefine.RoleAttrRefix_MoveFlag,out_data) ==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,canMove() - value = %s",self:getId(),tostring(out_data.value))
        end
        return out_data.value
    end
    return true
end
function Hero:canAttack()
    local out_data = {value=nil}
    if self:Impact_GetBoolAttRefix(CommonDefine.RoleAttrRefix_AktFlag,out_data)==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,canAttack() - value = %s",self:getId(),tostring(out_data.value))
        end
        return out_data.value
    end
    return true
end
function Hero:getBoolAttRefix(role_attr_refix_type)
    local out_data = {value=nil}
    if self:Impact_GetBoolAttRefix(role_attr_refix_type,out_data)==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,getBoolAttRefix() - value = %s",self:getId(),tostring(out_data.value))
        end
        return out_data.value
    end
    return true
end
-- 混乱
function Hero:isChaos()
    local out_data = {value=nil}
    if self:Impact_GetBoolAttRefix(CommonDefine.RoleAttrRefix_ChaosFlag,out_data)==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,canAttack() - value = %s",self:getId(),tostring(value))
        end
        return out_data.value
    end
    return false
end
------------------------------------------------------------------------------
function Hero:isFriend(objv)
    return false
end
------------------------------------------------------------------------------
-- 是否命中
-- function Hero:hit(target,_callback)
--     return self:isHit(target,_callback)
-- end
------------------------------------------------------------------------------
--
function Hero:tick(dt, map)
    --self:updataHits(dt)
end
------------------------------------------------------------------------------
--
function Hero:updata()

end
------------------------------------------------------------------------------
--回合才更新
function Hero:updataBout()
    self:updataSkillCDs()
    -- self:updataImpacts()
end
-- ------------------------------------------------------------------------------
return Hero
------------------------------------------------------------------------------