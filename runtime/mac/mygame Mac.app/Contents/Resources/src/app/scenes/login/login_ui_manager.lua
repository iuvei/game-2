--
-- Author: Anthony
-- Date: 2014-09-11 11:54:54
--
------------------------------------------------------------------------------
-- 图片资源
------------------------------------------------------------------------------
local IMG_PATH              = "scene/login/" --路径
--
local IMG_BG                = IMG_PATH.."bg.jpg"
--
local IMG_SELECT_BTN        = "select_btn.png"
local IMG_SELECT_BTN_PRE    = "select_btn_pre.png"
local IMG_FONT_FAST_GAME    = IMG_PATH.."fast_game.png"
local IMG_FONT_LOGIN        = IMG_PATH.."login.png"
------------------------------------------------------------------------------
local lastServerAccount_filepath = G_FLIE_PATH.."LastServerAccount.txt"
--
local serverListFile =  G_FLIE_PATH..SERVER_FILENAME
local serverlisturl = WEBSERVER_URL..SERVER_FILENAME
------------------------------------------------------------------------------
local KNBtn 	= require("common.UI.KNBtn")
local KNLoading = require("common.UI.KNLoading")
local timer 	= require("common.utils.Timer")
------------------------------------------------------------------------------
-- ui 脚本文件
local UILogin 		= require("app.ui.UILogin")
local UIServerlist 	= require("app.ui.UIServerlist")
------------------------------------------------------------------------------
local login_ui_manager  = class("login_ui_manager",require("app.ac.ui.UIManager"))
------------------------------------------------------------------------------
function login_ui_manager:ctor(parent)
    login_ui_manager.super.ctor(self,parent)
    self._timers = {}
end
------------------------------------------------------------------------------
-- 退出
function login_ui_manager:onExit()
    login_ui_manager.super.onExit(self)
    -- 必需删除所有的timer
    local function killAllTimer()
	    for timerId, flag in pairs(self._timers) do
	        timer:kill(timerId)
	    end
	end
	killAllTimer()
end
------------------------------------------------------------------------------
--
function login_ui_manager:init()
    login_ui_manager.super.init(self)
    -- 背景
    local bg = display.newSprite(IMG_BG,display.cx,display.cy)
    self:addChild( bg )
    -- 屏幕自适应
    local mapcontent = bg:getContentSize()
    bg:setScaleX(INIT_FUNCTION.width/mapcontent.width);
    bg:setScaleY(INIT_FUNCTION.height/mapcontent.height);

    -- 版本
    local version_label = cc.ui.UILabel.newTTFLabel_({
        text = "version: "..VERSION,
        font = FONT,--FONT_GAME,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT
    })
    setAnchPos(version_label ,display.right-20, 30,1,1)
    -- version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
    self:addChild( version_label )

	if CHANNEL_ID ~= "test" then
		--如果曾经登陆过，则直接跳过直接去验证，不显示界面
		local acc,pwd = self:getlastacc()
		if acc and acc~="" and pwd and pwd~="" then
			token.user = acc
			token.pass = pwd
			-- 需去平台验证

			-- 显示ui
			self:getServerList()
			return
		end
	end

	self:createLoginBtn()
end
----------------------------------------------------------------
-- 不联网直接进
function login_ui_manager:test_login()
	switchscene("home",{ transitionType = "crossFade", time = 0.5})
end
----------------------------------------------------------------
-- 需连接服务端
function login_ui_manager:testnet_login()

	self:openUI({uiScript=UILogin, ccsFileName="UI/serverlist/login.json"})
end
----------------------------------------------------------------
-- 登入按钮
function login_ui_manager:createLoginBtn()

    -- self.loginBtn = KNBtn:new(IMG_PATH, {IMG_SELECT_BTN , IMG_SELECT_BTN_PRE} , display.cx - 100 , 100 , {
    --     front = IMG_FONT_LOGIN,
    --     callback = function()
    --         self.loginBtn:removeFromParentAndCleanup( true )
    --         self.loginBtn = nil
    --         --
    --     	if CHANNEL_ID == "test" then self:test_login() return
    --     	else self:testnet_login() return end

    --     end
    -- }):getLayer()
    -- self:addChild(self.loginBtn)
    local btn1_img = {
        normal  = IMG_PATH..IMG_SELECT_BTN,
        pressed = IMG_PATH..IMG_SELECT_BTN_PRE,
    }
    self.selectBtn = cc.ui.UIPushButton.new(btn1_img,{scale9 = false})
    -- :setButtonSize(455,67)
    :onButtonClicked(function()
        if CHANNEL_ID == "test" then self:test_login() return
         else self:testnet_login() return end
    end)
    :pos(display.cx - 100, 100)
    :addTo(self)
