--
-- Author: Your Name
-- Date: 2014-08-06 15:05:40
--
local configMgr       = require("config.configMgr")         -- 配置
local CommonDefine = require("common.CommonDefine")
local SkillDefine=require("app.controllers.skills.SkillDefine")
local HeroAtkCommand=require("app.controllers.commands.HeroAtkCommand")
local HeroCGCommand = require("app.controllers.commands.HeroCGCommand")
local SkillInfo = require("app.controllers.skills.SkillInfo")
local CooldownList = require("common.CooldownList")
local TargetAndDepleteParams = require("app.controllers.skills.TargetAndDepleteParams")
local BehaviorBase = require("app.controllers.behaviors.BehaviorBase")
------------------------------------------------------------------------------
local SkillBehavior = class("SkillBehavior", BehaviorBase)
------------------------------------------------------------------------------
function SkillBehavior:ctor()
    SkillBehavior.super.ctor(self, "SkillBehavior", nil, 1)
end
------------------------------------------------------------------------------
function SkillBehavior:bind(object)

    self:bindMethods(object)
    object.skills_      = {}                                        --人物身上技能列表
    object.skillsByUseType_    ={}                                  --主动技能
    object.impacts_={}
    object.skillInfo_      = SkillInfo.new()
    object.targetAndDepleteParams_=TargetAndDepleteParams.new()     --目标和消耗等参数
    object.skillCore_     = SkillCore.new()
    object.cds_           = CooldownList.new()                      --cd列表
    self:reset(object)
end
------------------------------------------------------------------------------
function SkillBehavior:unbind(object)
    object.skills_      = {}                                    --所有技能
    object.skillsByUseType_    ={}                              --主动技能
    object.skillInfo_      = {}
    object.skillCore_     = nil
    self:unbindMethods(object)
end
------------------------------------------------------------------------------
function SkillBehavior:reset(object)

