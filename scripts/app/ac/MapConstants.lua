--
-- Author: Anthony
-- Date: 2014-07-03 15:53:31
--
local MapConstants = {}
MapConstants.LAYER_ZORDER_OBJ=100
MapConstants.LAYER_ZORDER_EFF=101   --效果层


MapConstants.DEFAULT_OBJECT_ZORDER  = 100
MapConstants.MAX_OBJECT_ZORDER      = 20000

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
