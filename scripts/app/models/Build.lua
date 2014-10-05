--
-- Author: Your Name
-- Date: 2014-08-04 15:28:07
--
--[[
建筑类
]]


local Object = import(".Object")
local Build = class("Build", Object)

------------------------------------------------------------------------------
-- properties
------------------------------------------------------------------------------
Build.schema = clone(Object.schema)

function Build:ctor(properties,map)
    -- 没有配置行为，则默认添加
    if properties.behaviors == nil then
        self.behaviors_ = {"StateMachineBehavior","DestroyedBehavior","SkillBehavior"}
    end

    Build.super.ctor(self, properties,map)
end
------------------------------------------------------------------------------
-- 防御力
-- function Build:getDefense()
--     -- 基本属性 + 其他属性
--     return Build.super.getBaseDefense(self)
-- end
return Build