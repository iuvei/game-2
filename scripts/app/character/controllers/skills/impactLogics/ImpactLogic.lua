--
-- Author: wangshaopei
-- Date: 2014-08-21 15:16:24
--
local CommonDefine = require("common.CommonDefine")
local ImpactLogic = class("ImpactLogic")
function ImpactLogic:ctor()
end
--修改效果值
function ImpactLogic:refixSkill(ownImp,skillInfo)

end
function ImpactLogic:updata(rMe,ownImp)
    local bContinue = true
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
function ImpactLogic:markModifiedAttrDirty(rMe,ownImpact)
    return true
end
function ImpactLogic:getIntAttrRefix(ownImpact,rMe,roleAttrType)
    return false,0
end
function ImpactLogic:getBoolAttrRefix(ownImpact,rMe,roleAttrType)
    return false,CommonDefine.INVALID_ID
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
function ImpactLogic:onDamage()
    -- body
end
--处理分类伤害
function ImpactLogic:onDamages()
    -- body
end
-------------------------------------------------------------
return ImpactLogic
-------------------------------------------------------------