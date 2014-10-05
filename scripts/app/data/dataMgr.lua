--
-- Author: Anthony
-- Date: 2014-07-14 11:15:37
--
--[[

通用数据存储

]]

--[[包含所有 DATA]]
local _datas = {
    "DATA_User",
    "DATA_Formation",
    "DATA_Hero",
}

for i = 1 , #_datas do
    require("app.data." .. _datas[i])
end


local M = {}

--[[初始化]]
function M.init()
    for i = 1 , #_datas do
        require("app.data." .. _datas[i]):init()
    end
end

-- --[[处理公用数据]]
-- function M.saveCommonData( data )
--     local result = data["result"]
--     if type(result) ~= "table" then return false end
--     --dump(result["_G_general_stage_conf"])
--     -- 存储数据

--     return true
-- end


return M
