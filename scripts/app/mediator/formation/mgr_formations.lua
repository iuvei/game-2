--
-- Author: Anthony
-- Date: 2014-10-13 16:01:25
-- 阵形数据管理器
----------------------------------------------------------------
local client_formation = import(".client_formation")
----------------------------------------------------------------
local M = class("mgr_formations")
----------------------------------------------------------------
function M:ctor(player)
	self.__data = {}
    self.player = player
end
----------------------------------------------------------------
--
----------------------------------------
-- 得到所有数据
function M:get()
	return self.__data
end
----------------------------------------
function M:set( data )

    for i , v in pairs(data) do
        local nd = client_formation.new(v)
        self.__data[tonumber(i)] = nd
    end

    -- print("---------set_formations")
    -- dump(self.__data)
end
----------------------------------------
function M:remove(index)
    for k, v in pairs(self.__data) do
        if tonumber(v:get("index")) == tonumber(index) then
            -- print("fomation:remove",v:get("GUID"),v:get("dataId"),index)
            table.remove(self.__data,k)
        end
    end
end
----------------------------------------
--
function M:insertByPos(index,data)
    data.index  = index
    local newdata = client_formation.new(data)
    -- print("insertByPos",newdata:get("GUID"),newdata:get("dataId"),newdata:get("index"))
    table.insert(self.__data,newdata)

    -- dump(self.__data)
end
----------------------------------------
-- 刷新数据，如果存在会先删除
function M:addData( index, data )
	-- 先删除
    self:remove(index)

    -- 有数据则加入
    if data then
        self:insertByPos(index,data)
    end
end
----------------------------------------
-- 更新位置根据GUID
function M:updatePosByGUID(GUID,index)
    for k, v in pairs(self.__data) do
        if tonumber(v:get("GUID")) == tonumber(GUID) then
            -- print("fomation:updatePosByGUID",v:get("GUID"),v:get("dataId"),index)
            v:setkey("index",index)
        end
    end
end
----------------------------------------------------------------
-- 逻辑处理函数
----------------------------------------
-- 更新数据到服务端
-- pos为位置编号,总共5个位
function M:update_server_fomation( pos, herodata )
    if CHANNEL_ID ~= "test" then
        local formation = nil
        if herodata then
            formation   = {
                index   = herodata.index,
                GUID    = herodata.GUID,
                dataId  = herodata.dataId,
            }
        end

        -- dump(herodata)

        self.player:send("CS_UpdateFormation", {
            playerid    = self.player:get_playerid(),
            pos         = pos,
            formation   = formation
        })
    end
end
----------------------------------------------------------------
return M
----------------------------------------------------------------