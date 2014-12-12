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
    self._isDoDoneBefore=false                          --是否完成前处理过
    self._isDoingBefore=false
end
function HeroOperateCommand:execute()

    HeroOperateCommand.super:execute(self)
    local object=self.map_:getObject(self.opObjId_)
    if object ~= nil then
        if not object:GetModel():isDead() then
            if object:GetModel():getClassId() == "hero" then
                local cmd = HeroOperateManager:getFrontCommand(HeroOperateManager.CmdSequence)
                --队列为空，才添加命令
                if HeroOperateManager:isEmpty() then
                    -- 攻击前处理
                    self:doingBefore(object:GetModel())

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
                            local move_cmds=HeroOperateManager:getCmdsByType(CommandType.HeroMove)
                            if #move_cmds<=1 then
                                self.map_:updataTrigger(object:GetModel())
                            end
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
                    if self._isDoDoneBefore == false then
                        self:doDoneBefore(object:GetModel())
                        if HeroOperateManager:isEmpty() then
                            self:doDone()
                        end
                    else
                        --完成此次步骤
                        self:doDone()
                    end
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
        if v:GetModel():getClassId() == "hero" and v:GetModel():isDestroyed() then
            table.insert(delObjLst,v)
        end
    end
    for i,v in ipairs(delObjLst) do
         self.map_:removeObject(v)
    end
end
--------------------------------------------------------
function HeroOperateCommand:doDone(rMe)
        self:setDone(true)
        HeroOperateManager:destroyAllCommands()
        self._isDoDoneBefore = false
end
--------------------------------------------------------
--功能函数
function HeroOperateCommand:doDoneBefore(rMe)
    if rMe then
        rMe:updataBout()
    end
    self._isDoDoneBefore = true
end
function HeroOperateCommand:doingBefore(rMe)
    if rMe then
        rMe:onImpactBeforeBout()
        self.map_:updataTrigger(rMe)
        rMe:updataImpacts()
    end

    self._isDoingBefore = true
end
--------------------------------------------------------
return HeroOperateCommand
--------------------------------------------------------