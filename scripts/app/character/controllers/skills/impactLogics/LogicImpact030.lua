--
-- Author: wangshaopei
-- Date: 2014-11-14 20:36:38
-- note: 效果过滤
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic030 = class("ImpactLogic030",ImpactLogic)
ImpactLogic030.ID=SkillDefine.LogicImpact030

function ImpactLogic030:ctor()
end
function ImpactLogic030:onFiltrateImpact(rMe,ownImpact,impactNeedCheck)
    -- body
end
return ImpactLogic030