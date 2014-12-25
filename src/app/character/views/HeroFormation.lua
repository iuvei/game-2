--
-- Author: Anthony
-- Date: 2014-08-04 18:56:58
-- 英雄方阵的处理
------------------------------------------------------------------------------
local CList         =  require("common.List.List")
local MapConstants  = require("app.ac.MapConstants")
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
-- 得到阵形的默认人数
function M:getFormationMaxCount( fId )
    local count = 9
    if fId == 1 then
        count = 7
    elseif fId == 2 then
        count = 7
    end

    return count
end
------------------------------------------------------------------------------
-- 方阵, 总的生成9个sprite，一个不显示。
function M:handleFormation(parent, action, Params)
    --------------------------------
    -- 处理死亡
    if action == "dead" then
        local fId = parent:GetModel():getFormationId()
        local maxFN = self:getFormationMaxCount( fId )
        --------------------------------
        -- 根据HP减少方阵的人数
        if parent.lastCount_ == nil then parent.lastCount_ = maxFN end

        local h = parent:GetModel()
        -- 得到当前方阵人数
        local num_ = math.ceil((h:getHp()/h:getMaxHp())*maxFN)

        -- 只剩下一只时，不删除，交给外部删除
        if parent.lastCount_ <= 1 then parent.lastCount_ = num_; return; end

        self:RemoveSpriteLand(parent,(parent.lastCount_ - num_),Params.callback)
        parent.lastCount_ = num_
        --------------------------------
        return
    end

    -- --------------------------------
    -- -- 处理其他
    --
    if action == "create" then -- 创建

        --------------------------------
        -- 如果没有创建第一只，则创建,放在方阵中间
        if parent.sprite_ == nil then
            parent.sprite_ = display.newSprite(Params.img)
                            :addTo(parent:GetBatch(),MapConstants.MAX_OBJECT_ZORDER)
        end
        parent.sprite_:setScale(0.6)
        parent.sprite_:setOpacity(0) -- 设置透明不显示
        --------------------------------
        --
        if parent.spriteLand == nil then parent.spriteLand = CList.new() end
        --------------------------------
        --
        local fId = parent:GetModel():getFormationId()
        local maxFN = self:getFormationMaxCount( fId )
        for i = 1, maxFN do
            local sprite___ = display.newSprite(Params.img)
                :scale(parent.sprite_:getScale())
                :flipX(parent.sprite_:isFlippedX())
                :addTo(parent:GetBatch())
            parent.spriteLand:push_front( sprite___ )
        end
    --------------------------------
    elseif action == "update" then -- 更新位置

        local spriteLand = parent.spriteLand
        if spriteLand == nil then return end

        local fId = parent:GetModel():getFormationId()
        local index = 1
        -- 遍历
        spriteLand:traversal(function(sprite)
            local xpos, ypos = 0, 0

            --以屏幕中间为界限，来处理方阵
            local dir = 3 -- 默认为中间
            if     Params.x <= display.cx - 50 then dir = 1
            elseif Params.x >= display.cx + 50 then dir = 2
            end
            -- 得到坐标
            if     fId == 1 then xpos, ypos = self:getTuJinPos( dir, index, Params)
            elseif fId == 2 then xpos, ypos = self:getYuHuiPos( dir, index, Params)
            elseif fId == 3 then xpos, ypos = self:getBaoWeiPos( dir, index, Params)
            elseif fId == 4 then xpos, ypos = self:getjianMiePos(dir,index, Params)
            elseif fId == 5 then xpos, ypos = self:getQiangGongPos( dir, index, Params)
            elseif fId == 6 then xpos, ypos = self:getRouBoPos( dir, index, Params)
            end

            sprite:setPosition(xpos,ypos)
            -- 按Y轴重新排列Z轴
            parent:GetBatch():reorderChild(sprite, MapConstants.MAX_OBJECT_ZORDER-ypos)
            -- 记数
            index = index + 1
        end)
    --------------------------------
    elseif action == "callback" then --回调
        local spriteLand = parent.spriteLand
        if spriteLand == nil then return end
        -- 遍历
        spriteLand:traversal(function(sprite)
            Params.callback(sprite)
        end)
    else
        print("handleFormation erro action",action)
        return
    end -- end if
