--
-- Author: wangshaopei
-- Date: 2014-11-14 21:31:50
-- node: 吸血
local CommonDefine = require("app.ac.CommonDefine")
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic025 = class("ImpactLogic025",ImpactLogic)
ImpactLogic025.ID=SkillDefine.LogicImpact025
function ImpactLogic025:ctor()
    self._rate=0
end
function ImpactLogic025:onDamageTarget(rMe,target,ownImpact,outData,skillId)
    if ownImpact:isFadeOut() then
        return
    end
    self._rate = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),SkillDefine.ImpactParamL025_AbsorbRate)
    rMe:increaseHp(outData.damage*self._rate/CommonDefine.RATE_LIMITE)
    -- body
end
return ImpactLogic025
