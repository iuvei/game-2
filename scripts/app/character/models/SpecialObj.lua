--
-- Author: wangshaopei
-- Date: 2014-11-05 18:10:42
--
local BaseObject = import(".BaseObject")
local Cooldown = import("app.ac.Cooldown")
local SpecialObj = class("SpecialObj", BaseObject)

------------------------------------------------------------------------------
-- properties
------------------------------------------------------------------------------
SpecialObj.schema = clone(BaseObject.schema)

function SpecialObj:ctor(properties,map)
    -- 没有配置行为，则默认添加
    if properties.behaviors == nil then
        self.behaviors_ = {"CampBehavior"}
    end
    SpecialObj.super.ctor(self, properties,map)
    self._conf_data = properties
    self._map = map
    self._owner_obj = properties.owner
    self._ower_obj_id = self._owner_obj:getId()
    self._is_fade_out = false
    self._cd=Cooldown.new(self._conf_data.keepBoutNum)
    self.view_=nil
end
function SpecialObj:setView(objView)
     self.view_=objView
end
function SpecialObj:getView()
    return self.view_
end
--是否渐没完成
function SpecialObj:IsFadeOut()
    return self._is_fade_out
end
function SpecialObj:SetFadeOut(b)
    self._is_fade_out = b
end
function SpecialObj:OnUpdata()
    if not self._cd:isCooldowned() then
        -- self:_OnUpdata()
    end
    --更新cd
    self._cd:updata(1)
    if self._cd:isCooldowned() then
        self._is_fade_out = true
        self:SetActive(false)
    end
end
function SpecialObj:_OnUpdata()
    local special_logic = self._map.SpecialLogicManger_:getLogicByLogicId(self._conf_data.logicId)
    if special_logic then
        special_logic:OnUpdata(self)
    end
end
function SpecialObj:OnUpdataAndTriggerObj(trigger_obj)
    self:SetTriggerObj(trigger_obj)
    self:_OnUpdata()
end
function SpecialObj:GetTriggerObj()
    return self._trigger_obj
end
function SpecialObj:SetTriggerObj(trigger_obj)
    self._trigger_obj = trigger_obj
end
function SpecialObj:removeView()
    self:getView():removeImpactsEffect()
end
------------------------------------------------------------------------------
return SpecialObj
------------------------------------------------------------------------------