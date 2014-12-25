--
-- Author: Anthony
-- Date: 2014-08-04 18:13:29
-- 大阵形的处理
-- ------------------------------------------------------------------------------
-- collectgarbage("setpause" , 100)
-- collectgarbage("setstepmul" , 5000)
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
--[[
@ fId: 阵形编号
@ _callback: 若 第一个参数 == true，则index为阵形编号
             若 第二个参数 == false, 则index不为阵形编号
@ return:
]]
function M:build( fId, _callback )
    local function gen( index,formaion )
        local i, j = string.find(formaion, index)
        if i then _callback(true,index);
        else _callback(false,index);
        end
    end

    -- 生成
    for index=1,9 do
        if fId == 1 then      gen( index, "2,4,5,6,8" ) -- 鱼鳞阵
        elseif fId == 2 then  gen( index, "2,3,4,5,7" ) -- 长蛇阵
        elseif fId == 3 then  gen( index, "1,2,3,4,5" ) -- 乱剑阵
        elseif fId == 4 then  gen( index, "2,3,6,8,9" ) -- 方圆阵
        elseif fId == 5 then  gen( index, "1,4,5,6,7" ) -- 虎韬阵
        elseif fId == 6 then  gen( index, "1,3,4,7,9" ) -- 鹤翼阵
        elseif fId == 7 then  gen( index, "1,3,5,7,9" ) -- 箕行阵
        elseif fId == 8 then  gen( index, "2,3,4,8,9" ) -- 雁形阵
        elseif fId == 9 then  gen( index, "1,2,6,7,8" ) -- 锥形阵
        elseif fId == 10 then gen( index, "3,4,5,6,9" ) -- 锋矢阵
        end
    end
end
------------------------------------------------------------------------------
-- 位置编号转为坐标
--[[
@ index: 阵形位置编号
@ param.Left: 是否在左边
@ param.callback: 回调函数，用来转化为地图坐标
@ return: 转化后的坐标
]]
function M:indexToPos( index, param )

    if param == nil then param = {} end

    local function getPos( position, refix)
        local pos = param.getValue(position)
        pos.x = pos.x + refix
        return pos
    end
    if param.Left then
        if index == 1 then     return getPos( cc.p(1,4), 25 )
        elseif index == 2 then return getPos( cc.p(2,4), 25 )
        elseif index == 3 then return getPos( cc.p(3,4), 25 )
        elseif index == 4 then return getPos( cc.p(1,5), 0 )
        elseif index == 5 then return getPos( cc.p(2,5), 0 )
        elseif index == 6 then return getPos( cc.p(3,5), 0 )
        elseif index == 7 then return getPos( cc.p(1,6), -25 )
        elseif index == 8 then return getPos( cc.p(2,6), -25 )
        elseif index == 9 then return getPos( cc.p(3,6), -25 )
        end
    else
        if index == 1 then     return getPos( cc.p(9,4),  -25 )
        elseif index == 2 then return getPos( cc.p(10,4), -25 )
        elseif index == 3 then return getPos( cc.p(11,4), -25 )
        elseif index == 4 then return getPos( cc.p(9,5),  0 )
        elseif index == 5 then return getPos( cc.p(10,5), 0 )
        elseif index == 6 then return getPos( cc.p(11,5), 0 )
        elseif index == 7 then return getPos( cc.p(9,6),  25 )
        elseif index == 8 then return getPos( cc.p(10,6), 25 )
        elseif index == 9 then return getPos( cc.p(11,6), 25 )
        end
    end
 end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------