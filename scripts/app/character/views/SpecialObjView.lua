--
-- Author: wangshaopei
-- Date: 2014-11-05 18:11:06
--
local EffectFadeInOut = require("common.effect.FadeInOut")
------------------------------------------------------------------------------
local SpecialObjView = class("SpecialObjView", import(".ObjectView"))
------------------------------------------------------------------------------
function SpecialObjView:ctor(model,params)
    -- 父类
    SpecialObjView.super.ctor(self,model,params)
end
------------------------------------------------------------------------------
function SpecialObjView:init(model,params)
    SpecialObjView.super.init(self,model,params)

    --self:GetSprite():setScale(0.2)

    -- self:GetModel():createView(self:GetBatch("hero"))
    self:createImpactEffect(params.res_effect_id,true,params.effectPoint)
    self:updateView()

end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
return SpecialObjView
------------------------------------------------------------------------------