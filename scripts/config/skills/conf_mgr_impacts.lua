--
-- Author: Your Name
-- Date: 2014-08-06 11:39:45
--
local conf_mgr_impacts={}
------------------------------------------------------------------------------
--取得效果实例
function conf_mgr_impacts:GetImpact(impactTypeId)
    assert(impactTypeId~=nill,"conf_mgr_impacts:GetImpact() - impactTypeId is nil")
    local conf_standardImpacts = require("config.skills.standardImpact")
    return conf_standardImpacts[impactTypeId]
end
function conf_mgr_impacts:GetImpactParams(impactTypeId)
    assert(impactTypeId~=nill,"conf_mgr_impacts:GetImpactParams() - impactTypeId is nil")
    local impact = self:GetImpact(impactTypeId)
    --local conf_impactParams = require("config.impacts.impactParams")
    local params = {
        impact.param1,
        impact.param2,
        impact.param3,
        impact.param4,
        impact.param5,
        impact.param6,
        impact.param7,
        impact.param8,
        impact.param9,
        impact.param10,
    }
    return params
end
function conf_mgr_impacts:GetImpactParamVal(impactTypeId,paramTypeIndex)
    local params = self:GetImpactParams(impactTypeId)
    local v = params[paramTypeIndex]
    return v
end
------------------------------------------------------------------------------
function conf_mgr_impacts:GetSpecialObjData(specialobj_type_id)
    local conf_special_obj_datas = require("config.skills.specialObjData")
    return conf_special_obj_datas[specialobj_type_id][1]
end
------------------------------------------------------------------------------
function conf_mgr_impacts:GetLogicId(id)
    local d = self:GetImpact(id)
    return d.logicId
end
------------------------------------------------------------------------------
return conf_mgr_impacts
------------------------------------------------------------------------------