--
-- Author: Anthony
-- Date: 2014-06-26 10:52:19
--
----------------------------------------------------------------
local MapConstants  = require("app.ac.MapConstants")
local ObjectFactory = import(".ObjectFactory")
----------------------------------------------------------------
-- obj管理器
----------------------------------------------------------------
local ObjectManager = class("ObjectManager")
----------------------------------------------------------------
function ObjectManager:ctor()

end
----------------------------------------------------------------
function ObjectManager:init()
    self.objects_           = {}
    self.objectsByClass_    = {}
    self.objectsByCamp_     = {}
    self.nextObjectIndex_   = 1
end
----------------------------------------------------------------
--创建新的对象
function ObjectManager:newObject(parent,classId,properties,viewParams, id)
    if not id then
        -- print("···",classId,self.nextObjectIndex_)
        id = string.format("%s:%d", classId, self.nextObjectIndex_)
        self.nextObjectIndex_ = self.nextObjectIndex_ + 1
    end

    local object = ObjectFactory.newObject(parent,classId, id,viewParams, properties)
        :addTo(parent,MapConstants.MAP_Z_1_0)

    -- validate max object index
    local index = object:GetModel():getIndex()
    if index >= self.nextObjectIndex_ then
        self.nextObjectIndex_ = index + 1
    end

    -- add object
    self.objects_[id] = object
    if not self.objectsByClass_[classId] then
        self.objectsByClass_[classId] = {}
    end
    self.objectsByClass_[classId][id] = object

    local campId = object:GetModel():getCampId()
    if not self.objectsByCamp_[campId] then
        self.objectsByCamp_[campId] = {}
    end
    self.objectsByCamp_[campId][id] = object

    return object
end
----------------------------------------------------------------
--删除一个对象
function ObjectManager:removeObject(object)
    local id = object:GetModel():getId()
    assert(self.objects_[id] ~= nil, string.format("ObjectManager:removeObject() - object %s not exists", tostring(id)))

    self.objects_[id] = nil
    self.objectsByClass_[object:GetModel():getClassId()][id] = nil
    self.objectsByCamp_[object:GetModel():getCampId()][id] = nil
    -- object:remove()
    object:removeSelf()
end
----------------------------------------------------------------
--删除指定 Id 的对象
function ObjectManager:removeObjectById(objectId)
    self:removeObject(self:getObject(objectId))
end
----------------------------------------------------------------
--删除所有对象
function ObjectManager:removeAllObjects()
    for id, object in pairs(self.objects_) do
        self:removeObject(object)
    end
    self.objects_           = {}
    self.objectsByClass_    = {}
    self.objectsByCamp_     = {}
    self.nextObjectIndex_   = 1
end
----------------------------------------------------------------
--检查指定的对象是否存在
function ObjectManager:isObjectExists(id)
    return self.objects_[id] ~= nil
end
----------------------------------------------------------------
--返回指定 Id 的对象
function ObjectManager:getObject(id)
    -- assert(self:isObjectExists(id), string.format("ObjectManager:getObject() - object %s not exists", tostring(id)))
    if self:isObjectExists(id) then
        return self.objects_[id]
    else
        return nil
    end
end
----------------------------------------------------------------
--返回所有的对象
function ObjectManager:getAllObjects()
    return self.objects_
end
----------------------------------------------------------------
--返回特定类型的对象
function ObjectManager:getObjectsByClassId(classId)
    -- dump(self.objectsByClass_[classId])
    return self.objectsByClass_[classId] or {}
end
----------------------------------------------------------------
--返回
function ObjectManager:getObjectsByCamp(CampId)
    -- dump(self.objectsByCamp_[CampId])
    return self.objectsByCamp_[CampId] or {}
end
----------------------------------------------------------------
return ObjectManager