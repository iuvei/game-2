--
-- Author: wangshaopei
-- Date: 2014-08-25 11:57:13
--

local CommonDefine = require("app.ac.CommonDefine")
local ImpactLogic003 = import(".impactLogics.LogicImpact003")
local CombatCore = class("CombatCore")

function CombatCore:ctor()
    self._add_atk_phy=0
    self._add_def_phy=0
    self._add_atk_magic=0
    self._add_def_magic=0
    self._add_atk_tactics=0
    self._add_def_tactics=0
end
--------------------------------------------------------------------
--
function CombatCore:getResultImpact(rAttacker,rDefender,ownImpact)
    -- 逻辑id为003的伤害计算
    local impLogic=ImpactLogic003.new()

    --
    self._add_atk_phy = impLogic:getDamagePhy(ownImpact)
    self._add_atk_magic = impLogic:getDamageMagic(ownImpact)
    self._add_atk_tactics = impLogic:getDamageTactics(ownImpact)
    -- 物理伤害
    local damage=self:CalcPhyDamage(rAttacker, rDefender, self._add_atk_phy, self._add_def_phy)
    impLogic:setDamagePhy(ownImpact, math.round(damage))
    -- 战法伤害
    local damage=self:CalcMagicDamage(rAttacker, rDefender, self._add_atk_magic, self._add_def_magic)
    impLogic:setDamageMagic(ownImpact, math.round(damage))
    -- 计策伤害
    local damage=self:CalcTacticsDamage(rAttacker, rDefender, self._add_atk_tactics,self._add_def_tactics)
    impLogic:setDamageTactics(ownImpact, math.round(damage))

    return damage
end
--------------------------------------------------------------------
-- 普通伤害计算
function CombatCore:CalcPhyDamage(atk_obj,def_obj,add_atk_phy,add_def_atk)
    if add_atk_phy ==-1 or add_atk_phy==0 then
        return -1
    end
    --
    local r1 = (atk_obj:getAttackPhysics() * (atk_obj.attr_.Captain * 0.005 + 1) - def_obj:getDefensePhysice() *(def_obj.attr_.Captain * 0.005 + 1))
    --
    local ratio = def_obj.arm_.PhysicsAtkRatio
    assert(ratio~=0,"CalcPhyDamage() - the dinominetor is not zero")
    local r2 = atk_obj.arm_.PhysicsAtkRatio/def_obj.arm_.PhysicsAtkRatio
    --
    local v1 = 1 -- 攻方普攻科技等级
    local v2 = 1 -- 防方普防科技等级
    local r3 = ((1 + v1 * 0.04)*(1 - v2 * 0.016))*(atk_obj.attr_.Captain/def_obj.attr_.Captain)
    --
    local v3 = 1 -- 攻方阵法加成
    local v4 = 0.5 -- 防方阵法加成
    local r4 = (1+v3)*(1-v4)
    local damage = math.floor(add_atk_phy*r1*r2*r3*r4)
    if damage<0 then
        damage=0
    end
    return damage
end
-- 战法伤害计算
function CombatCore:CalcMagicDamage(atk_obj,def_obj,add_atk_magic,add_def_magic)
    if add_atk_magic ==-1 or add_atk_magic == 0 then
        return -1
    end
    --
    local r1 = (100+atk_obj:getAttackMagic())/(100+def_obj:getDefenseMagic())
    --
    local ratio = def_obj.arm_.MagicAtkRatio
    assert(ratio~=0,"CalcMagicDamage() - the dinominetor is not zero")
    local r2 = atk_obj.arm_.MagicAtkRatio/ratio
    --
    local v1 = 1 -- 攻方战攻科技等级
    local v2 = 1 -- 防方战防科技等级
    local r3 = ((1 + v1 * 0.04)*(1 - v2 * 0.016))*(atk_obj.attr_.Str/def_obj.attr_.Str)
    --
    local v3 = 1 -- 攻方阵法加成
    local v4 = 0.5 -- 防方阵法加成
    local r4 = (1+v3)*(1-v4)
    local damage = add_atk_magic*r1*r2*r3*r4

    if damage<0 then
        damage=0
    end
    return damage
end
-- 计策伤害计算
function CombatCore:CalcTacticsDamage(atk_obj,def_obj,add_atk_tactics,add_def_tactics)
    if add_atk_tactics ==-1 or add_atk_tactics == 0 then
        return -1
    end
    --
    local r1 = (100+atk_obj:getAttackTactics())/(100+def_obj:getDefenseTactics())
    --
    local ratio = def_obj.arm_.TacticsDefRatio
    assert(ratio~=0,"CalcTacticsDamage() - the dinominetor is not zero")
    local r2 = atk_obj.arm_.TacticsAtkRatio/ratio
    --
    local v1 = 1 -- 攻方计策科技等级
    local v2 = 1 -- 防方计策科技等级
    local r3 = ((1 + v1 * 0.04)*(1 - v2 * 0.016))*(atk_obj.attr_.Int/def_obj.attr_.Int)
    --
    local v3 = 1 -- 攻方阵法加成
    local v4 = 0.5 -- 防方阵法加成
    local r4 = (1+v3)*(1-v4)
    local damage = add_atk_tactics*r1*r2*r3*r4
    if damage<0 then
        damage=0
    end
    return damage
end
--------------------------------------------------------------------
--
-- function CombatCore:physicalDamage(rMe,rTar,addAttack,addDefence)
--     local damage = 0
--     --物理攻击
--     local attack = rMe:getAttackPhysics()+addAttack
--     --物理防御
--     local defence= rTar:getDefensePhysice()+addDefence
--     --抵消物理攻击百分比
--     local ignoreRate = 0

--     damage=attack-defence

--     if damage<0 then
--         damage=0
--     end

--     return damage
-- end
--------------------------------------------------------------------
--命中相关
function CombatCore:isHit(hitRate,rand)
    if hitRate<0 then
        hitRate=0
    elseif hitRate>CommonDefine.RATE_LIMITE_100 then
        hitRate=CommonDefine.RATE_LIMITE_100
    end
    if hitRate>rand then
        return true
    end
    return false
end
-- 命中率
function CombatCore:calcHitRate(hit,miss)
    if hit + miss == 0 then
        return 0
    end
    return math.floor(hit/(hit+miss))
end
--------------------------------------------------------------------
-- 真实暴击率
function CombatCore:calcCrtRate(crt,crt_factor,crtdef,crtdef_factor)
    local crt_rate=self:_calcCrtRate(crt,crt_factor)
    local crtdef_rate=self:calcCrtdef(crtdef,crtdef_factor)
    local ret = crt_rate * ( 1 - crtdef_rate )
    return ret
end
-- 暴击率
function CombatCore:_calcCrtRate(crt,crt_factor)
    return crt*(crt_factor/100)
end
-- 抗暴击率
function CombatCore:calcCrtdef(crtdef,crtdef_factor)
    return crtdef*(crtdef_factor/100)
end
function CombatCore:isCrtHit(hitRate,rand)
    if hitRate<0 then
        hitRate=0
    elseif hitRate>CommonDefine.RATE_LIMITE_100 then
        hitRate=CommonDefine.RATE_LIMITE_100
    end
    if hitRate>rand then
        return true
    end
    return false
end
--------------------------------------------------------------------
return CombatCore
--------------------------------------------------------------------