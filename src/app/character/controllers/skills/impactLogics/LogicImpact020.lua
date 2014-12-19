--
-- Author: wangshaopei
-- Date: 2014-11-17 17:17:48
-- 一定时间内修改命中,闪避,暴击，抗暴击值,破防伤害值, 破防伤害减免值
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact020 = class("LogicImpact020",ImpactLogic)
----------------------------------------------------------------
LogicImpact020.ID=SkillDefine.LogicImpact020
function LogicImpact020:ctor()
end
function LogicImpact020:initFromData(ownImpact,impactData)
    return true
end
function LogicImpact020:isOverTimed()
    return true
end

function LogicImpact020:markModifiedAttrDirty(rMe,ownImpact)
    local value = 0
end
function LogicImpact020:getIntAttrRefix(ownImpact,rMe,role_attr_refix,out_data)
     local value=0
     local conf_index = nil
    if role_attr_refix == CommonDefine.RoleAttrRefix_Hit then  -- 命中
        conf_index = 1
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_Evd then -- 闪避
        conf_index = 2
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_Crt then -- 暴击
        conf_index = 3
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_Crtdef then -- 抗暴击
        conf_index = 4
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_DecDef then -- 破防伤害值
        conf_index = 5
    elseif role_attr_refix == CommonDefine.RoleAttrRefix_DecDefRed then -- 破防伤害减免值
        conf_index = 6
    end
    assert(conf_index~=nil,"getIntAttrRefix()")
    value = Impact_GetImpactParamVal(ownImpact:getImpactTypeId(),conf_index)
    if value~=-1 then
        out_data.value = out_data.value + value
    end
end
function LogicImpact013:refixPowerByRate(ownImpact,rate)
    -- body
end
----------------------------------------------------------------
return LogicImpact013
----------------------------------------------------------------