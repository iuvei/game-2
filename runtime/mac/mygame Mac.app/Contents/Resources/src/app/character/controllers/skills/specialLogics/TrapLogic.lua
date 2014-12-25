--
-- Author: wangshaopei
-- Date: 2014-11-05 17:03:56
--
local MapConstants  = require("app.ac.MapConstants")
local SkillDefine=require("app.character.controllers.skills.SkillDefine")
local CommonDefine = require("app.ac.CommonDefine")
local configMgr       = require("config.configMgr")         -- 配置
local SpecialLogic = import(".SpecialLogic")
local TrapLogic = class("TrapLogic",SpecialLogic)
TrapLogic.ID=1
function TrapLogic:ctor()

end
function TrapLogic:OnUpdata(special_obj)
    self:_Activate(special_obj)
end
function TrapLogic:_Activate(special_obj)
    if special_obj:IsFadeOut() then
        return
    end
    local options = {out_target_views={},cell_positions={},sender_obj_id = special_obj._owner_obj:getId()}
    local data = special_obj._conf_data
    --set target type
    options.target_type = "player"
    if data.targetType == 1 then -- 目标对全体敌人
        if special_obj:getEnemyCampId() == MapConstants.ENEMY_CAMP then
            options.target_type = "enemy"
        end
    elseif data.targetType == 2 then
        if special_obj:getCampId() == MapConstants.ENEMY_CAMP then
            options.target_type = "enemy"
        end
    end

    if data.affectRangeType == 1 then -- 十字型
        local coords = {{0,0},{0,-1},{0,1},{-1,0},{1,0}} --  mid,up,down,left,right
        for i,v in ipairs(coords) do
            table.insert(options.cell_positions,cc.p(special_obj:getView():getCellPos().x+v[1],special_obj:getView():getCellPos().y+v[2]))
        end
    end
    special_obj._map:scan(options) -- options={out_targets,cell_positions,target_type}
    local trigger_obj=special_obj:GetTriggerObj()
    if trigger_obj then
        for i,v in ipairs(options.out_target_views) do
            if trigger_obj:getId() == v:GetModel():getId() then
                self:_EffectOnChar(special_obj,v:GetModel())
                special_obj:SetTriggerObj(nil)
                break
            end
        end
    else
        -- issue : 会执行到这里？
        for i,v in ipairs(options.out_target_views) do
            self:_EffectOnChar(special_obj,v:GetModel())
        end
    end
end
function TrapLogic:_EffectOnChar(special_obj,target_obj)
    local data = special_obj._conf_data
    local impact_id = data.param1
    -- local impact_id=310001
    ImpactCore:sendImpactToUnit_(target_obj, impact_id, special_obj._owner_obj, false)
end
-------------------------------------------------------------------------
return TrapLogic
-------------------------------------------------------------------------