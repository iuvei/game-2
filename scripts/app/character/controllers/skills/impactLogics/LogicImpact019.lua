--
-- Author: wangshaopei
-- Date: 2014-11-14 18:21:49
-- node : 增加一个护盾，抵挡一定次数的，物理伤害，战法伤害，计策伤害，和直接减少固定伤害
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr    = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact019 = class("LogicImpact019",ImpactLogic)
----------------------------------------------------------------
LogicImpact019.ID=SkillDefine.LogicImpact019
function LogicImpact019:ctor()
end
function LogicImpact019:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact019:onDamage(rMe,attacker,ownImpact,outData,skillId)
    -- body
end
return LogicImpact019
