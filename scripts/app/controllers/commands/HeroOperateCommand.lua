--
-- Author: Your Name
-- Date: 2014-07-21 18:00:49
-- 处理一轮人物的每个操作命令
local Command = import(".Command")
local HeroOperateCommand = class("HeroOperateCommand",Command)
function HeroOperateCommand:ctor(opObj,map,mapEvent)
    HeroOperateCommand.super.ctor(self)
    self.opObjId_=opObj:GetModel():getId()
    self.opObj_=opObj
    self.map_=map
    self.mapEvent_=mapEvent
    self.isDoDoneBefore_=false                          --是否完成前处理过
end
function HeroOperateCommand:execute()
    HeroOperateCommand.super:execute(self)
    local object=self.map_:getObject(self.opObjId_)
    if object ~= nil then
        if not object:GetModel():isDead() then
            if object:GetModel():getClassId() == "hero" then
                local cmd = HeroOperateManager:getCommand()
                --队列为空，才添加命令
                if cmd==nil  then
                    --添加攻击命令
                    if object:GetModel():AILogicAkt(self.mapEvent_) then
                        --self.mapEvent_:doStopMove(object)
                    else
                        --添加移动命令
                        if object:GetModel():AILogicMove(self.mapEvent_) then
                            --没有移动命令说明当前不可走，该人物操作设为完成
                            --  if HeroOperateManager:isEmpty() then
                            --     self:setDone(true)
                            -- end
                        end
                    end
                else
                    if cmd then
                        --每次移动结束后都检测一次攻击
                        if cmd:getOpState()==HeroOpState.End and cmd:getType()==CommandType.HeroMove then
                           if object:GetModel():AILogicAkt(self.mapEvent_) then
                               --todo
                           end
                        end
                    end
                end
                --执行列表的命令
                HeroOperateManager:updata()

                --没有玩家操作命令
                if HeroOperateManager:isEmpty() then
                    --if self:doDoneBefore(object:GetModel()) then
                        --完成此次步骤
                        self:doDone(object:GetModel())
                    --end
                end

            end
        end
    else
        --对象为空说明这个对象已被删除
        self:doDone()
    end
    self:clearExpireObj()
end
-------------------------------------------------------
function HeroOperateCommand:clearExpireObj()
    local delObjLst={}
    for k,v in pairs(self.map_:getAllObjects()) do
        -- 判断是否已经被摧毁
        if v:GetModel():isDestroyed() then
            table.insert(delObjLst,v)
        end
    end
    for i,v in ipairs(delObjLst) do
        self.map_:removeObject(v)
    end
end
--------------------------------------------------------
function HeroOperateCommand:doDone(rMe)
    if rMe then
        rMe:updataBout()
    end
    self.isDoDoneBefore_=false
    self:setDone(true)
    HeroOperateManager:destroyAllCommands()
end
--------------------------------------------------------
--功能函数
function HeroOperateCommand:doDoneBefore(rMe)
    if self.isDoDoneBefore_ == false then
        self.isDoDoneBefore_=true
        if rMe then
            rMe:updataBout()
        end
        return false
    end
    return true
end
--------------------------------------------------------
return HeroOperateCommand
--------------------------------------------------------