--
-- Author: Anthony
-- Date: 2014-06-26 10:51:39
--
----------------------------------------------------------------
local ObjectFactory = {}
----------------------------------------------------------------
local Hero      = import(".models.Hero")
local HeroView  = import(".views.HeroView")
local Build     = import(".models.Build")
local BuildView = import(".views.BuildView")
local SpecialObj     = import(".models.SpecialObj")
local SpecialObjView = import(".views.SpecialObjView")
----------------------------------------------------------------
function ObjectFactory.newObject(map,classId, objId, viewParams, properties)
    local objectView

    -- 合并属性
    local defaultProperties = {
        id = objId;
    }
    table.merge(defaultProperties, checktable(properties))

    if classId == "hero" then -- 英雄
        local object = Hero.new(defaultProperties,map)
        object:init()
        objectView = HeroView.new(object,viewParams)
        objectView:init(object,viewParams)
    elseif classId == "build" then --建筑
        local object = Build.new(defaultProperties,map)
        object:init()

        objectView = BuildView.new(object,viewParams)
        objectView:init(object,viewParams)
    elseif classId == "special_obj" then
        local object = SpecialObj.new(defaultProperties,map,viewParams)
        object:init()
        objectView = SpecialObjView.new(object,viewParams)
        objectView:init(object,viewParams)
    else
        assert(false, string.format("ObjectFactory:newObject() - invalid classId %s", tostring(classId)))
    end

    return objectView
end
----------------------------------------------------------------
return ObjectFactory