end
------------------------------------------------------------------------------
function M:RemoveSpriteLand(parent,diffNum,_callback)

    while diffNum > 0 do
        local _sprite = parent.spriteLand:back()
        parent.spriteLand:pop_back()

        if _callback == nil then
            -- 没有设置，则直接删除
            _sprite:removeFromParentAndCleanup(true)
            _sprite = nil
        else
            -- 回调处理
            _callback( _sprite, function()
                if _sprite then
                    _sprite:removeFromParentAndCleanup(true)
                    _sprite = nil
                end
            end)
        end
        diffNum = diffNum -1
    end
    -- print( parent.spriteLand:size())
end
------------------------------------------------------------------------------
-- 突进阵
function M:getTuJinPos(dir,index,Params)
    local size = Params.contentSize
    local xpos, ypos =  0,0

    local offsetX = 0 -- X的偏移
    local indexOffsetX = 0 --角度偏移
    local allOffsetX = 0 -- 所有的偏移

    if Params.isFlipX then -- 是否翻转
        --[[ 图形和位置为
                7
                  6
                    5
                      4
                    3
                  2
                1
        ]]
        offsetX = (size.width/2)
        indexOffsetX = (size.width/3)
    else
        --[[ 图形和位置为
                  7
                6
              5
            4
              3
                2
                  1
        ]]
        offsetX = -(size.width/2)
        indexOffsetX = -(size.width/3)
    end

    -- 按顺序生成
    if index == 1 or index == 2 or index == 3 or index == 4 then
        xpos, ypos = Params.x - offsetX + (index-1)*indexOffsetX + allOffsetX,
                     Params.y + (index-3)*(size.height/6)
    elseif index == 5 or index == 6 or index == 7 then
        xpos, ypos = Params.x + offsetX - (index-4)*indexOffsetX + allOffsetX,
                     Params.y + (index-3)*(size.height/6)
    end
    return xpos, ypos
end
------------------------------------------------------------------------------
-- 迂回阵
function M:getYuHuiPos(dir,index,Params)
    local size = Params.contentSize
    local xpos, ypos =  0,0
    local offsetX = 0 -- X的偏移
    local indexOffsetX = 0 --角度偏移
    local allOffsetX = 0 -- 所有的偏移

    if Params.isFlipX then -- 是否翻转
        --[[ 图形和位置为
                  7
                6
              5
            4
              3
                2
                  1
        ]]
        offsetX = (size.width/2)
        indexOffsetX = (size.width/3)
    else
        --[[ 图形和位置为
                7
                  6
                    5
                      4
                    3
                  2
                1
        ]]
        offsetX = -(size.width/2)
        indexOffsetX = -(size.width/3)
    end

    -- 按顺序生成
    if index == 1 or index == 2 or index == 3 or index == 4 then
        xpos, ypos = Params.x + offsetX +-(index-1)*indexOffsetX + allOffsetX,
                     Params.y + (index-3)*(size.height/6)
    elseif index == 5 or index == 6 or index == 7 then
        xpos, ypos = Params.x - offsetX + (index-4)*indexOffsetX + allOffsetX,
                     Params.y + (index-3)*(size.height/6)
    end

    return xpos, ypos
