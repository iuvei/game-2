--
-- Author: wangshaopei
-- Date: 2014-11-06 16:03:09
-- 记录陷阱
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr    = require("config.configMgr")         -- 配置

local ImpactLogic = import(".ImpactLogic")
----------------------------------------------------------------
local LogicImpact018 = class("LogicImpact018",ImpactLogic)
----------------------------------------------------------------
LogicImpact018.ID=SkillDefine.LogicImpact018
function LogicImpact018:ctor()
end
function LogicImpact018:initFromData(ownImpact,impactData)
    return true
end
--是否驻留
function LogicImpact018:isInvervaled()
    return false
end
--是否被延长时间
function LogicImpact018:isOverTimed()
    return true
end
function LogicImpact018:specialCDCheck(rMe,own_impact)
    local count = 0
    for i=1,3 do
        local special_id = own_impact:getParameterByIndex(i)
        if special_id then
            local special_obj_view = rMe:getMap():getObject(special_id)
            if special_obj_view then
                local special_obj = special_obj_view:GetModel()
                if special_obj:IsFadeOut() then
                    own_impact:setParameterByIndex(i, nil)
                 end
            else
                own_impact:setParameterByIndex(i, nil)
            end
            count = count + 1
        end
    end
    if count <= 0 then
        -- 没有陷阱一回合后消失
        if own_impact:getCD():getCooldownAmountVal() == -1 then
            own_impact:getCD():setCooldownAmountVal(1)
            own_impact:getCD():setCooldownElapsedVal(0)
        end
    else
        -- 有陷阱，永不消失
        if own_impact:getCD():getCooldownAmountVal() >= 0 then
            own_impact:getCD():setCooldownAmountVal(-1)
            own_impact:getCD():setCooldownElapsedVal(0)
        end
    end
    return true
end

function LogicImpact018:AddNewTrap(own_impact,rMe,specail_obj_id)
    local b = false
    local index = 0
    for i=1,3 do
        local special_id = own_impact:getParameterByIndex(i)
        if special_id then
            local special_obj_view = rMe:getMap():getObject(special_id)
            if special_obj_view then
            local special_obj = special_obj_view:GetModel()
                if special_obj:IsFadeOut() then
                    b=true
                    own_impact:setParameterByIndex(i, specail_obj_id)
                    break
                 end
            end
        end
    end
    if b==false then
        own_impact:setParameterByIndex(index+1, specail_obj_id)
    end
end
return LogicImpact018