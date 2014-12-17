--
-- Author: wangshaopei
-- Date: 2014-08-21 15:16:24
--
local CommonDefine = require("app.ac.CommonDefine")
local ImpactLogic = class("ImpactLogic")
function ImpactLogic:ctor()
end
function ImpactLogic:initFromData(ownImpact,conf_impact)
    return true
end
--修改效果值
function ImpactLogic:refixSkill(ownImp,skillInfo)

end
function ImpactLogic:crtRefix(ownImp)

end
function ImpactLogic:updata(rMe,ownImp)
    local bContinue = true
    if self:specialCDCheck(rMe,ownImp) == false then
        bContinue = false
    end
    if bContinue == false then
        return
    end
    if self:isInvervaled() then
        self:calcCDInterval(rMe,ownImp)
    end
    self:calcCD(rMe,ownImp)
end
--真正开始执行效果
function ImpactLogic:onActive(rMe,ownImpact)

end
--驻留倒计时完成
function ImpactLogic:onIntervalOver(rMe,ownImpact)
end
--是否驻留
function ImpactLogic:isInvervaled()
    return false
end
--是否被延长时间
function ImpactLogic:isOverTimed()
    return false
end
function ImpactLogic:specialCDCheck(rMe,ownImpact)
    return true
end
function ImpactLogic:markModifiedAttrDirty(rMe,ownImpact)
    return true
end
function ImpactLogic:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
end
function ImpactLogic:getBoolAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
    return false
end
--驻留CD
function ImpactLogic:calcCDInterval(rMe,ownImpact)
    ownImpact:getCDInterval():updata(1)
    if ownImpact:getCDInterval():isCooldowned() then
        self:onIntervalOver(rMe,ownImpact)
        ownImpact:getCDInterval():setCooldownElapsedVal(ownImpact:getCDInterval():getRemainVal())
    end
end
function ImpactLogic:calcCD(rMe,ownImpact)
    --为－1无线回合
    if ownImpact:getCD():getCooldownAmountVal() == CommonDefine.INVALID_ID then
        return false
    end
    if ownImpact:getCD():getCooldownAmountVal()>0 then
        ownImpact:getCD():updata(1)
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s,updataImpactCD() - cooldownId=%d cooldownElapseVal=%d cooldownVal=%d",
            rMe:getId(),ownImpact:getImpactTypeId(),ownImpact:getCD():getCooldownElapsedVal(),ownImpact:getCD():getCooldownAmountVal())
        end
    end
    if ownImpact:getCD():isCooldowned() then
        rMe:Impact_OnImpactFadeOut(ownImpact)
    end
    return true
end
--处理无类型伤害
function ImpactLogic:onDamage(rMe,attacker,ownImpact,outData,skillId) -- outData={damage}
    -- body
end
--处理分类伤害
function ImpactLogic:onDamages(rMe,attacker,ownImpact,outData,skillId) -- outData={damages}
    -- body
end
function ImpactLogic:onDamageTarget(rMe,target,ownImpact,outData,skillId) -- outData={damage}
    -- body
end
function ImpactLogic:onFiltrateImpact(rMe,ownImpact,impactNeedCheck)
    -- body
end
-- 回合开始前执行
function ImpactLogic:onBeforeBout(sender_obj,ownImpact)
    -- body
end
-------------------------------------------------------------
return ImpactLogic
-------------------------------------------------------------