end
------------------------------------------------------------------------------
function SkillBehavior:bindMethods(object)

    local function useSkill(object,skillId)
        if not object.skillCore_:preocessSkillRequest(object,skillId) then
            object:getTargetAndDepleteParams():init()
            return false
        end
        HeroOperateManager:destroyAllCommands()
        --加入命令
        --加入战前CG
        local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
        if skillTemp.isPlayHeadIcon == 1 then
            HeroOperateManager:addCommand(HeroCGCommand.new(object))
        end
        --加入攻击
        HeroOperateManager:addCommand(HeroAtkCommand.new(object))
        return true
    end
    self:bindMethod(object,"useSkill", useSkill)
    ------------------------------------------------------------------------------
    -- 伤害处理相关
    local function doAttack(object)
        local params = object:getTargetAndDepleteParams()
        if params == nil then return false end
        --整个攻击完成的时间：加上了被攻击后的时间和0.2的调整
        return object:doAttackEvent(params.atkAomuntTime/1000 + object.ATTACK_COOLDOWN + 0.2)--Object.ATTACK_COOLDOWN
    end
    self:bindMethod(object,"doAttack", doAttack)
    --受伤害分类型
    local function onDamages(object,damageArr,attackerId,skillId)
         local attackerView =object:getMap():getObject(attackerId)
         local attackerObj = nil
         if attackerView then attackerObj = attackerView:GetModel() end

        object:Impact_OnDamages(damageArr,attackerObj,skillId)

        local damageVal = damageArr[SkillDefine.ImpactParamL003_DamagePhy]+
        damageArr[SkillDefine.ImpactParamL003_DamagePhyRate]+
        damageArr[SkillDefine.ImpactParamL003_DamageZhanFa]+
        damageArr[SkillDefine.ImpactParamL003_DamageZhanFaRate]+
        damageArr[SkillDefine.ImpactParamL003_DamageJiCe]+
        damageArr[SkillDefine.ImpactParamL003_DamageJiCeRate]

        object:Impact_OnDamage(damageVal,attackerObj,skillId)

        if attackerObj~=nil then
            attackerObj:onDamageTarget(damageVal,object,skillId)
        end
        object:increaseHp(-damageVal)

        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        if not object:isDestroyed() then
            object:increaseRage(10)
        end



    end
    self:bindMethod(object,"onDamages", onDamages)
    --受伤害无类型
    local function onDamage(object,damageVal,attackerId,skillId)
        local attackerObj =object:getMap():getObjectReal(attackerId)
        if damageVal<=0 then damageVal=1 end
        object:Impact_OnDamage(damageVal,attackerObj,skillId)
        if attackerObj~=nil then
            attackerObj:onDamageTarget(damageVal,object,skillId)
        end
        object:increaseHp(-damageVal)
    end
    self:bindMethod(object,"onDamage", onDamage)
    --受伤害目标
    local function onDamageTarget(object,damageVal,rTar,skillId)

    end
    self:bindMethod(object,"onDamageTarget", onDamageTarget)
    --拥有的无类型伤害处理

    local function Impact_OnDamage(object,nDamage,attacker,skillId)
        for k,ownImpact in pairs(object.impacts_) do
            local logic=Impact_GetLogic(object, ownImpact)
            if logic==nil then
            else
                logic:onDamage()
            end
        end
    end
    self:bindMethod(object,"Impact_OnDamage", Impact_OnDamage)
    --拥有的分类型伤害处理
    local function Impact_OnDamages(object,nDamage,attacker,skillId)
        for k,ownImpact in pairs(object.impacts_) do
            local logic=Impact_GetLogic(object, ownImpact)
            if logic==nil then
            else
                logic:onDamages()
            end
        end
    end
    self:bindMethod(object,"Impact_OnDamages", Impact_OnDamages)
    ------------------------------------------------------------------------------
    --效果相关
    local function Impact_OnImpactActived(object,ownImpact)
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s impactId = %d is actived,", object:getId(),ownImpact:getImpactTypeId())
        end
        local logic =  Impact_GetLogic(object,ownImpact)
        logic:onActive(object,ownImpact)
        --标记修改属性更新
        if logic:isOverTimed() then
            logic:markModifiedAttrDirty(object,ownImpact)
        end
        if ownImpact:getResEffectId()>0 then
            local isRepeatPlay = logic:isOverTimed()
            object:getView():createImpactEffect(ownImpact:getResEffectId(),isRepeatPlay)
        end
    end
    self:bindMethod(object,"Impact_OnImpactActived", Impact_OnImpactActived)
    local function Impact_RegisterImpact(object,ownImpact)
        object:Impact_AddNewImpact(ownImpact)
        object:Impact_OnImpactActived(ownImpact)
    end
    self:bindMethod(object,"Impact_RegisterImpact", Impact_RegisterImpact)
    local function Impact_AddNewImpact(object,ownImpact)
        object.impacts_[ownImpact:getImpactTypeId()]=ownImpact
        if DEBUG_BATTLE.showSkillInfo then
            printf("object = %s impactId = %d is add new",object:getId(),ownImpact:getImpactTypeId())
        end
        return true
    end
    self:bindMethod(object,"Impact_AddNewImpact", Impact_AddNewImpact)
    local function Impact_OnImpactFadeOut(object,ownImpact)
       ownImpact:markFadeOut()

       local logic =  Impact_GetLogic(object,ownImpact)
       if ownImpact:getResEffectId()>0 and logic:isOverTimed() then
           object:getView():removeImpactEffect(ownImpact:getImpactSpriteTagId())
       end
       object:Impact_DelImpact(ownImpact)
    end
    self:bindMethod(object,"Impact_OnImpactFadeOut", Impact_OnImpactFadeOut)
    local function Impact_DelImpact(object,ownImpact)
        object.impacts_[ownImpact:getImpactTypeId()]=nil
        if DEBUG_BATTLE.showSkillInfo then
           printf("object = %s impactId = %d is delect",object:getId(),ownImpact:getImpactTypeId())
       end
    end
    self:bindMethod(object,"Impact_DelImpact", Impact_DelImpact)
    local function Impact_GetIntAttRefix(object,roleAttrType)
        local v = 0
        local b = false
        for k,ownImpact in pairs(object.impacts_) do
            local impLogic = Impact_GetLogic(object, ownImpact)
            if impLogic==nil then

            elseif ownImpact:isFadeOut()==false and impLogic:isOverTimed()==true then
                b,v=impLogic:getIntAttrRefix(ownImpact,object,roleAttrType)
                if b==true then
                    return b,v
                end
            end
        end
        return b,v
    end
    self:bindMethod(object,"Impact_GetIntAttRefix", Impact_GetIntAttRefix)
    local function Impact_GetBoolAttRefix(object,roleAttrType)
        local v = CommonDefine.INVALID_ID
        local b = false
        for k,ownImpact in pairs(object.impacts_) do
            local impLogic = Impact_GetLogic(object, ownImpact)
            if impLogic==nil then
                --todo
            elseif ownImpact:isFadeOut()==false and impLogic:isOverTimed()==true then
                b,v=impLogic:getBoolAttrRefix(ownImpact,object,roleAttrType)
                if b==true then
                    break
                end
            end
        end
        local bRet =nil
        if v == 0 then
            bRet = false
        elseif v == 1 then
            bRet = true
        end
        return b,bRet
    end
    self:bindMethod(object,"Impact_GetBoolAttRefix", Impact_GetBoolAttRefix)
    --取得物品属性影响值
    local function Skill_RefixItemAttr(object,slotId,itemType,attrType,outAttr)
        if not object:getSkillsByUseType(SkillDefine.UseType_Passivity) then return end
        for k,skill in pairs(object:getSkillsByUseType(SkillDefine.UseType_Passivity)) do
            local logic = Skill_GetLogic(object,Skill_GetLogicId(skill.id))
            --print("···",skill.id)
            if logic~=nil then
                --logic:refix_ItemEffect(skill,slotId,itemType,attrType,outAttr)
                logic:refix_SkillEffect(skill,attrType,outAttr)
            end
        end
    end
    self:bindMethod(object,"Skill_RefixItemAttr", Skill_RefixItemAttr)
    --效果过滤
    local function onFiltrateImpact(object,ownImpact)
        return false
    end
    self:bindMethod(object,"onFiltrateImpact", onFiltrateImpact)
    --更新效果列表
    local function updataImpacts(object)
        if table.nums(object.impacts_)<=0 then return end
        --必须记录当前需要更新的，因为updata过程中impacts会被修改
        local tmp = {}
        for k,v in pairs(object.impacts_) do
            tmp[k]=v
        end
        for k,ownImpact in pairs(tmp) do
            local impLogic = Impact_GetLogic(object, ownImpact)
            if impLogic then
                impLogic:updata(object,ownImpact)
            end
        end
    end
    self:bindMethod(object,"updataImpacts", updataImpacts)
    ------------------------------------------------------------------------------
    -- 命中目标
    local function isHit(object,enemy,_callback)
        assert(not object:isDead(), string.format("Object %s:%s is dead, can't change Hp", object:getId(), object:getNickname()))
        if math.random(1, 100) <= object:getHit() then
            return true
        else
            return false
        end
    end
    self:bindMethod(object,"isHit", isHit)
    --------------------------------------------------------------------------
    local function getTargetAndDepleteParams(object)
        return object.targetAndDepleteParams_
    end
    self:bindMethod(object,"getTargetAndDepleteParams", getTargetAndDepleteParams)
    --------------------------------------------------------------------------
    local function getSkillInfo(object)
        return object.skillInfo_
    end
    self:bindMethod(object,"getSkillInfo", getSkillInfo)
    --------------------------------------------------------------------------
    -- local function copySkillInstance(object,skillInstance)
    --     object.skillInfo_.skillId = skillInstance.skillId
    -- end
    -- self:bindMethod(object,"copySkillInstance", copySkillInstance)
    -- --------------------------------------------------------------------------
    -- local function copySkillTemp(object,skillTemp)
    --     object.skillInfo_.skillId = skillTemp.skillId
    -- end
    -- self:bindMethod(object,"copySkillTemp", copySkillTemp)
    --------------------------------------------------------------------------
    local function initSkill(object)
        for k,v in pairs(object:getArmSkillsOfSkillRule()) do
            object:addSkill(object:createSkill(v.skillId))
        end
        for k,v in pairs(object:getHeroSkillsOfSkillRule()) do
            object:addSkill(object:createSkill(v.skillId))
        end
        -- if object:getIndex()==4 then
        --     object:addSkill(object:createSkill(41001))
        -- end
        object:skillsSort()
        object:markMaxHpDirtyFlag()
    end
    self:bindMethod(object,"initSkill", initSkill)
    --------------------------------------------------------------------------
    --使用顺序 冷却回合 > 怒气值消耗大 > 技能顺序(暂时不处理)
    local function skillsSort(object)
        table.sort(object:getSkills(),function (a,b)
            if a.coolBoutTimes > b.coolBoutTimes then
                return true
            elseif a.coolBoutTimes == b.coolBoutTimes then
                if a.consumeRage > b.consumeRage then
                    return true
                end
            end
            return false
        end)
    end
    self:bindMethod(object,"skillsSort", skillsSort)
    local function checkCondition(object,skillId)
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        if object:getRage()>= skillIns.consumeRage then
            return true
        end
    end
    self:bindMethod(object,"checkCondition", checkCondition)
    local function isInSceneSkill(object,skillId)
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        if skillIns then
            if skillIns.isEnterUseSkill==1 then
                return true
            end
        end
        return false
    end
    self:bindMethod(object,"isInSceneSkill", isInSceneSkill)
    --------------------------------------------------------------------------
    local function getSkills(object)
        return object.skills_
    end
    self:bindMethod(object,"getSkills", getSkills)
    local function getSkillsByUseType(object,useType)
        return object.skillsByUseType_[useType]
    end
    self:bindMethod(object,"getSkillsByUseType", getSkillsByUseType)
    --------------------------------------------------------------------------
    local function getSelectSkill(object)
        -- for k,v in pairs(object:getSkills()) do
        --     local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(v.id)
        --     print("getSkills",v.id,skillIns.consumeRage)
        -- end
        for k,v in pairs(object:getSkills()) do
            --判断怒气值消耗
            if not object:isBeSkill(v.id) and object:getCDs():isCooldownedById(v.id)
                and object:checkCondition(v.id)
            then
                return v
            end
        end
        return nil
    end
    self:bindMethod(object,"getSelectSkill", getSelectSkill)
    --------------------------------------------------------------------------
    local function isBeSkill(object,skillId)
        local skillData = configMgr:getConfig("skills"):GetSkillData(skillId)
        if skillData.type == SkillDefine.UseType_Passivity then
            return true
        end
        return false
    end
    self:bindMethod(object,"isBeSkill", isBeSkill)
    --------------------------------------------------------------------------
    local function getSkill(object,skillId)
        if object.skills_ == nil and table.nums(object.skills_) <=0 then
            return nil
        end
        local typeId = skillId/1000
        local s = nil
        table.walk(object.skills_, function(v,k)
            if typeId==v.typeId then
                s=v
                return
            end
        end)
        return s
    end
    self:bindMethod(object,"getSkill", getSkill)
    --------------------------------------------------------------------------
    local function addSkill(object,skill)
        -- print("addSkill for info:")
        -- table.walk(skill, function( v,k)
        --     print(k,v)
        -- end)
        assert(object:getSkill(skill.id) == nil, "addSkill() typeId is exist")
        table.insert(object.skills_,skill)
        --主动技能
        if skill.useType==SkillDefine.UseType_Auto then
            if not object.skillsByUseType_[skill.useType] then
                object.skillsByUseType_[skill.useType]={}
            end
            object.skillsByUseType_[skill.useType][skill.typeId]=skill
        else
            if not object.skillsByUseType_[SkillDefine.UseType_Passivity] then
                object.skillsByUseType_[SkillDefine.UseType_Passivity]={}
            end
           object.skillsByUseType_[SkillDefine.UseType_Passivity][skill.typeId]=skill
        end

    end
    self:bindMethod(object,"addSkill",addSkill)
    --------------------------------------------------------------------------
    --技能数值修改相关
    local function refixSkill( object ,skillInfo)
        object:skillRefix(skillInfo)
        object:impactRefix(skillInfo)
    end
    self:bindMethod(object,"refixSkill",refixSkill)
    local function skillRefix(object,skillInfo)
        -- body
    end
    self:bindMethod(object,"skillRefix",skillRefix)
    local function impactRefix(object,skillInfo)
        for k,v in pairs(object.impacts_) do
            local ownImpact = v
            local logic = Impact_GetLogic(object, ownImpact)
            if logic then
                logic:refixSkill(ownImpact,skillInfo)
            end
        end
    end
    self:bindMethod(object,"impactRefix",impactRefix)
    --------------------------------------------------------------------------
    --技能CD相关
    local function updataSkillCDs(object)
        object:getCDs():updata(1)
        if DEBUG_BATTLE.showSkillInfo then
            if table.nums(object:getCDs().cooldownList_) > 0 then
                print("--------------------------------------------------------------------")
            end
            for k,v in pairs(object:getCDs().cooldownList_) do
                printf("object = %s ,updataSkillCDs() - skilltype=%d cooldownElapsedVal_=%d cooldownAmountVal_=%d",
                    object:getId(),k,v.cooldownElapsedVal_,v.cooldownAmountVal_)
            end
        end

        local skillId=object:getTargetAndDepleteParams().skillId
        if skillId ==0 then
            return
        end
        if not object:getCDs():isCooldownedById(skillId) then return end
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        if skillIns.coolBoutTimes > 0 then
            object:getCDs():registerCooldown(skillId, skillIns.coolBoutTimes)
            if DEBUG_BATTLE.showSkillInfo then
                printf("object = %s,registerCooldown() - cooldownId=%d cooldownVal=%d",object:getId(),skillId,skillIns.coolBoutTimes)
            end
        end
    end
    self:bindMethod(object,"updataSkillCDs", updataSkillCDs)
    --------------------------------------------------------------------------
    local function getCDs(object)
        return object.cds_
    end
    self:bindMethod(object,"getCDs", getCDs)
    --------------------------------------------------------------------------
    local function isSkillCooldowned(object,skillId)
        return object:getCDs():isCooldownedById(skillId)
    end
    self:bindMethod(object,"isSkillCooldowned", isSkillCooldowned)
    --------------------------------------------------------------------------
    --技能规则相关
    local function getHeroSkillsOfSkillRule(object)
        local s = {}
        local skillRuleOfHero = object:getSkillRule()
        if skillRuleOfHero == CommonDefine.INVALID_ID then
            return s
        end
        s=configMgr:getConfig("heros"):getHeroSkills(skillRuleOfHero)
        return s
    end
    self:bindMethod(object,"getHeroSkillsOfSkillRule", getHeroSkillsOfSkillRule)
    local function getArmSkillsOfSkillRule(object)
        local armData = configMgr:getConfig("heros"):GetArmsData(object:getArmId())
        assert(armData~=nil,"getArmSkillsOfSkillRule():arm nil")
        local skillRuleOfArm = armData.skillRule
        local s=configMgr:getConfig("heros"):getArmSkills(skillRuleOfArm)

        return s
    end
    self:bindMethod(object,"getArmSkillsOfSkillRule", getArmSkillsOfSkillRule)
    --------------------------------------------------------------------------
    --创建技能
    local function createSkill(object,skillId,skillExp)
        local skillIns = configMgr:getConfig("skills"):GetSkillInstanceBySkillId(skillId)
        local skillTemp = configMgr:getConfig("skills"):GetSkillTemplate(skillId)
        local skillEffData = configMgr:getConfig("skills"):GetSkillEffect(skillId)
        local skill = {
            id=skillId,
            typeId=math.floor(skillId/1000),
            lev=math.floor(skillId%1000),
            exp=skillExp or 0,
            coolBoutTimes=skillIns.coolBoutTimes,
            consumeRage=skillIns.consumeRage,
            useType=skillTemp.type,
            nickname=skillTemp.nickname,
            hitTime=0,
        }
        if skillEffData then
            skill.hitTime=skillEffData.hitTime
        end
        return skill
    end
    self:bindMethod(object,"createSkill", createSkill)
    --------------------------------------------------------------------------
    --取得逻辑管理
    local function getImpactLogicByLogicId(object,logicId)
        return object:getMap().ImpactLogicManger_:getLogicByLogicId(logicId)
    end
    self:bindMethod(object,"getImpactLogicByLogicId", getImpactLogicByLogicId)
    local function getSkillLogicByLogicId(object,logicId)
        return object:getMap().SkillLogicManger_:getLogicByLogicId(logicId)
    end
    self:bindMethod(object,"getSkillLogicByLogicId", getSkillLogicByLogicId)
    --------------------------------------------------------------------------
end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function SkillBehavior:unbindMethods(object)
    self:unbindMethod(object,"useSkill")
    self:unbindMethod(object,"getSkill")
    self:unbindMethod(object,"getSkills")
    self:unbindMethod(object,"addSkill")
    self:unbindMethod(object,"getTargetAndDepleteParams")
    self:unbindMethod(object,"isSkillCooldowned")
    self:unbindMethod(object,"createSkill")
    self:unbindMethod(object,"initSkill")
    self:unbindMethod(object,"doAttack")
    self:unbindMethod(object,"isHit")
    self:unbindMethod(object,"getCDs")
    self:unbindMethod(object,"getHeroSkillsOfSkillRule")
    self:unbindMethod(object,"getArmSkillsOfSkillRule")
    self:unbindMethod(object,"isBeSkill")
    self:unbindMethod(object,"Impact_GetIntAttRefix")
    self:unbindMethod(object,"Impact_GetBoolAttRefix")
end
------------------------------------------------------------------------------
return SkillBehavior
------------------------------------------------------------------------------