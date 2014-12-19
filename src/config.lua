
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "Landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"

-- 游戏用到的字体
FONT_GAME = "Font/DFYuanW7-GB2312.ttf"

FONT = "Arial"

IMAGEBUTTON = 0 --图片按钮
TEXTBUTTON = 1  --文本按钮

CC_USE_DEPRECATED_API=true

-- 调试战斗的开关
DEBUG_BATTLE = { showRect = false,  -- 显示tilemap方块
                 showPos = false,   -- 显示方块坐标
                 showShortestPath=false, -- 显示寻径最终信息
                 showOpenPath=false,-- 显示寻径open列表信息
                 showDMapInfo=false,-- 显示生成的动态地图坐标信息
                 showCommandList=false,--显示命令列表信息
                 showFSMLog = false,  -- 是否显示状态机相关log
                 showSkillInfo=false,  -- 显示技能信息
                 showUILayerInfo=false,--现实界面信息
                 useLocalSkill=false,-- 是否使用本地技能
}