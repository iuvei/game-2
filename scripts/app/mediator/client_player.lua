--
-- Author: Anthony
-- Date: 2014-10-12 20:05:06
-- player中间层，用来处理服务端和客户端数据的转换等
----------------------------------------------------------------
G_DefaultSelectedFormation = 1 -- 全局阵形默认选中
----------------------------------------------------------------
local playerProperties 	= import(".player_properties")
local mgr_heros 		= import(".hero.mgr_heros")
local mgr_formations	= import(".formation.mgr_formations")
----------------------------------------------------------------
local CLIENT_PLAYER = class("playerclient")
----------------------------------------------------------------
function CLIENT_PLAYER:ctor()
	self:reset()
end
----------------------------------------
function CLIENT_PLAYER:reset()
	self:reset_basedata()
	self:reset_heros()
	self:reset_formations()
end
----------------------------------------
-- 发送消息到服务端
function CLIENT_PLAYER:send( cmdname,... )
	NETWORK:encode_send(cmdname,...)
end
----------------------------------------------------------------
-- basedata
----------------------------------------
function CLIENT_PLAYER:reset_basedata()
	self.m_properties = nil
end
----------------------------------------
function CLIENT_PLAYER:init_basedata(basedata)
	self.m_properties = playerProperties.new(basedata)
	-- dump(self.m_properties)
end
----------------------------------------
function CLIENT_PLAYER:get_basedata()
	return self.m_properties:get_info()
end
----------------------------------------
-- 玩家编号
function CLIENT_PLAYER:get_playerid()
	return self.m_properties:get_playerid()
end
----------------------------------------------------------------
-- heros
----------------------------------------
function CLIENT_PLAYER:reset_heros()
	self.m_mgr_heros = nil
	self:init_mgr_heros()
end
----------------------------------------
-- manager
function CLIENT_PLAYER:init_mgr_heros()
	self.m_mgr_heros = mgr_heros.new(self)
end
function CLIENT_PLAYER:get_mgr_heros()
	return self.m_mgr_heros
end
----------------------------------------
function CLIENT_PLAYER:set_heros(data)
	self:get_mgr_heros():set_heros(data)
end
function CLIENT_PLAYER:get_heros()
	return self:get_mgr_heros():get_heros()
end
----------------------------------------
function CLIENT_PLAYER:get_heros_count()
	return self:get_mgr_heros():get_heros_count()
end
----------------------------------------
function CLIENT_PLAYER:update_hero(data)
	self:get_mgr_heros():update(data)
end
----------------------------------------------------------------
-- 阵形
----------------------------------------
function CLIENT_PLAYER:reset_formations()
	self.m_mgr_formations = nil
	self:init_mgr_formations()
end
----------------------------------------
-- manager
function CLIENT_PLAYER:init_mgr_formations()
	self.m_mgr_formations = mgr_formations.new(self)
end
function CLIENT_PLAYER:get_mgr_formations()
	return self.m_mgr_formations
end
----------------------------------------
function CLIENT_PLAYER:set_formations(data)
	self:get_mgr_formations():set(data)
end
----------------------------------------
function CLIENT_PLAYER:get_formations()
	return self:get_mgr_formations():get()
end
----------------------------------------
-- pos增加新的数据，如果存在会先删除
function CLIENT_PLAYER:set_formation(index, data)
	self:get_mgr_formations():addData( index, data )
end
----------------------------------------
function CLIENT_PLAYER:remove_formation(index)
	self:get_mgr_formations():remove( index )
end
----------------------------------------
function CLIENT_PLAYER:update_formation(GUID,index)
	self:get_mgr_formations():updatePosByGUID(GUID,index)
end
----------------------------------------------------------------
return CLIENT_PLAYER
----------------------------------------------------------------