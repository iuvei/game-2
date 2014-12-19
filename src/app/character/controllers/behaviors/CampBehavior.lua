--
-- Author: Anthony
-- Date: 2014-07-03 15:54:44
-- CampBehavior
------------------------------------------------------------------------------
local MapConstants = require("app.ac.MapConstants")
------------------------------------------------------------------------------
local BehaviorBase = import(".BehaviorBase")
local CampBehavior = class("CampBehavior", BehaviorBase)
------------------------------------------------------------------------------
function CampBehavior:ctor()
    CampBehavior.super.ctor(self, "CampBehavior", nil, 1)
end

------------------------------------------------------------------------------
function CampBehavior:bind(object)
    -- object.campId_ = checkint(object.state_.campId)
    if object.campId_ == nil and object.campId_ ~= MapConstants.ENEMY_CAMP and object.campId_ ~= MapConstants.PLAYER_CAMP then
        object.campId_ = MapConstants.ENEMY_CAMP
    end

    self:bindMethods(object)
end
------------------------------------------------------------------------------
function CampBehavior:unbind(object)
    object.campId_ = nil
    slef:unbindMethods(object)
end
------------------------------------------------------------------------------
function CampBehavior:bindMethods(object)

    ----------------------------------------
    -- 得到阵营ID
    local function getCampId(object)
        return object.campId_
    end
    self:bindMethod(object,"getCampId", getCampId)
    ----------------------------------------
    -- 取得对立的阵营ID
    local function getEnemyCampId(object)
        if object:getCampId() == MapConstants.PLAYER_CAMP then
            return MapConstants.ENEMY_CAMP
        elseif object:getCampId() == MapConstants.ENEMY_CAMP then
            return MapConstants.PLAYER_CAMP
        end
    end
    self:bindMethod(object,"getEnemyCampId", getEnemyCampId)
    ----------------------------------------
    -- 得到阵营ID
    local function setCampId(object,campId)
        object.campId_ = campId
    end
    self:bindMethod(object,"setCampId", setCampId)

    ----------------------------------------
    -- 是否敌人
    local function isEnemyByObj(object,target)
        if object:getCampId() ~= target:getCampId() then
            return true
        else
            return false
        end
    end
    self:bindMethod(object,"isEnemyByObj", isEnemyByObj)
    ----------------------------------------
    -- 是否敌人
    local function isEnemy(object)
        if object:getCampId() ~= MapConstants.PLAYER_CAMP then
            return true
        else
            return false
        end
    end
    self:bindMethod(object,"isEnemy", isEnemy)

end
------------------------------------------------------------------------------
-- 卸载绑定的函数
function CampBehavior:unbindMethods(object)
    self:unbindMethod(object,"getCampId")
    self:unbindMethod(object,"setCampId")
    self:unbindMethod(object,"isEnemy")
    self:unbindMethod(object,"getEnemyCampId")
end
------------------------------------------------------------------------------
return CampBehavior
