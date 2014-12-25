--
-- Author: wangshaopei
-- Date: 2014-11-14 21:31:50
-- node: 命中时转化伤害的百分比为hp
local CommonDefine = require("app.ac.CommonDefine")
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic025 = class("ImpactLogic025",ImpactLogic)
ImpactLogic025.ID=SkillDefine.LogicImpact025
function ImpactLogic025:ctor()

end
function ImpactLogic025:initFromData(ownImpact,impactData)
    self._rate=ownImpact:getParameterByIndex(SkillDefine.ImpactParamL025_AbsorbRate)
    return true
end
function ImpactLogic025:onDamageTarget(rMe, target, ownImpact, outData, skillId)
    if ownImpact:isFadeOut() then
        return
    end
    local val = ownImpact:getParameterByIndex(SkillDefine.ImpactParamL025_RecodeDamage)
    if val then
        ownImpact:setParameterByIndex(SkillDefine.ImpactParamL025_RecodeDamage,outData.damage)
    end

    self._rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL025_AbsorbRate)
    local hp = math.floor(outData.damage*self._rate/CommonDefine.RATE_LIMITE)
    rMe:increaseHp(hp)
    ownImpact:markFadeOut()
    -- body
end
return ImpactLogic025
