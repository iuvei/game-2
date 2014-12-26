--
-- Author: wangshaopei
-- Date: 2014-09-28 11:51:13
--
local UIListView = class("UIListViewCtrl")
function UIListView:ctor(ScrollView,col,row)
    self.scrollView_=ScrollView
    self.amountCol_=col or 0
    self.amountRow_ = row or 0
    self.items_={}
    self.lstCtrlItem = nil
    local item=self:getItemByIndex(1)
    if item then
        self.sizeItem_=item:getContentSize()
    else
        self.sizeItem_=CCSize(0,0)
    end
    self.scrollAreaSize_=ScrollView:getInnerContainerSize()
end
-- 取得滚动层
function UIListView:getScrollView()
    return self.scrollView_
end
function UIListView:insert(item)
    self:getScrollView():addChild(item)

    -- if not self.items_[col+1] then
    --     self.items_[col+1]={}
    -- end
    -- self.items_[col+1][row+1]=item
    self.sizeItem_=item:getContentSize()
    self:updataScrollArea()
end
function UIListView:setScrollAreaSize(size)
    local size_ = size
    if self:getScrollView():getContentSize().width > size.width or self:getScrollView():getContentSize().height > size.height then
        size_=self:getScrollView():getContentSize()
    end
    self:getScrollView():setInnerContainerSize(size_)
end
function UIListView:getCount()
    return self:getScrollView():getChildrenCount()
end
function UIListView:getItemByIndex(index)
    if self:getScrollView():getChildrenCount() > 0 then
        return self:getScrollView():getChildren()[index]
    end
    return nil
end
function UIListView:updataScrollArea(callback_)
    local amount = self:getScrollView():getChildrenCount()
    if amount<=0 then
        return
    end
    local count = 0
    local arrTemp = {}
    -- 默认顺序
    local arr=self:getScrollView():getChildren()
    for i=1,amount do
        local layout=arr[i]
        table.insert(arrTemp,layout)
        if layout:isEnabled() then
            count = count +1
        end
    end

    if callback_ then
        callback_(arrTemp)
    end
    -- set position
    local sizeItem = self.sizeItem_
    self.amountCol_= math.floor(self:getScrollView():getContentSize().width/sizeItem.width)

    -- 除法
    local row_div = math.floor(amount/self.amountCol_)
    -- 取模
    local row_mod = amount%self.amountCol_
    self.amountRow_ = row_div
    if row_mod > 0 then
        self.amountRow_ = self.amountRow_ + 1
    end
    -- 实际的显示区域
    row_div = math.floor(count/self.amountCol_)
    row_mod = count%self.amountCol_
    local amountRow__ = row_div
    if row_mod > 0 then
        amountRow__ = amountRow__ + 1
    end
    self.scrollAreaSize_=CCSize(sizeItem.width*(self.amountCol_),sizeItem.height*(amountRow__))
    self:setScrollAreaSize(self.scrollAreaSize_)
    self.scrollAreaSize_=self:getScrollView():getInnerContainerSize()

    for i=0,#arrTemp-1 do
        local layout = arrTemp[i+1]
        local col= i%self.amountCol_
        local row = math.floor(i/self.amountCol_)
        layout:setPosition(cc.p( col*sizeItem.width,self.scrollAreaSize_.height-((row+1)*sizeItem.height)))
    end
    -- local layout=tolua.cast(self.sv_:getChildren():objectAtIndex(0), "Layout")
    -- self:setScrollAreaSize(CCRect(col*layout:getContentSize().width,layout:getContentSize().height*row))
end
----------------------------------------------------------------------------------------------------------
-- item 相关
function UIListView:InitialItem()
    self.lstCtrlItem = UIHelper:seekWidgetByName(self.scrollView_, "PanelItem")
    self.lstCtrlItem:setEnabled(false)
end
function UIListView:SetItemTemp(tempItem)
    self.lstCtrlItem = tempItem
end
function UIListView:ClearItem()
    for i=1,self:getCount() do
        local item = self:getItemByIndex(i)
        item:setEnabled(false)
        item:setVisible(false)
    end
end
function UIListView:AddItem(index)
    assert(self.lstCtrlItem ~= nil,"UIListView:AddItem()")
    if index==1 then
        for i=1,self:getCount() do
            local item = self:getItemByIndex(i)
            item:setEnabled(false)
            item:setVisible(false)
        end
    end
    local item = nil
    if index <= self:getCount() then
        item = self:getItemByIndex(index)
        item:setEnabled(true)
        item:setVisible(true)
    else
        item = self:_AddItem(index)
    end
    return item
end
function UIListView:_AddItem(index)
    local item=self.lstCtrlItem
    if index>1 then
        item = self.lstCtrlItem:clone()    -- 拷贝C++数据
        self:insert(item)
    else
        item:setEnabled(true)
        item:setVisible(true)
    end
    return item
end
----------------------------------------------------------------------------------------------------------
return UIListView
----------------------------------------------------------------------------------------------------------
