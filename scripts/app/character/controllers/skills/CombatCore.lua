--
-- Author: wangshaopei
-- Date: 2014-08-25 11:57:13
--
local CommonDefine = require("common.CommonDefine")
local ImpactLogic003 = import(".impactLogics.LogicImpact003")
local CombatCore = class("CombatCore")

function CombatCore:ctor()
    -- body
end
--------------------------------------------------------------------
--
function CombatCore:getResultImpact(rAttacker,rDefender,ownImpact)

    local impLogic=ImpactLogic003.new()
    local damage = 0
    --物理伤害
    damage=self:physicalDamage(rAttacker, rDefender, 0, 0)

    impLogic:setDamagePhy(ownImpact, damage)
    --魔法伤害

    return damage
end
--------------------------------------------------------------------
--
function CombatCore:physicalDamage(rMe,rTar,addAttack,addDefence)
    local damage = 0
    --物理攻击
    local attack = rMe:getAttackPhysics()+addAttack
    --物理防御
    local defence= rTar:getDefensePhysice()+addDefence
    --抵消物理攻击百分比
    local ignoreRate = 0

    damage=attack-defence

    if damage<0 then
        damage=0
    end

    return damage
end
function CombatCore:magicDamage(rMe,rTar,addAttack,addDefence)
    local damage = 0
    return damage
end
function CombatCore:fireDamage(rMe,rTar,addAttack,addDefence)
    local damage = 0
    return damage
end
--------------------------------------------------------------------
--命中相关
function CombatCore:isHit(hitRate,rand)
    if hitRate<0 then
        hitRate=0
    elseif hitRate>CommonDefine.RATE_LIMITE then
        hitRate=CommonDefine.RATE_LIMITE
    end
    if hitRate>rand then
        return true
    end
    return false
end
function CombatCore:calcHitRate(hit,miss)
    if hit+miss ==0 then
        return 0
    end
    return math.floor(hit*CommonDefine.RATE_LIMITE/(hit+miss))
end
--------------------------------------------------------------------
return CombatCore
--------------------------------------------------------------------