end
----------------------------------------------------------------
-- 服务列表按钮
function login_ui_manager:createServerListBtn()

	local btn1_img = {
	    normal	= "UI/serverlist/serverselect_serverlist_frame.png",
	    pressed	= "UI/serverlist/serverselect_serverlist_bg.png",
	}
    self.selectBtn = cc.ui.UIPushButton.new(btn1_img,{scale9 = true})
    :setButtonSize(455,67)
    :onButtonClicked(function()
    	-- 跳到服务器选择列表
    	if self.serverlistUi == nil then

    		-- 隐藏控件
    		self:showWidget(false)

			self:openUI({uiScript=UIServerlist,
				ccsFileName = "UI/serverlist/serverlist.json",
				params = self.selectedServer.serverinfo
				})
    	end
    end)
    :pos(display.cx, 180)
    :addTo(self)

    -- 显示服名
    local aid,sid = self:getlastserver()
	local servername = ""
   	if aid and aid~="" and sid and sid~="" then
	    -- print(aid,sid)
	    local serverinfo = self:getserverinfo(aid,sid)
	    if serverinfo then servername = serverinfo.name end
	else
		-- 没有上次的就随机选个新区
		local newServer = {}
		local num = 1
		local areaninfo = self:getserverinfo(aid)
		if areaninfo == nil then
			return
		end

		for k,v in pairs(areaninfo) do
			-- print("area",k,v)
			for i,j in pairs(v.servers) do
				-- print("server",i,j)
				if j.state == 1 then
					newServer[num] = {}
					newServer[num].aid = v.aid
					newServer[num].servers = j
					num = num + 1
				end
			end
		end
		-- dump(newServer)
		-- print(#newServer)
		local count = #newServer
		if count >= 1 then
			local info = newServer[math.random(1,count)]
			if info then
				aid = info.aid
				sid = info.servers.sid
				servername = info.servers.name
			end
		end
   	end

    -- 选择的服务器名字
    self.selectedServer = cc.ui.UILabel.new({
    	font = FONT_GAME,
	    text = servername,
	    size = 25,
	    color = ccc3(214,172,56),
	})
    :pos(display.cx-190, 195)
    :addTo(self)
    self.selectedServer:setAnchorPoint(cc.p(0,1))
    self.selectedServer.serverinfo = {aid=aid, sid=sid}

    --
    self.selcetText = cc.ui.UILabel.new({
    	font = FONT_GAME,
	    text = "点击换区",
	    size = 23,
	    color = display.COLOR_WHITE,
	})
    :pos(display.cx+90, 195)
    :addTo(self)
    self.selcetText:setAnchorPoint(cc.p(0,1))

end
------------------------------------------------------------------------------
function login_ui_manager:showerror(text)

	local timeid = timer:start(function( dt, data, timerId)
		self:removeLoading() --去除loading

		if text == nil then
			text = "获取服务器列表失败"
		end
        KNMsg.getInstance():boxShow(text, {
            confirmFun = function()
            	-- NETWORK:reset()
                switchscene("login")
            end
        })
	end, 0.1,1)
	self._timers[timeid] = 1
end
------------------------------------------------------------------------------
-- 得到服务器列表
function login_ui_manager:getServerList()
	-- self:closeUI()

	self:showLoading() -- 显示loading

    local request = nil
    request = network.createHTTPRequest(function(event)
    	-- printf("# REQUEST event.name = %s", event.name)

        local request = event.request
        if event.name == "completed" then

            if request:getResponseStatusCode() ~= 200 then
                printf("# download:%s error!",serverListFile)

                self:showerror()
            else
            	printf("# download:%s ok!",serverListFile)
                io.writefile(serverListFile, request:getResponseData())

				local timeid = timer:start(function( dt, data, timerId)
					self:createServerListBtn()
					self:createEnterGameBtn()
					self:removeLoading() --去除loading
				end, 0.1,1)
				self._timers[timeid] = 1

            end
        elseif event.name == "progress" then
            return
        else
            printf("# REQUEST event.name=%s getErrorCode() = %d, getErrorMessage() = %s",
            		event.name,request:getErrorCode(), request:getErrorMessage())
            self:showerror()
        end
    end, serverlisturl, "GET")

    if request then
        request:setTimeout(waittime or 30)
        request:start()
    else
        printf("# createHTTPRequest error!")
        self:showerror("连接服务器失败。")
    end

end
------------------------------------------------------------------------------
-- 关闭服务列表ui
function login_ui_manager:closeServerListUI(serverinfo)
	if serverinfo == nil then return end

	self.selectedServer:setString(serverinfo.sname)
	self.selectedServer.serverinfo.aid = serverinfo.aid
	self.selectedServer.serverinfo.sid = serverinfo.sid

	-- self:closeUI()
	self:showWidget(true)
end
------------------------------------------------------------------------------
-- 显示或隐藏控件
function login_ui_manager:showWidget(isshow)
	if isshow == nil then
		isshow = true
	end

	if self.entergameBtn then self.entergameBtn:setVisible(isshow) end
	self.selectBtn:setVisible(isshow)
	self.selectedServer:setVisible(isshow)
	self.selcetText:setVisible(isshow)
end
------------------------------------------------------------------------------
function login_ui_manager:showLoading()
	self:removeLoading()
	self.loading = KNLoading:new()
	self:addChild( self.loading:getLayer() )
end
------------------------------------------------------------------------------
-- 去掉 loading
function login_ui_manager:removeLoading()

	if self.loading then
		self.loading:remove()
		self.loading = nil
	end
end
------------------------------------------------------------------------------
-- 进入游戏按钮
function login_ui_manager:createEnterGameBtn()

    -- cc.ui.UIPushButton.new({normal="scene/login/select_btn.png",pressed="scene/login/select_btn_pre.png"}, {scale9 = false})
    --     :onButtonClicked(function()

    --     end)
    --     :pos(display.cx, 70)
    --     :addTo(self)

    self.entergameBtn = KNBtn:new(IMG_PATH, {IMG_SELECT_BTN , IMG_SELECT_BTN_PRE} , display.cx - 100 , 70 , {
        front = IMG_FONT_FAST_GAME,
        callback = function()

           	self.entergameBtn:removeFromParentAndCleanup( true )
            self.entergameBtn = nil

        	self:showLoading()

            local aid = self.selectedServer.serverinfo.aid
            local sid = self.selectedServer.serverinfo.sid
            if aid==nil and sid==nil then
                aid,sid = self:getlastserver()
            end

        	if aid and aid~="" and sid and sid~="" then

			   	local serverinfo = self:getserverinfo(aid,sid)

				-- print(aid,sid,serverinfo.ip,serverinfo.port)

				token.server = serverinfo.sname
				-- dump(token)
			    self:connetToLoginServer(serverinfo.ip, serverinfo.port)

				self:setlastacc(token.user,token.pass)
			    self:setlastserver(aid,sid)
		   	end

        end
    }):getLayer()
    self:addChild(self.entergameBtn)
end
------------------------------------------------------------------------------
-- 得到服务器信息
function login_ui_manager:getserverinfo( aid, sid)
	if type(aid) == "string"then
		aid = tonumber(aid)
	end

    local serverList = nil
    if io.exists(serverListFile) then
        serverList = dofile(serverListFile)
    end

    if serverList == nil then
    	print("not flie",serverListFile)
    	return nil
    end

    if aid == nil then
    	return serverList
    end

    local areainfo = serverList[aid]
    if sid ==nil then
    	return areainfo
    end

    if type(sid) == "string"then
		sid = tonumber(sid)
	end

    for k,v in pairs(areainfo.servers) do
    	if v.sid == sid then
    		return v
    	end
    end

    return nil
end
------------------------------------------------------------------------------
-- 得到状态文字和字体颜色
function login_ui_manager:getstateText( stateid )
	local color = ccc3(214,172,56) -- 金黄色
	local text = ""

	if stateid == 1 then
		text = "新区"
	elseif stateid == 2 then
		text = "火爆"
		color = display.COLOR_RED
	elseif stateid == 3 then
		text = "维护"
		color = ccc3(128,128,128)
	elseif stateid == 4 then
		text = "拥挤"
	end

	return text,color
end
------------------------------------------------------------------------------
--上次登陆的服务器
function login_ui_manager:getlastserver()
    local aid = KNFileManager.readfile(lastServerAccount_filepath , "aid" , "=")
   	local sid = KNFileManager.readfile(lastServerAccount_filepath , "sid" , "=")
   	return aid,sid
end
------------------------------------------------------------------------------
--
function login_ui_manager:setlastserver(aid,sid)
    KNFileManager.updatafile(lastServerAccount_filepath , "aid" , "=" , aid)
	KNFileManager.updatafile(lastServerAccount_filepath , "sid" , "=" , sid)
end
------------------------------------------------------------------------------
--上次登陆的帐号密码
function login_ui_manager:getlastacc()
    local acc = KNFileManager.readfile(lastServerAccount_filepath , "acc" , "=")
   	local pwd = KNFileManager.readfile(lastServerAccount_filepath , "pwd" , "=")
   	return acc,pwd
end
------------------------------------------------------------------------------
--
function login_ui_manager:setlastacc(acc,pwd)
    KNFileManager.updatafile(lastServerAccount_filepath , "acc" , "=" , acc)
	KNFileManager.updatafile(lastServerAccount_filepath , "pwd" , "=" , pwd)
end
------------------------------------------------------------------------------
-- 连接登陆服
function login_ui_manager:connetToLoginServer( _host, _port )
    local CMD = {
        onError     = function(error)
        	-- 去掉 loading,这里不能用self
        	login_ui_manager:removeLoading()

            -- print(error)
            local text = error
            if error == "not_conneted" then
                text = "网络未连接！"
            else
                if error == nil then
                    text = "网络出现异常，你可能已经断网了！"
                    text = text.."error code："..error
                end
            end
            -- print(text)

            KNMsg.getInstance():boxShow(text, {
                confirmFun = function()
                    switchscene("login")
                end
            })
        end,
        onLoginSucc = function( subid )
            -- body
        end,
        onEnterSucc = function(subid)
            -- 发送进入包
            PLAYER:send("CS_Login", {
                uid = subid,
                acc = token.user,
            })
        end,
    }
    NETWORK:connect("ls",_host, _port,CMD)
end
------------------------------------------------------------------------------
return login_ui_manager
------------------------------------------------------------------------------