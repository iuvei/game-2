--
-- Author: Your Name
-- Date: 2014-08-06 10:44:10
--
local configMgr       = require("config.configMgr")         -- 配置
------------------------------------------------------------------------------
local conf_skillsMgr={}
------------------------------------------------------------------------------
function conf_skillsMgr:GetSkillInstanceBySkillId(SkillId)
    assert(SkillId~=nil,"GetSkillInstanceBySkillId() - SkillId is nil")
    local TypeId = SkillId/1000
    local lev = SkillId%1000
    local skillInstanceId = self:GetSkillTemplate(SkillId).instanceId
    local ins = self:GetSkillInstance(skillInstanceId,lev)
    assert(ins~=nil,string.format("GetSkillInstanceBySkillId() - instance is nil skillId = %d",SkillId))
    return ins
end
------------------------------------------------------------------------------
function conf_skillsMgr:GetSkillTemplate(SkillId)
    local TypeId = math.floor(SkillId/1000)
    local conf_skillTemps = require("config.skills.skillTemplate")
    assert(conf_skillTemps.all_type[TypeId]~=nil,"GetSkillTemplate failed SkillId = "..SkillId)
    return conf_skillTemps.all_type[TypeId][1]
end
------------------------------------------------------------------------------
function conf_skillsMgr:GetSkillInstance(instanceId,lev)
    local conf_skillDatas = require("config.skills.skillData")
    return conf_skillDatas.all_type[instanceId][lev]
end

------------------------------------------------------------------------------
function conf_skillsMgr:GetSkillEffect(SkillId)
    assert(SkillId ~= 0,"SkillId == 0")

    local skillInstance = self:GetSkillInstanceBySkillId(SkillId)
    if skillInstance.skillEffId == 0 then
        return nil
    end
    --local TypeId = math.floor(skillInstance.skillEffId/1000)
    return self:GetSkillEffectByEffectId(skillInstance.skillEffId)
end
function conf_skillsMgr:GetSkillEffectByEffectId(EffectId)
    local conf_skillEffects = require("config.skills.skillEffects")
    local eff = conf_skillEffects.all_type[EffectId][1]
    assert(eff~=nil,string.format("GetSkillEffectByEffectId() - SkillEffect is nil,EffectId = %d", EffectId))
    return eff
end
------------------------------------------------------------------------------
function conf_skillsMgr:GetSkillData(SkillId)
    local skillTemp = self:GetSkillTemplate(SkillId)
    local skillIns = self:GetSkillInstanceBySkillId(SkillId)
    local appendImpactRuleData = self:GetSkillAppendImpactIdDatas(SkillId)
    local skillData = {
    type=skillTemp.type,
    logicId=appendImpactRuleData[1].logicId,
    nickname=skillTemp.nickname,
    lev=skillIns.lev,
    iconId=skillTemp.iconId,
    sikllBrief=skillIns.sikllBrief
}
    return skillData
end
function conf_skillsMgr:GetSkillIcon(SkillId)
    local skillTemp = self:GetSkillTemplate(SkillId)
    local conf_skillIcons = require("config.skills.skillIcon")
    return conf_skillIcons.all_type[skillTemp.iconId][1]
end
------------------------------------------------------------------------------
--技能效果相关
--取得技能的效果索引列表
function conf_skillsMgr:GetSkillAppendImpactIdDatas(SkillId)
    local skillInstance = self:GetSkillInstanceBySkillId(SkillId)
    local conf_appendImpacts = require("config.skills.appendImpacts")
    return conf_appendImpacts.all_type[skillInstance.appendImpactRule]
end
function conf_skillsMgr:GetSkillAppendImpacParams(SkillId)
    local data=self:GetSkillAppendImpactIdDatas(SkillId)
    local paramsLst={}
    for i=1,#data do
        if not paramsLst[i] then
            paramsLst[i]={}
        end
        paramsLst[i][1]=data[i].param1
        paramsLst[i][2]=data[i].param2
        paramsLst[i][3]=data[i].param3
        paramsLst[i][4]=data[i].param4
    end
    return paramsLst
end
function conf_skillsMgr:GetInitDataByType(initValType)
    local conf_initDatas = require("config.skills.initializeData")
    return conf_initDatas.all_type[initValType][1].value
end
------------------------------------------------------------------------------
return conf_skillsMgr
------------------------------------------------------------------------------