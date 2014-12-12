--
-- Author: Anthony
-- Date: 2014-10-12 23:39:16
-- 基础属性

----------------------------------------------------------------
local M = class("player_properties")
----------------------------------------------------------------
function M:ctor(data)
	self.__data = nil
	self:set_data( data )
end
----------------------------------------
function M:get_data()
	return self.__data
end
----------------------------------------
function M:set_data( data )
	self.__data = self:gen_new(data)
	-- dump(self.__data)
end
----------------------------------------
function M:get( key )
	if key == nil then
		return self.__data
	end
	return self.__data[key]
end
----------------------------------------
function M:setkey( key, data )
	self.__data[key] = data

	-- dump(self.__data)
end
----------------------------------------
-- 转为新数据,来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function M:gen_new(olddata)
    return {
		playerid = olddata.playerid,
		aid 	= olddata.aid,	-- area id
		sid 	= olddata.sid,	-- server id
		name	= olddata.name,
		level 	= olddata.level,
		exp 	= olddata.exp,
		RMB 	= olddata.RMB,
		money 	= olddata.money,
		-- createtime 		= olddata.createTime,
		-- last_logintime	= olddata.lastLoginTime,
		-- last_logouttime	= olddata.lastLogoutTime,

		max_vigour 		= olddata.max_vigour,
		vigour  		= olddata.vigour,
		rvt 			= olddata.rvt, --体力恢复最终时间
    }
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function M:get_info()
    local outInfo = self:get_data()
    return outInfo
end
----------------------------------------
function M:get_playerid()
	return self.__data.playerid
end
function M:set_playerid( value )
	self.__data.playerid = value
end
-- ----------------------------------------
-- -- 把时间转为可读格式: 2015-10-10 12:20:20
-- function get_timestr( time )
-- 	local tab = os.date("*t",time)
-- 	return tab.year.."-"
-- 			..tab.month.."-"
-- 			..tab.day.." "
-- 			..tab.hour..":"
-- 			..tab.min..":"
-- 			..tab.sec
-- end
-- ----------------------------------------
-- function M:get_createtime()
-- 	return get_timestr( self:get("createtime") )
-- end
-- function M:set_createtime( value )
-- 	self:setkey( "createtime", value )
-- end
-- ----------------------------------------
-- function M:get_lastlogintime()
-- 	return get_timestr( self:get("last_logintime") )
-- end
-- function M:set_lastlogintime( value )
-- 	self:setkey( "last_logintime", value )
-- end
-- ----------------------------------------
-- function M:get_lastlogouttime()
-- 	return get_timestr( self:get("last_logouttime") )
-- end
-- function M:set_lastlogouttime( value )
-- 	self:setkey( "last_logouttime", value )
-- end
----------------------------------------------------------------
return M
----------------------------------------------------------------