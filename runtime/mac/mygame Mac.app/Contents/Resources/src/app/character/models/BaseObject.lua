--
-- Author: wangshaopei
-- Date: 2014-11-05 17:53:39
--
------------------------------------------------------------------------------
--[[--
”BaseObject“类
]]
------------------------------------------------------------------------------
-- 全局的行为管理器
BehaviorsManager    = import("..controllers.behaviors.BehaviorsManager")
------------------------------------------------------------------------------
local BaseObject = class("BaseObject", cc.mvc.ModelBase)
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- 定义属性
------------------------------------------------------------------------------
BaseObject.schema = clone(cc.mvc.ModelBase.schema)
BaseObject.schema["typename"]          = {"string"}        -- 类型
BaseObject.schema["campId"]            = {"number", 0}     -- 阵营
function BaseObject:ctor(properties,map)
    BaseObject.super.ctor(self, properties)
    self.map_=map
    self._is_active=true
end

------------------------------------------------------------------------------
-- 类开始处理
------------------------------------------------------------------------------
function BaseObject:init()
    if self.behaviors_ == nil then
        -- 默认绑定AI行为
        self.behaviors_  = {"AICharacterBehavior"}
    end
    BehaviorsManager:initBehaviors(self)
end
------------------------------------------------------------------------------
function BaseObject:getType()
    return self.typename_
end
------------------------------------------------------------------------------
-- 对象所在地图
function BaseObject:getMap()
    return self.map_
end
------------------------------------------------------------------------------
function BaseObject:IsActiveObj()
    return self._is_active
end
------------------------------------------------------------------------------
function BaseObject:SetActive(b)
    self._is_active = b
end
------------------------------------------------------------------------------
-- id由 类型:递增编号 组成,例："hero:1","hero:2"
function BaseObject:getId()
    return self.id_
end
------------------------------------------------------------------------------
--
function BaseObject:getClassId()
    local classId, index = unpack(string.split(self.id_, ":"))
    return classId
end
------------------------------------------------------------------------------
-- 递增编号
function BaseObject:getIndex()
    local classId, index = unpack(string.split(self.id_, ":"))
    return tonumber(index)
end
------------------------------------------------------------------------------
return BaseObject
------------------------------------------------------------------------------