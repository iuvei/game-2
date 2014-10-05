--
-- Author: wangshaopei
-- Date: 2014-09-28 11:51:13
--
local UIListView = class("UIListView")
function UIListView:ctor(ScrollView,col,row)
    self.scrollView_=ScrollView
    self.amountCol_=col or 0
    self.amountRow_ = row or 0
    self.items_={}
   -- ScrollView:setAnchorPoint(ccp(0, 1))

    self.scrollAreaSize_=ScrollView:getInnerContainerSize()
    --ScrollView:setDirection(3)
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

    self:updataScrollArea(item)
end
function UIListView:setScrollAreaSize(size)
    if self:getScrollView():getSize().width > size.width or self:getScrollView():getSize().height > size.height then
        return
    end
    self:getScrollView():setInnerContainerSize(size)
end
function UIListView:updataScrollArea(item)
    local amount = self:getScrollView():getChildrenCount()
    if amount<=0 then
        return
    end
    local itemSize = item:getSize()
    self.amountCol_= math.floor(self:getScrollView():getSize().width/itemSize.width)
    --除法
    local row_div = math.floor(amount/self.amountCol_)
    --取模
    local row_mod = amount%self.amountCol_
    self.amountRow_ = row_div
    if row_mod > 0 then
        self.amountRow_ = self.amountRow_ + 1
    end

    self.scrollAreaSize_=CCSize(item:getSize().width*(self.amountCol_),item:getSize().height*(self.amountRow_))
    self:setScrollAreaSize(self.scrollAreaSize_)
    self.scrollAreaSize_=self:getScrollView():getInnerContainerSize()
    local arr=self:getScrollView():getChildren()
    for i=0,amount-1 do
        local layout=tolua.cast(arr:objectAtIndex(i), "Layout")
        local col= i%self.amountCol_
        local row = math.floor(i/self.amountCol_)
        -- if i%self.amountCol_ > 0 then
        --     row=row+1
        -- end
        --print("···",col,row)
        layout:setPosition(ccp( col*itemSize.width,self.scrollAreaSize_.height-((row+1)*itemSize.height)))
    end
    -- local layout=tolua.cast(self.sv_:getChildren():objectAtIndex(0), "Layout")
    -- self:setScrollAreaSize(CCRect(col*layout:getSize().width,layout:getSize().height*row))
end
return UIListView
