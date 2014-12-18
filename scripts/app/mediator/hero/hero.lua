--
-- Author: Anthony
-- Date: 2014-10-13 14:48:10
-- hero数据
local ipairs = ipairs
local pairs = pairs
----------------------------------------------------------------
local game_attr = require("app.ac.game_attr")
local MapConstants  = require("app.ac.MapConstants")
local configMgr = require("config.configMgr")
local item_operator = require("app.mediator.item.item_operator")
----------------------------------------------------------------
local hero = class("hero")
----------------------------------------------------------------
function hero:ctor(data)
    self.__data = nil
	self:set_data(data)
    self._item_effects={}
end
----------------------------------------
function hero:get_data()
    return self.__data
end
----------------------------------------
function hero:set_data( data )
    self.__data = self:gen_new(data)
    -- dump(self.__data)
end
----------------------------------------
function hero:get( key )
    if key == nil then
        return self.__data
    end
    return self.__data[key]
end
----------------------------------------
function hero:setkey( key, data )
    self.__data[key] = data
    -- dump(self.__data)
end
----------------------------------------
-- 转为新数据，来自己服务端
-- 因为pb会附带其他没用信息，所有需要这步
function hero:gen_new(olddata)
    -- 转出skill
    local skills = {}
    if olddata.skills then
        for k,v in ipairs(olddata.skills) do
            skills[k] = { templateId = v.templateId ,level = v.level}
        end
    end

    --
    local equips = {}
    if olddata.equips then
        for k,v in ipairs(olddata.equips) do
            -- equips[k] = { GUID = v.GUID}
            equips[k] =  {
                GUID    = v.GUID,
                dataId  = v.dataId,
                num     = v.num,
                elevel  = v.elevel or 0,
            }
        end
    end

    return {
        dataId  = olddata.dataId,
        GUID    = olddata.GUID,
        campId  = MapConstants.PLAYER_CAMP,
        level   = olddata.level,
        quality = olddata.quality,
        stars   = olddata.stars,
        exp     = olddata.exp,
        favor   = olddata.favor, -- 好友度
        armId   = olddata.armId,
        skills  = skills,
        --arr   = game_attr.gen_hero_attr(confHeroData),
        equips  = equips,

    }
end
----------------------------------------
--[[
        得到组合过的数据
        如果有配置文件，请放在这里处理!
]]
function hero:get_info()

    local confHeros = configMgr:getConfig("heros")
    local confHeroData = confHeros:GetHeroDataById(self:get( "dataId" ))
    --local confHeroData_ = confHeros:GetConfHerosData(self:get( "dataId" ))
    local cfheroArt = confHeros:GetHerosArt(confHeroData.artId)

    -- 国家信息
    local countryInfo = {
        id      = confHeroData.country,
        name    = confHeros:getCountryName(confHeroData.country)
    }
    -- 兵种数据
    local armId_ = self:get( "armId" ) or confHeroData.ArmId
    local arm_ =confHeros:GetArmsData(armId_)

    local skills_ = nil
    if DEBUG_BATTLE.useLocalSkill then
        skills_      = confHeroData.skills
    else
        skills_      = self:get( "skills" )
    end
    --新数据
    return {
        dataId      = self:get( "dataId" ),
        GUID        = self:get( "GUID" ),
        exp         = self:get( "exp" ) or 0,
        favor       = self:get( "favor" ) or 0,

        -- typename    = confHeroData.typename,
        nickname    = confHeroData.nickname,
        level       = self:get( "level" ),
        -- speed       = confHeroData.speed,
        hit         = confHeroData.hit,
        -- MovDis      = confHeroData.MovDis,
        campId      = self:get( "campId" ),
        quality     = self:get( "quality" ),    -- 品质
        stars       = self:get( "stars" ) or 0,      -- 星级
        artId       = confHeroData.artId,
        headIcon    = cfheroArt.headIcon,
        formationId = confHeroData.formationId,
        ArmId       = armId_,
        SkillRule   = confHeroData.SkillRule,
        skills      = skills_,
        countryInfo = countryInfo,

        arm         = arm_,
        Desc        = confHeroData.Desc,
        attr        = confHeroData.attr,
        equips      = self:get( "equips" ),
    }
end
----------------------------------------
-- 装备相关
function hero:flush_item_effect()
    local equips = self:get_info().equips
    self._item_effects={}

    local equip_info
    local value_
    for k,v in ipairs(equips) do
        equip_info = item_operator:get_equip_info( v )
        for k,v in pairs(equip_info.attr) do
            value_ = item_operator:get_equip_attr(equip_info,k)
            self:calc_effect({attr_type=k,value=value_})
        end
    end
    -- for k,v in pairs(self._item_effects) do
    --     print(k,v.value)
    -- end
end
function hero:calc_effect(item_attr)
    local item_effect_new ={is_active=true,value=0}
    local item_effect = self:get_item_effect(item_attr.attr_type)
    if item_effect==nil then
        self._item_effects[item_attr.attr_type]=item_effect_new
        item_effect = self._item_effects[item_attr.attr_type]
    end

    if item_effect.is_active then
        item_effect.value = item_effect.value + item_attr.value
    else
        item_effect.is_active = true
        item_effect.value = item_effect.value + item_attr.value
    end

end
function hero:get_item_value(attr_type)
    local item_effect  = self:get_item_effect(attr_type)
    if item_effect then
        return item_effect.value
    end
    return 0
end
-- 装备的各个影响因素
function hero:get_item_effect(attr_type)
    return self._item_effects[attr_type]
end
----------------------------------------------------------------
return hero