end
------------------------------------------------------------------------------
--包围阵
function M:getBaoWeiPos(dir,index,Params)

    local size = Params.contentSize
    local xpos, ypos =  0,0

    if dir == 1 then -- 在屏幕左边
        if Params.isFlipX then -- 是否翻转
            --[[ 图形和位置为
                 9 6 3
                  8 5 2
                   7 4 1
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x + (size.width/2)) + (index-1)*(size.width/3) - index*12,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x + (size.width/2)) + (index-5)*(size.width/3) - (index-3)*12,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x + (size.width/2)) + (index-9)*(size.width/3) - (index-6)*12,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        else
            --[[ 图形和位置为
                  3 6 9
                 2 5 8
                1 4 7
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x + (size.width/1.3)) + (index-4)*(size.width/3) - index*12,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x + (size.width/1.3)) + (index-6)*(size.width/3) - (index-3)*12,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x + (size.width/1.3)) + (index-8)*(size.width/3) - (index-6)*12,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        end
    elseif dir==2 then -- 在屏幕右边
        if Params.isFlipX then -- 是否翻转
            --[[ 图形和位置为
                  9 6 3
                 8 5 2
                7 4 1
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x - (size.width/1.3)) - (index-4)*(size.width/3) + index*12,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x - (size.width/1.3)) - (index-6)*(size.width/3) + (index-3)*12,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x - (size.width/1.3)) - (index-8)*(size.width/3) + (index-6)*12,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        else
            --[[ 图形和位置为
                3 6 9
                 2 5 8
                  1 4 7
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x - (size.width/2)) - (index-1)*(size.width/3) + index*12,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x - (size.width/2)) - (index-5)*(size.width/3) + (index-3)*12,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x - (size.width/2)) - (index-9)*(size.width/3) + (index-6)*12,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        end
    else -- 在中间
        if Params.isFlipX then
            --[[ 图形和位置为
                9 6 3
                8 5 2
                7 4 1
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x + (size.width/1.5)) + (index-1)*(size.width/3) - index*18,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x + (size.width/1.5)) + (index-5)*(size.width/3) - (index-3)*18,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x + (size.width/1.5)) + (index-9)*(size.width/3) - (index-6)*18,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        else
            --[[ 图形和位置为
                3 6 9
                2 5 8
                1 4 7
            ]]
            if index == 1 or index == 2 or index == 3 then
                xpos, ypos = (Params.x - (size.width/1.5)) - (index-1)*(size.width/3) + index*18,
                             Params.y + (index-1)*(size.height/3) - (size.height/3.5)
            elseif index == 4 or index == 5 or index == 6 then
                xpos, ypos = (Params.x - (size.width/1.5)) - (index-5)*(size.width/3) + (index-3)*18,
                             Params.y + (index-4)*(size.height/3) - (size.height/3.5)
            elseif index == 7 or index == 8 or index == 9 then
                xpos, ypos = (Params.x - (size.width/1.5)) - (index-9)*(size.width/3) + (index-6)*18,
                             Params.y + (index-7)*(size.height/3) - (size.height/3.5)
            end
        end
    end

    return xpos,ypos
end
------------------------------------------------------------------------------
-- 歼灭阵
function M:getjianMiePos(dir,index,Params)
    local size = Params.contentSize
    local xpos, ypos =  0,0
    local offsetX = 0 -- X的偏移
    local indexOffsetX = 0 --角度偏移
    -- local allOffsetX = 0 -- 所有的偏移

    if Params.isFlipX then -- 是否翻转
        --[[ 图形和位置为
              8   9
            3 4 5 6 7
              1   2
        ]]
        offsetX = -(size.width/4)
        indexOffsetX = -(size.width/2)
    else
        --[[ 图形和位置为
              9   8
            7 6 5 4 3
              2   1
        ]]
        offsetX = (size.width/4)
        indexOffsetX = (size.width/2)
    end

    -- 按顺序生成
    if index == 1 or index == 2  then
        xpos, ypos = Params.x -  offsetX + (index-1)*indexOffsetX,
                     Params.y  - (size.height/3)
    elseif index == 3 or index == 4 or index == 5 or index == 6 or index == 7 then
        xpos, ypos = Params.x + (index-5)*(size.width/4),
                     Params.y
    elseif index == 8 or index == 9 then
        xpos, ypos = Params.x - offsetX + (index-8)*indexOffsetX,
                     Params.y  + (size.height/3)
    end

    return xpos,ypos
