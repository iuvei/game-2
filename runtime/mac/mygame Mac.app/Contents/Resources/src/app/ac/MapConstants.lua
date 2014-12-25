--
-- Author: Anthony
-- Date: 2014-07-03 15:53:31
--
local MapConstants = {}
MapConstants.LAYER_ZORDER_OBJ=100
MapConstants.LAYER_ZORDER_EFF=101   --效果层


MapConstants.DEFAULT_OBJECT_ZORDER  = 100
MapConstants.MAX_OBJECT_ZORDER      = 20000
--[[
    MapConstants.MAP_Z_0 : 人物表现，objview
    MapConstants.MAP_Z_2 : 人物技能效果表示
    MapConstants.MAP_Z_3 : 战斗结束后表现
]]
-- 地图层z次序,-1层,分配区间区间 51 ~ 100
MapConstants.MAP_Z__1_MID = 51 + math.floor((100 - 51)/2)
MapConstants.MAP_Z__1_0 = MapConstants.MAP_Z__1_MID + 0 -- 0
-- 地图层z次序,0层,分配区间区间 101 ~ 150
MapConstants.MAP_Z_0_MID = 101 + math.floor((150 - 101)/2)
MapConstants.MAP_Z_0_0 = MapConstants.MAP_Z_0_MID + 0 -- 0
-- 地图层z次序,1层,分配区间区间 151 ~ 200,人物层
MapConstants.MAP_Z_1_MID = 151 + math.floor((200 - 151)/2)
MapConstants.MAP_Z_1__1 = MapConstants.MAP_Z_1_MID - 1 -- -1
MapConstants.MAP_Z_1_0 = MapConstants.MAP_Z_1_MID + 0 -- 0
MapConstants.MAP_Z_1_1 = MapConstants.MAP_Z_1_MID + 1 -- 1
-- 地图层z次序,2层,分配区间区间 201 ~ 250
MapConstants.MAP_Z_2_MID = 201 + math.floor((250-201)/2)
MapConstants.MAP_Z_2_0 = MapConstants.MAP_Z_2_MID + 0 -- 0
-- 地图层z次序,3层,分配区间区间 251 ~ 300
MapConstants.MAP_Z_3_MID = 251 + math.floor((300-251)/2)
MapConstants.MAP_Z_3_0 = MapConstants.MAP_Z_3_MID + 0 -- 0


--
MapConstants.HP_BAR_ZORDER          = 30000
MapConstants.HP_BAR_OFFSET_Y        = 30
MapConstants.RADIUS_SCALE_X         = 0.4
-- MapConstants.RADIUS_SCALE_Y         = 0

-- camp
MapConstants.PLAYER_CAMP            = 1
MapConstants.ENEMY_CAMP             = 2
MapConstants.OTHERPLAYER_CAMP       = 3

-- direction
MapConstants.DIR_L = 1
MapConstants.DIR_R = 2
MapConstants.DIR_T = 3
MapConstants.DIR_D = 4

MapConstants.SPEED_FACTOR=5
--人物攻击单位方向，目前设为4个方向
MapConstants.AKT_DIRCTIONS_L= {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} -- 左，上，下，右
MapConstants.AKT_DIRCTIONS_R= {{1, 0}, {0, -1}, {0, 1}, {-1, 0}} -- 右，上，下，左
MapConstants.SPLIT_SING="|"

return MapConstants
