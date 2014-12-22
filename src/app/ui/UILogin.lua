--
-- Author: Anthony
-- Date: 2014-09-17 11:39:40
--
local UILogin  = class("UILogin", require("app.ac.ui.UIBase"))
------------------------------------------------------------------------------
local uiLayerDef =require("app.ac.uiLayerDefine")
UILogin.DialogID=uiLayerDef.ID_Login
------------------------------------------------------------------------------
function UILogin:ctor(UIManager)
    UILogin.super.ctor(self,UIManager)
end
------------------------------------------------------------------------------
-- 退出
function UILogin:onExit( )
    UILogin.super.onExit(self)
end
------------------------------------------------------------------------------
-- 是否合法帐号
local function isRightAcc(str)
	     -- if string.len(str or "") < 6 then return false end
	     if str == "" then return false end
	     local p1,p2 = string.find(str, "[%w]+")
	     if (p1 ~= 1) or (p2 ~= string.len(str)) then return false end
	     return true
end
------------------------------------------------------------------------------
-- 是否合法密码
local function isRightPwd(str)
	     -- if string.len(str or "") < 6 then return false end
	     if str == "" then return false end
	     local p1,p2 = string.find(str, "[%w]+")
	     if (p1 ~= 1) or (p2 ~= string.len(str)) then return false end
	     return true
end
------------------------------------------------------------------------------
-- 判断是否邮箱
local function isRightEmail(str)
	     if string.len(str or "") < 6 then return false end
	     local b,e = string.find(str or "", '@')
	     local bstr = ""
	     local estr = ""
	     if b then
	         bstr = string.sub(str, 1, b-1)
	         estr = string.sub(str, e+1, -1)
	     else
	         return false
	     end

	     -- check the string before '@'
	     local p1,p2 = string.find(bstr, "[%w_]+")
	     if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

	     -- check the string after '@'
	     if string.find(estr, "^[%.]+") then return false end
	     if string.find(estr, "%.[%.]+") then return false end
	     if string.find(estr, "@") then return false end
	     if string.find(estr, "[%.]+$") then return false end

	     _,count = string.gsub(estr, "%.", "")
	     if (count < 1 ) or (count > 3) then
	         return false
	     end

	     return true
end
------------------------------------------------------------------------------
function UILogin:init( ccsFileName, params )
    UILogin.super.init(self,ccsFileName)
print("···3")
	self:getWidgetByName("Button_login",function(wd)
		print("···8",wd)
		if wd then
			wd:addTouchEventListener(function(sender, eventType)
				print("···1")
	            local ccs = self.ccs
	            if eventType == ccs.TouchEventType.ended then
	            print("···9")
	            	local acc = ""
	            	self:getWidgetByName("TextField_acc",function(textwd)
	            		acc = textwd:getStringValue()
	            	end)

	            	if not isRightAcc(acc) then
	            		KNMsg:getInstance():flashShow("帐号必须为字符的字母或数字")
	            		return
	            	end

	            	local pwd = ""
	            	self:getWidgetByName("TextField_pass",function ( textwd )
	            		pwd = textwd:getStringValue()
	            	end)

	            	if not isRightPwd(pwd) then
	            		KNMsg:getInstance():flashShow("密码必须为字符的字母或数字")
	            		return
	            	end

	            	-- if acc=="" or pwd=="" then
	            	-- 	KNMsg:getInstance():flashShow("帐号或密码不能为空")
	            	-- 	return
	            	-- end

	            	token.user 	= acc
	            	token.pass	= pwd
	            	self:close()
	            	self:getUIManager():getServerList()
	            end
	        end)
		end
	end)
end

------------------------------------------------------------------------------
return UILogin
------------------------------------------------------------------------------