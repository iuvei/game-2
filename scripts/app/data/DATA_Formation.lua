--
-- Author: Anthony
-- Date: 2014-07-14 11:19:06
--
--[[

编队数据

]]
------------------------------------------------------------------------------
G_DefaultSelectedFormation = 1 -- 全局阵形默认选中
------------------------------------------------------------------------------
DATA_Formation = {}
------------------------------------------------------------------------------
-- 私有变量
local _data = {}
------------------------------------------------------------------------------
function DATA_Formation:init()
    _data = {}
end
------------------------------------------------------------------------------
function DATA_Formation:set(data)
    _data = data
end
------------------------------------------------------------------------------
function DATA_Formation:insert(data)
    for i , v in pairs(data) do
        v.data.index = v.index --设置位置
        _data[tonumber(i)] = v.data
    end
end
------------------------------------------------------------------------------
function DATA_Formation:get_data()
    return _data
end
------------------------------------------------------------------------------
function DATA_Formation:get(...)
    local result = _data
    for i = 1, arg["n"] do
        if not result then
--          print(arg[i],"字段未找到")
            break
        end
        if arg[i] then
            result = result[arg[i]..""]
        end
    end
    return result
end
------------------------------------------------------------------------------
function DATA_Formation:get_lenght()
    -- return table.getn(_data)
    -- local count = 1
    -- for k, v in pairs(_data) do
    --     count = count + 1
    -- end
    -- return count
    return table.nums(_data)
end
------------------------------------------------------------------------------
--检查对应cid是否在阵
function DATA_Formation:checkOnByGUID(GUID)
    local exist = false
    for k, v in pairs(_data) do
        if tonumber(v.GUID) == tonumber(GUID) then
            exist = true
        end
    end
    return exist
end
------------------------------------------------------------------------------
--
function DATA_Formation:insertByIndex(index,data)
    data.index  = index
    local count = 1
    for k, v in pairs(_data) do
        count = count + 1
    end
    _data[count] = data
    -- print(count,data.index)
end
------------------------------------------------------------------------------
--
function DATA_Formation:SetIndex(GUID,index)
    for k, v in pairs(_data) do
        if tonumber(v.GUID) == tonumber(GUID) then
            -- print("SetIndex",GUID,index)
            v.index = index
        end
    end
end
------------------------------------------------------------------------------
function DATA_Formation:haveData(index)
    for k, v in pairs(_data) do
        if tonumber(v.index) == tonumber(index) then
            return true
        end
    end
    return false
end
------------------------------------------------------------------------------
function DATA_Formation:haveDataByGUID(GUID)
    for k, v in pairs(_data) do
        if tonumber(v.GUID) == tonumber(GUID) then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------
--
function DATA_Formation:Remove(index)
    for k, v in pairs(_data) do
        if tonumber(v.index) == tonumber(index) then
            -- print("DATA_Formation:Remove",index)
            table.remove(_data,k)
        end
    end
end
------------------------------------------------------------------------------
-- 刷新数据，如果存在会先删除
function DATA_Formation:addData( index, data )
    if DATA_Formation:haveData(index) then
        -- print("有数据删除",data.index, index)
        DATA_Formation:Remove(index)
    end
    -- 有数据则加入
    if data then
        DATA_Formation:insertByIndex(index,data)
    end
end
------------------------------------------------------------------------------
return DATA_Formation
------------------------------------------------------------------------------