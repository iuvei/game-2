--
-- Author: Anthony
-- Date: 2014-07-16 17:21:17
--
--[[

hero数据
_data = { { GUID= 100,typeID = 1,quality=1,camp=0} }
]]
DATA_Hero = {}
------------------------------------------------------------------------------
local _data = {}
------------------------------------------------------------------------------
function DATA_Hero:init()
    _data = {}
end
------------------------------------------------------------------------------
function DATA_Hero:set(data)
    _data = data
end
------------------------------------------------------------------------------
function DATA_Hero:insert(data)
    for i , v in pairs(data) do
        local gid = tonumber(i)
        _data[gid] = v
    end
end
------------------------------------------------------------------------------
function DATA_Hero:setByKey(index , key , data)
    _data[index][key] = data
end
------------------------------------------------------------------------------
function DATA_Hero:get(...)
    local result = _data
    for i = 1, arg["n"] do
        if not result then
            print(arg[i],"字段未找到")
            break
        end

        if arg[i] then
            result = result[arg[i]]
        end
    end
    return result
end
------------------------------------------------------------------------------
function DATA_Hero:getTable(gid)
    gid = tonumber(gid)
    return _data[gid]
end
------------------------------------------------------------------------------
function DATA_Hero:haveData(index)
    if index then
        if _data[index] then
            return true
        end
    else
        if #_data > 0 then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------
function DATA_Hero:get_lenght()
    return table.getn(_data)
end
------------------------------------------------------------------------------
return DATA_Hero
------------------------------------------------------------------------------