end
------------------------------------------------------------------------------
-- 强攻阵
function M:getQiangGongPos(dir,index,Params)
    local size = Params.contentSize
    local xpos, ypos =  0,0

    local offsetX = 0 -- X的偏移
    local indexOffsetX = 0 --角度偏移
    local allOffsetX = 0 -- 所有的偏移

    if Params.isFlipX then -- 是否翻转
        --[[ 图形和位置为
            9
               5
            8     2
               4
            7     1
               3
            6
        ]]
        if dir == 1 then
            offsetX = (size.width/2.5)
            indexOffsetX = 5
            allOffsetX = -5
        elseif dir == 2 then
            offsetX = (size.width/3)
            indexOffsetX = -5
            allOffsetX = 10
        else
            offsetX = (size.width/2.5)
        end
    else
       --[[ 图形和位置为
                  9
               3
            2     8
               4
            1     7
               5
                  6
        ]]
        if dir == 1 then
            offsetX = -(size.width/2.5)
            indexOffsetX = 5
            allOffsetX = -5
        elseif dir == 2 then
            offsetX = -(size.width/2.5)
            indexOffsetX = -5
            allOffsetX = 5
        else
            offsetX = -(size.width/2.5)
        end
    end

    -- 按顺序生成
    if index == 1 or index == 2 then
        xpos, ypos = Params.x + offsetX + (index-1)*indexOffsetX + allOffsetX,
                     Params.y + (index-1)*(size.height/3)
    elseif index == 3 or index == 4 or index == 5 then
        xpos, ypos = Params.x + (index-3)*indexOffsetX + allOffsetX,
                     Params.y + (index-3)*(size.height/3) - (size.height/10)
     elseif index == 6 or index == 7 or index == 8 or index == 9 then
        xpos, ypos = Params.x - offsetX + (index-6)*indexOffsetX + allOffsetX,
                     Params.y  + (index-7)*(size.height/3)
    end

    return xpos,ypos
end
------------------------------------------------------------------------------
-- 肉搏阵
function M:getRouBoPos(dir,index,Params)
    local size = Params.contentSize
    local xpos, ypos =  0,0
    local offsetX = 0 -- X的偏移
    local indexOffsetX = 0 --角度偏移
    local allOffsetX = 0 -- 所有的偏移

    if Params.isFlipX then -- 是否翻转
       --[[ 图形和位置为
                  4
               7
            9     3
               6
            8     2
               5
                  1
        ]]
        if dir == 1 then
            offsetX = (size.width/2.5)
            indexOffsetX = 5
            allOffsetX = -10
        elseif dir == 2 then
            offsetX = (size.width/2)
            indexOffsetX = -5
            allOffsetX = 10
        else
            offsetX = (size.width/2.5)
        end

    else
        --[[ 图形和位置为
            4
               7
            3     9
               6
            2     8
               5
            1
        ]]
        if dir == 1 then
            offsetX = -(size.width/2)
            indexOffsetX = 5
            allOffsetX = -10
        elseif dir == 2 then
            offsetX = -(size.width/2.5)
            indexOffsetX = -5
            allOffsetX = 10
        else
            offsetX = -(size.width/2.5)
        end
    end

    -- 按顺序生成
    if index == 1 or index == 2 or index == 3 or index == 4  then
        xpos, ypos = Params.x + offsetX + index*indexOffsetX + allOffsetX,
                     Params.y + (index-2)*(size.height/3)
    elseif index == 5 or index == 6 or index == 7  then
        xpos, ypos = Params.x + (index-4)*indexOffsetX + allOffsetX,
                     Params.y + (index-5)*(size.height/3) - (size.height/5)
    elseif index == 8 or index == 9 then
        xpos, ypos = Params.x - offsetX + (index-7)*indexOffsetX + allOffsetX,
                     Params.y + (index-8)*(size.height/3)
    end

    return xpos,ypos
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------