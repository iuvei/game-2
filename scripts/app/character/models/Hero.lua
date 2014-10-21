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
local CommonDefine  = require("common.CommonDefine")

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
Hero.schema["MovDis"]       = {"number", 1}     -- 移动距离，格子数
Hero.schema["AtkDis"]       = {"number", 1}     -- 攻击距离，格子数
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
    self.itemEffect_={}

    -- dump(self)
end
function Hero:init()
    Hero.super.init(self)
    self:markMaxHpDirtyFlag()
    self:initSkill()
end
------------------------------------------------------------------------------
function Hero:getExp()
    return self.exp_
end
------------------------------------------------------------------------------
-- 防御力
function Hero:getDefensePhysice()
    local  baseAttr = self:getBaseDefensePhysics()
    local value = 0
    --技能和效果对属性的影响
    local impactAndSkillRefix = self:getDefensePhysicsRefix()

    value= baseAttr+impactAndSkillRefix
    return value
end
function Hero:getBaseDefensePhysics()
    return Hero.super.getBaseDefensePhysics(self)
end
------------------------------------------------------------------------------
-- 攻击力
function Hero:getAttackPhysics()
    local  baseAttr = self:getBaseAttackPhysics()
    local value = 0
    --技能和效果对属性的影响
    local impactAndSkillRefix = self:getAttackPhysicsRefix()
    value= baseAttr+impactAndSkillRefix
    return value
end
function Hero:getBaseAttackPhysics()
    return Hero.super.getBaseAttackPhysics(self)
end
function Hero:getMaxHp()
    if self:getMaxHpDirtyFlag()==true then
        local value = 0
        local impactAndSkillRefix=0
        local passiveSkillPointRefix = 0
        local passiveSkillRateRefix = 0
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
        --被动技能对属性值的影响
        local outAttr = {}
        outAttr.value=0
        self:Skill_RefixItemAttr(0,0,CommonDefine.ItemAttrType_Point_MaxHp,outAttr)
        passiveSkillPointRefix=outAttr.value
        --被动技能对属性百分比的影响
        outAttr.value=0
        self:Skill_RefixItemAttr(0,0,CommonDefine.ItemAttrType_Rate_MaxHp,outAttr)
        passiveSkillRateRefix=math.floor(baseAttr*outAttr.value/CommonDefine.RATE_LIMITE)
        --技能对属性的影响
        impactAndSkillRefix = self:getMaxHpRefix()
        value = impactAndSkillRefix+baseAttr+itemPointRefix+itemRateRefix+passiveSkillPointRefix+passiveSkillRateRefix
        self:setIntAttr(CommonDefine.RoleAttr_Max_Hp,value)
        self:clearMaxHpDirtyFlag()
        --if self:getHp()>value then
            self:setHp(value)
        --end
    end
    return self:getIntAttr(CommonDefine.RoleAttr_Max_Hp)
end
------------------------------------------------------------------------------
--属性修改
function Hero:getAttackPhysicsRefix()
    local b,value=self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Atk_Phy)
    return value
end
function Hero:getDefensePhysicsRefix()
    local b,value=self:Impact_GetIntAttRefix(CommonDefine.RoleAttrRefix_Defend_Phy)

    return value
end
------------------------------------------------------------------------------
-- 移动距离
function Hero:getMoveDistance()
    return self.MovDis_
end
------------------------------------------------------------------------------
function Hero:getBaseAtkDis()
    return self.AtkDis_
end
------------------------------------------------------------------------------
-- 攻击距离
function Hero:getAtkDis()
    return self.AtkDis_
end
------------------------------------------------------------------------------
function Hero:getSkillRule()
    return self.SkillRule_
end
------------------------------------------------------------------------------
--物品相关
function Hero:itemEffectFlush()
    self.itemEffect_={}
    for i=1,CommonDefine.HEquip_Num do
        local attrCount = 0
        for i=1,attrCount do
            self:calcEffect()
        end
    end
end
function Hero:calcEffect(itemAttr,itemType)
    local itemEffect={isActive=false,value=0}
end
function Hero:itemValue(attrType)
    return self.itemEffect_[attrType].value
end
function Hero:itemEffect(attrType)
    return self.itemEffect_[attrType]
end
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
    local b,value=self:Impact_GetBoolAttRefix(CommonDefine.RoleAttrRefix_MoveFlag)
    if b==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,canMove() - value = %s",self:getId(),tostring(value))
        end
        return value
    end
    return true
end
function Hero:canAttack()
    local b,value=self:Impact_GetBoolAttRefix(CommonDefine.RoleAttrRefix_AktFlag)
    if b==true then
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,canAttack() - value = %s",self:getId(),tostring(value))
        end
        return value
    end
    return true
end
function Hero:isFriend(objv)
    return false
end
------------------------------------------------------------------------------
-- 是否命中
function Hero:hit(target,_callback)
    return self:isHit(target,_callback)
end
------------------------------------------------------------------------------
--
function Hero:stop()
    self:setIsStop(true)
    self:stopMovingNow()
end
------------------------------------------------------------------------------
-- 攻击,_callback为死亡时回调，用来删除对象
function Hero:attack(target)
    if not Hero:attack() then
        return false
    end
end
function Hero:tick(dt, map)
    --self:updataHits(dt)
end
------------------------------------------------------------------------------
--
function Hero:updataHits(dt)
    --if self:getState() == "attacking" then

        local params = self:getTargetAndDepleteParams()
        if params and params.nextHitTime ~=-1 then
            params.hitTimeCounter=params.hitTimeCounter+dt
           -- print("333333",params.timeCounter)
            local hitTimeCounter = math.floor(params.hitTimeCounter*1000)
            --print("···",params.nextHitTime,hitTimeCounter)
            if params.nextHitTime <= hitTimeCounter then
                --print("···",params.nextHitTime,hitTimeCounter)
                --self:executeHit(params.target)
                -- SkillCore:activeSkillNew(self)
                --更新下次击中时间
                if params.skillExeTimesCounter <= #params.hitTimeArr then
                    params.nextHitTime=tonumber(params.hitTimeArr[params.skillExeTimesCounter])
                    params.skillExeTimesCounter = params.skillExeTimesCounter + 1
                    if params.nextHitTime == nil then params.nextHitTime=-1 end
                else
                    params.nextHitTime=-1
                end
                return true
            end
        end
    --end
    return false
end
------------------------------------------------------------------------------
--回合才更新
function Hero:updataBout()
    self:updataSkillCDs()
    self:updataImpacts()
end
-- ------------------------------------------------------------------------------
return Hero
------------------------------------------------------------------------------