--
-- Author: wangshaopei
-- Date: 2014-12-08 18:06:29
--
local UICollectCtrl = class("UICollectCtrl")
function UICollectCtrl:ctor(fold_ctrl,state)
    self._items={}
    self._items_by_class={}
    self._size={width=0,height=0}
    self._state = state or "fold"
    --
    self._fold=fold_ctrl
end
-- typename up dowm left right
function UICollectCtrl:AddItem(item,typename)
    self._items[#self._items]=item
    self._size.width,self._size.height=item:getContentSize().width,item:getContentSize().height
    if not self._items_by_class[typename] then
        self._items_by_class[typename] = {}
     end
     table.insert(self._items_by_class[typename],item)
     -- self:addChild(item)
     item:setVisible(false)
end
function UICollectCtrl:Activate()
    if self._state == "fold" then -- 折叠
        self:Unfold()
        self._state = "unfold"
    else
        self:Fold()
        self._state = "fold"
    end
    return self._state
end
-- 折叠
function UICollectCtrl:Fold()
    for k,v in pairs(self._items_by_class) do
        for i,v_ in ipairs(v) do
            -- v_:setPosition(cc.p(0,0))

            transition.execute(v_, CCMoveTo:create(0.1 / #v * i, cc.p(0, 0)), {
                    -- delay = 1.0,
                    -- easing = "backout",
                    onComplete = function()
                        -- v_:setEnabled(false)
                        v_:setVisible(false)
                    end,
                })
        end
    end
end
-- 展开
function UICollectCtrl:Unfold()
    for k,v in pairs(self._items_by_class) do
        local st = 0
        local dis = 0
        if k == "up" then
            for i,v_ in ipairs(v) do
                if i == 1 then
                   st = self._fold:getContentSize().height/2 + v_:getContentSize().height/2
                   dis=st
                else
                   dis = st + (i-1)*v_:getContentSize().height
                end
                transition.execute(v_, CCMoveTo:create(0.1 / #v * i, cc.p(0, dis)), {
                    -- delay = 1.0,
                    -- easing = "backout",
                    onComplete = function()

                    end,
                })
                -- v_:setPositionY(dis)
                v_:setVisible(true)
            end
        elseif k == "down" then

        end
    end

end
return UICollectCtrl