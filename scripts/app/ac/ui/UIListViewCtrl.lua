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
    self.sizeItem_=CCSize(0,0)
    self.scrollAreaSize_=ScrollView:getInnerContainerSize()
end
function UIListView:getScrollView()
    return self.scrollView_
end
function UIListView:insert(item)
    self:getScrollView():addChild(item)

    -- if not self.items_[col+1] then
    --     self.items_[col+1]={}
    -- end
    -- self.items_[col+1][row+1]=item
    self.sizeItem_=item:getSize()
    self:updataScrollArea()
end
function UIListView:setScrollAreaSize(size)
    if self:getScrollView():getSize().width > size.width or self:getScrollView():getSize().height > size.height then
        return
    end
    self:getScrollView():setInnerContainerSize(size)
end
function UIListView:getCount()
    return self:getScrollView():getChildrenCount()
end
function UIListView:getItemByIndex(index)
    return tolua.cast(self:getScrollView():getChildren():objectAtIndex(index), "Layout")
end
function UIListView:updataScrollArea(callback_)
    local amount = self:getScrollView():getChildrenCount()
    if amount<=0 then
        return
    end
    local sizeItem = self.sizeItem_
    self.amountCol_= math.floor(self:getScrollView():getSize().width/sizeItem.width)
    --除法
    local row_div = math.floor(amount/self.amountCol_)
    --取模
    local row_mod = amount%self.amountCol_
    self.amountRow_ = row_div
    if row_mod > 0 then
        self.amountRow_ = self.amountRow_ + 1
    end

    self.scrollAreaSize_=CCSize(sizeItem.width*(self.amountCol_),sizeItem.height*(self.amountRow_))
    self:setScrollAreaSize(self.scrollAreaSize_)
    self.scrollAreaSize_=self:getScrollView():getInnerContainerSize()
    local arrTemp = {}
    --默认顺序
        local arr=self:getScrollView():getChildren()
        for i=0,amount-1 do
            local layout=tolua.cast(arr:objectAtIndex(i), "Layout")
            table.insert(arrTemp,layout)
            -- local col= i%self.amountCol_
            -- local row = math.floor(i/self.amountCol_)
            -- layout:setPosition(ccp( col*itemSize.width,self.scrollAreaSize_.height-((row+1)*itemSize.height)))
        end
    if callback_ then
        callback_(arrTemp)
    end

    for i=0,#arrTemp-1 do
        local layout = arrTemp[i+1]
        local col= i%self.amountCol_
        local row = math.floor(i/self.amountCol_)
        layout:setPosition(ccp( col*sizeItem.width,self.scrollAreaSize_.height-((row+1)*sizeItem.height)))
    end
    -- local layout=tolua.cast(self.sv_:getChildren():objectAtIndex(0), "Layout")
    -- self:setScrollAreaSize(CCRect(col*layout:getSize().width,layout:getSize().height*row))
end
return UIListView
