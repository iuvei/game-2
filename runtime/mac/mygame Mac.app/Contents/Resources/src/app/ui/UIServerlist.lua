--
-- Author: Anthony
-- Date: 2014-09-12 10:17:58
--
local UIServerlist  = class("UIServerlist", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UIServerlist.DialogID=uiLayerDef.ID_Serverlist
------------------------------------------------------------------------------
function UIServerlist:ctor(UIManager)
    UIServerlist.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function UIServerlist:onExit( )
    UIServerlist.super.onExit(self)
end
------------------------------------------------------------------------------
function UIServerlist:init( ccsFileName, params )
    UIServerlist.super.init(self,ccsFileName)

    self:createAreaList()

    self:createLastSelected(params)
end
------------------------------------------------------------------------------
function UIServerlist:createLastSelected(params)

	local Image_last = self:getWidgetByName("Image_last")
	Image_last:setTouchEnabled(true)
	local function touch( widget, eventType )
        local ccs = self.ccs

        if eventType == ccs.TouchEventType.began then
        	-- 点击时显示
        	self:getWidgetByName("lastImgPres",function ( wd )
				if wd then wd:setEnabled(true) end
			end)
    	elseif eventType == ccs.TouchEventType.moved then
    	elseif eventType == ccs.TouchEventType.ended then
			self:getWidgetByName("lastImgPres",function ( wd )
				if wd then wd:setEnabled(false) end
			end)
			-- 关闭ui
			self:getUIManager():closeServerListUI(widget.serverinfo)
			self:close()
		else
			-- 取消时，不显示
			self:getWidgetByName("lastImgPres",function ( wd )
				if wd then wd:setEnabled(false) end
			end)
		end
    end
    Image_last:addTouchEventListener(touch)

    --
	self:createUINode("ImageView",{
        name    = "lastImgPres",
        texture = "UI/serverlist/serverselect_selected_highlight_brown.png",
        pos     = cc.p(0,2),
    }):addTo(Image_last):setEnabled(false)

	local title = self:getWidgetByName("Label_12")

    local aid,sid = self:getUIManager():getlastserver()
   	if aid==nil or aid=="" or sid==nil or sid=="" then
   		aid = params.aid
   		sid = params.sid
   	end

    local serverinfo = self:getUIManager():getserverinfo(aid,sid)
	local text,color = self:getUIManager():getstateText(serverinfo.state)

	local last = self:createUINode("Label",{
		name = "last_name",
		text = serverinfo.name,
		Font = FONT_GAME,
		FontSize  = 21,
		color = color,
		pos = cc.p(title:getPositionX()+180,title:getPositionY())
	}):addTo(Image_last)

	self:createUINode("Label",{
		name = "last_state",
		text = text,
		Font = FONT_GAME,
		FontSize  = 21,
		color = color,
		pos = cc.p(last:getPositionX()+200,last:getPositionY())
	}):addTo(Image_last)

	local areainfo = self:getUIManager():getserverinfo(aid)
	Image_last.serverinfo = {
		aid		= aid,
		aname 	= areainfo.name,
		sid		= sid,
		sname 	= serverinfo.name,
	}

   	-- -- 没有上次记录则，不可点击
   	-- Image_last:setTouchEnabled(false)

end
------------------------------------------------------------------------------
function UIServerlist:createAreaList()

    local lv = self:getWidgetByName("ListView_areas")
    -----------------------------------------
    -- list 的监听函数
    local function listViewEvent( sender, eventType)

       -- print("···",eventType,sender:getCurSelectedIndex(),self.lastSelectedArea)
        if eventType == LISTVIEW_ONSELECTEDITEM_START then

        elseif eventType == LISTVIEW_ONSELECTEDITEM_END then

        end
        self:selecAreaList(sender:getCurSelectedIndex())
    end
    lv:addEventListenerListView(listViewEvent)


    self.fileList = self:getUIManager():getserverinfo()
    local areacount = #self.fileList
    -- print("areacount",areacount)

    local num_ = 0
    for i=areacount-1,0,-1 do

    	local custom_widget = self:createUINode("CheckBox",{
		    name    = "area"..num_,
		    textures = {"UI/serverlist/serverselect_serverlist_frame.png",
		                "UI/serverlist/serverselect_serverlist_frame.png",
		                "UI/serverlist/serverselect_selected_highlight_green.png",
		                "",
		                ""},
		    touchEnable = true,
		})

		custom_widget:addEventListenerCheckBox(function( sender, eventType )
			self:createServers(i+1)
		end)

		-- 显示文字
		self:createUINode("Label",{
			name = "area_name"..num_,
			text = self.fileList[i+1].aname,
			Font = FONT_GAME,
			FontSize  = 20,
			color = display.COLOR_WHITE,
			achorpoint = cc.p(0,1),
			pos = cc.p(-60,10)
		}):addTo(custom_widget)

		lv:pushBackCustomItem(custom_widget)

		num_ = num_+1
    end

    -- 默认选择第一项
	self:selecAreaList(0)
	self:createServers(areacount)
end
------------------------------------------------------------------------------
function UIServerlist:selecAreaList(index )
	-- print("(···)",self.lastSelectedArea,index)

	if self.lastSelectedArea then
		self:getWidgetByName("area"..self.lastSelectedArea,function( wd )
            if wd then wd:setSelectedState(false) end
        end)
	end

	self:getWidgetByName("area"..index,function( wd )
        if wd then wd:setSelectedState(true) end
    end)

	self.lastSelectedArea = index
end
------------------------------------------------------------------------------
function UIServerlist:createServers(areaid)
	-- print("···",areaid)

	local lv = self:getWidgetByName("ListView_servers")
	lv:removeAllItems()

	self:getWidgetByName("Label_13",function( widget )
		if widget then widget:setText(self.fileList[areaid].aname) end
	end)

	local count = #self.fileList[areaid].servers
    -- print("count",count,math.ceil(count/2))
    local servercount = math.ceil(count/2) - 1

    local serverNum = 0
    for i=0,servercount do

  		local custom_item = self:createUINode("Panel",{
		    name = "serverPanel"..i,
		    size = CCSize(212,67),
		    achorpoint = cc.p(0,1),
		})

  		-- 一排2个
  		for j=0,1 do
  			if serverNum > count then
  				return
  			end

			serverNum = serverNum+1
			local areainfo = self.fileList[areaid]
			local serverinfo = areainfo.servers[serverNum]
	    	if serverinfo then

		    	-- print(serverinfo.name,serverNum)
		   		local custom_widget = self:createUINode("CheckBox",{
				    name     	= "server"..serverNum-1,
				    textures 	= {	"UI/serverlist/serverselect_serverlist_frame.png",
				                	"UI/serverlist/serverselect_serverlist_frame.png",
				                	"UI/serverlist/serverselect_selected_highlight_green.png",
				                	"UI/serverlist/serverselect_serverlist_frame.png",
				                	"" },
				    pos 		= cc.p(252*j + 140,35),
				}):addTo(custom_item)

				custom_widget.serverinfo = {
					aid		= areainfo.aid,
					aname 	= areainfo.name,
					sid		= serverinfo.sid,
					sname 	= serverinfo.name,
					index 	= serverNum
				}

				custom_widget:addEventListenerCheckBox(function( sender, eventType )
					-- print(sender.serverinfo.aid, sender.serverinfo.sid)
					self:selecserver(sender.serverinfo.index-1)
					self:getUIManager():closeServerListUI(sender.serverinfo)
					self:close()
				end)

				if serverinfo.state == 3 then
					custom_widget:setBright(false)
					custom_widget:setTouchEnabled(false)
				end
				-- 服务器名字
				local text,color = self:getUIManager():getstateText(serverinfo.state)
				self:createUINode("Label",{
					name = "server_name"..serverNum-1,
					text = serverinfo.name.." "..text,
					Font = FONT_GAME,
					FontSize  = 20,
					color = color,
				}):addTo(custom_widget)
	    	end
  		end

		lv:pushBackCustomItem(custom_item)
    end
    -- self:selecserver(0)
    self.lastSelectedserver = nil
end
------------------------------------------------------------------------------
function UIServerlist:selecserver(index)
	-- print("(···)",self.lastSelectedserver,index)

	if self.lastSelectedserver then
		self:getWidgetByName("server"..self.lastSelectedserver,function( wd )
            if wd then wd:setSelectedState(false) end
        end)
	end

	self:getWidgetByName("server"..index,function( wd )
        if wd then wd:setSelectedState(true) end
    end)

	self.lastSelectedserver = index
end
------------------------------------------------------------------------------
return UIServerlist
------------------------------------------------------------------------------