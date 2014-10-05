--
-- Author: Your Name
-- Date: 2014-08-06 11:39:45
--
local conf_impactsMgr={}
------------------------------------------------------------------------------
--取得效果实例
function conf_impactsMgr:GetImpact(impactTypeId)
    assert(impactTypeId~=nill,"conf_impactsMgr:GetImpact() - impactTypeId is nil")
    local conf_standardImpacts = require("config.skills.standardImpact")
    return conf_standardImpacts.all_type[impactTypeId][1]
end
function conf_impactsMgr:GetImpactParams(impactTypeId)
    assert(impactTypeId~=nill,"conf_impactsMgr:GetImpactParams() - impactTypeId is nil")
    local impact = self:GetImpact(impactTypeId)
    --local conf_impactParams = require("config.impacts.impactParams")
    local params = {}
    params[1]=impact.param1
    params[2]=impact.param2
    params[3]=impact.param3
    params[4]=impact.param4
    params[5]=impact.param5
    params[6]=impact.param6
    params[7]=impact.param7
    params[8]=impact.param8
    params[9]=impact.param9
    params[10]=impact.param10
    return params
end
function conf_impactsMgr:GetImpactParamVal(impactTypeId,paramTypeIndex)
    local params = self:GetImpactParams(impactTypeId)
    local v = params[paramTypeIndex]
    return v
end
------------------------------------------------------------------------------
function conf_impactsMgr:GetLogicId(id)
    local d = self:GetImpact(id)
    return d.logicId
end
------------------------------------------------------------------------------
return conf_impactsMgr
------------------------------------------------------------------------------