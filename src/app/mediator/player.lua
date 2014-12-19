--
-- Author: Anthony
-- Date: 2014-10-12 20:05:06
-- player中间层，用来处理服务端和客户端数据的转换等
----------------------------------------------------------------
G_DefaultSelectedFormation = 1 -- 全局阵形默认选中

local servertime = 0
----------------------------------------------------------------
local playerProperties 	= import(".basedata.player_properties")

----------------------------------------------------------------
local player = class("playerclient")
----------------------------------------------------------------
function player.create(network)
	local m = player.new()
	m.network = network -- attach network
	m:init()
	if network then
		network:attach_player(m) --net attack client player
	end
	return m
end
----------------------------------------------------------------
function player:ctor()
	-- self:init()
end
----------------------------------------
function player:init()
	local mediator_mgrs = require("app.mediator.mediator_mgrs")
	self.mgrs = {}
	for k,v in pairs(mediator_mgrs) do
		self.mgrs[v.name] = require("app.mediator."..v.file).new(self)
	end
end
----------------------------------------
-- 发送消息到服务端
function player:send( cmdname,... )
	self.network:encode_send(cmdname,...)
end
----------------------------------------------------------------
--[[
	得到管理器
	用法：	local mgr_heros = player:get_mgr("heros")
 ]]
function player:get_mgr( name )
	return self.mgrs[name]
end
----------------------------------------------------------------
-- basedata
----------------------------------------
function player:init_basedata(basedata)
	self.m_properties = nil
	self.m_properties = playerProperties.new(basedata)
	-- dump(self.m_properties)
end
----------------------------------------
function player:get_basedata()
	if not self.m_properties then
		return nil
	end
	return self.m_properties:get_info()
end
----------------------------------------
-- 玩家编号
function player:get_playerid()
	return self.m_properties:get_playerid()
end
----------------------------------------
function player:set_basedata( key, value )
	self.m_properties:setkey(key,value)
	-- dump(self.m_properties)
end
----------------------------------------
-- 得到服务器的时间
-- 服务器时间，是在心跳的时候得到
function player:get_servertime()
	return servertime
end
----------------------------------------
-- 设置服务器的时间
function player:set_servertime(time)
	servertime = time
end
----------------------------------------------------------------
-- 战斗数据
function player:get_fight_info()
	return self.fight_info
end
function player:set_fight_info(stageId, begin_time)
	self.fight_info = {stageId=stageId,begin_time=begin_time,cbegin_time=os.time()}
end
----------------------------------------------------------------
return player
----------------------------------------------------------------