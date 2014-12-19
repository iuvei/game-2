--
-- Author: wangshaopei
-- Date: 2014-11-05 17:02:15
--
local CommonDefine = require("app.ac.CommonDefine")
local SpecialLogic = class("SpecialLogic")
function SpecialLogic:ctor()
    self._is_fade_out = false
end
function SpecialLogic:OnUpdata(special_obj)

end
return SpecialLogic