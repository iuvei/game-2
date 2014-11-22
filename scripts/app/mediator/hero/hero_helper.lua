--
-- Author: Anthony
-- Date: 2014-11-14 15:46:48
-- Filename: hero_helper.lua
--
local configMgr = require("config.configMgr")
-- local item_operator = require("app.mediator.item_operator")
local item_helper = require("app.mediator.item_helper")


local hero_helper = {}

function hero_helper:check_require_equip( hero_id, equip_id )
	local equip_point = item_helper.get_serial_type( equip_id )
    local conf = configMgr:getConfig("heros")
    conf = conf:GetHeroDataById( hero_id )
    if conf.require_equip[equip_point] == equip_id then
        return true
    end
    return false
end

function hero_helper:getconf_require_equip( hero_id )
    local conf = configMgr:getConfig("heros")
    conf = conf:GetHeroDataById( hero_id )
    return conf.require_equip
end

return hero_helper