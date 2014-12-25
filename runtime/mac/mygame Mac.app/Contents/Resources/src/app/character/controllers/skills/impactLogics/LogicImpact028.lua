--
-- Author: wangshaopei
-- Date: 2014-11-14 15:54:19
-- 清理效果
-- local CommonDefine = require("app.ac.CommonDefine")
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local ImpactLogic = import(".ImpactLogic")
local ImpactLogic028 = class("ImpactLogic028",ImpactLogic)
ImpactLogic028.ID=SkillDefine.LogicImpact028
function ImpactLogic028:ctor()
end
function ImpactLogic028:onActive(rMe,ownImpact)
    local dispel_level = 0
    local dispel_count = 0
    local collection_id = -1
    -- id = -1  清理所有效果
    rMe:Impacte_DispelImpactInSpecialCollection(collection_id,dispel_level,dispel_count)
end
return ImpactLogic028
