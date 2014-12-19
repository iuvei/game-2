--
-- Author: wangshaopei
-- Date: 2014-09-02
local CommonDefine = {
    --------------------------------------------------------------
    --人物属性
    -- 一级属性
    RoleAttr_Con         =  "Con" ,   -- 体质
    RoleAttr_ConInc      =  "ConInc", -- 成长值
    RoleAttr_Captain     =  "Captain",    -- 统帅
    RoleAttr_CaptainInc  =  "CaptainInc",
    RoleAttr_Str         =  "Str"   , -- 武力
    RoleAttr_StrInc      =  "StrInc",
    RoleAttr_Int         =  "Int"   , -- 智力
    RoleAttr_IntInc      =  "IntInc",
    RoleAttr_Cha         =  "Cha"   , -- 魅力
    RoleAttr_ChaInc      =  "ChaInc",
    RoleAttr_Speed    =  "Speed",   -- 攻击速度
    RoleAttr_SpeedInc =  "SpeedInc",
    -- 二级属性
    RoleAttr_MaxRage     =  "MaxRage",    -- 最大怒气
    RoleAttr_MaxHP       =  "MaxHP" , -- 最大hp
    RoleAttr_MaxMP       =  "MaxMP", -- 最大mp
    RoleAttr_Hit         =  "Hit"   , -- 命中率
    RoleAttr_Evd         =  "Evd"  ,  -- 闪避率
    RoleAttr_Crt         =  "Crt"   , -- 暴击率
    RoleAttr_Crtdef      =  "Crtdef" ,-- 抗暴击率
    RoleAttr_Block       =  "Block" ,-- 格挡率
    RoleAttr_PhysicsAtk  =  "PhysicsAtk" ,-- 物理攻击力
    RoleAttr_PhysicsDef  =  "PhysicsDef", -- 物理防御力
    RoleAttr_MagicAtk    =  "MagicAtk"  , -- 魔法攻击力
    RoleAttr_MagicDef    =  "MagicDef"  , -- 魔法防御力
    RoleAttr_TacticsAtk  =  "TacticsAtk", -- 战法攻击力
    RoleAttr_TacticsDef  =  "TacticsDef" ,-- 战法防御力
    RoleAttr_DecDef      =  "DecDef" ,-- 破防伤害
    RoleAttr_DecDefRed   =  "DecDefRed" ,--
    --------------------------------------------------------------
    --人物修改属性
    RoleAttrRefix_MoveFlag       =1,
    RoleAttrRefix_AktFlag        =2,
    RoleAttrRefix_UnbreakableFlag=3,
    RoleAttrRefix_MaxRage     =  4  ,  -- 最大怒气
    RoleAttrRefix_MaxHP       =  5  ,-- 最大hp
    RoleAttrRefix_MaxMP       =  6  ,-- 最大mp
    RoleAttrRefix_Hit         =  7 ,   -- 命中率
    RoleAttrRefix_Evd         =  8 ,   -- 闪避率
    RoleAttrRefix_Crt         =  9 ,   -- 暴击率
    RoleAttrRefix_Crtdef      =  10 ,-- 抗暴击率
    RoleAttrRefix_PhysicsAtk  =  12 ,-- 物理攻击力
    RoleAttrRefix_PhysicsDef  =  13, -- 物理防御力
    RoleAttrRefix_MagicAtk    =  14,   -- 魔法攻击力
    RoleAttrRefix_MagicDef    =  15,  -- 魔法防御力
    RoleAttrRefix_TacticsAtk  =  16 ,-- 战法攻击力
    RoleAttrRefix_TacticsDef  =  17 ,-- 战法防御力
    RoleAttrRefix_DecDef      =  18 ,-- 破防伤害
    RoleAttrRefix_DecDefRed   =  19 ,--
    RoleAttrRefix_ChaosFlag   =  20 ,-- 混乱
    RoleAttrRefix_CanRegainRageFlag = 21, -- 是否可恢复怒气
    RoleAttrRefix_CanRegainHpFlag = 22,
    --------------------------------------------------------------
    --物品属性类型
    -- 一级属性
    ItemAttrType_Con         =  "Con"  ,  -- 体质
    ItemAttrType_ConInc      =  "ConInc", -- 成长值
    ItemAttrType_Captain     =  "Captain" ,   -- 统帅
    ItemAttrType_CaptainInc  =  "CaptainInc",
    ItemAttrType_Str         =  "Str"  ,  -- 武力
    ItemAttrType_StrInc      =  "StrInc",
    ItemAttrType_Int         =  "Int"  ,  -- 智力
    ItemAttrType_IntInc      =  "IntInc",
    ItemAttrType_Cha         =  "Cha"  ,  -- 魅力
    ItemAttrType_ChaInc      =  "ChaInc",
    ItemAttrType_Speed    =  "Speed",   -- 攻击速度
    ItemAttrType_SpeedInc =  "SpeedInc",
    -- 二级属性
    ItemAttrType_MaxRage     =  "MaxRage",    -- 最大怒气
    ItemAttrType_MaxHP       =  "MaxHP" , -- 最大hp
    ItemAttrType_MaxMP       =  "MaxMP" , -- 最大mp
    ItemAttrType_Hit         =  "Hit"  ,  -- 命中率
    ItemAttrType_Evd         =  "Evd"  ,  -- 闪避率
    ItemAttrType_Crt         =  "Crt"  ,  -- 暴击率
    ItemAttrType_Crtdef      =  "Crtdef", -- 抗暴击率
    ItemAttrType_Block       =  "Block", -- 格挡率
    ItemAttrType_PhysicsAtk  =  "PhysicsAtk", -- 物理攻击力
    ItemAttrType_PhysicsDef  =  "PhysicsDef", -- 物理防御力
    ItemAttrType_MagicAtk    =  "MagicAtk" ,  -- 魔法攻击力
    ItemAttrType_MagicDef    =  "MagicDef" ,  -- 魔法防御力
    ItemAttrType_TacticsAtk  =  "TacticsAtk", -- 战法攻击力
    ItemAttrType_TacticsDef  =  "TacticsDef" ,-- 战法防御力
    --------------------------------------------------------------
    --英雄装备
    HEquip_Num=0,
    --------------------------------------------------------------
    --初始化数据类型
    InitRageValType=1,
    InitHpValType=2,
    --------------------------------------------------------------
    --建筑类型
    Build_BingYing=1,-- 兵营
    Build_CangKu=2,-- 仓库
    Build_CeLveFu=3,-- 策略府
    Build_DaTing=4,-- 大厅
    Build_JiaoChang=5,-- 校场
    Build_JiShi=6,-- 集市
    Build_JiuGuan=7,-- 酒馆
    Build_MinJu=8,-- 民居
    Build_LiangCang=9,-- 粮仓
    Build_NongTian=10,-- 农田
    Build_ZhuBiChang=11,-- 铸币厂
    Build_TieJiangBu=12,-- 铁匠部
    Build_ZuoFang=13,-- 作坊
    --------------------------------------------------------------
    --资源ID
    HomeRes_BG=14,
    --------------------------------------------------------------
    --阵型ID
    Fmt_YuLin=1,
    --------------------------------------------------------------
    -- 装备位置
    E_Weapon=0,
    E_Cloth=1,
    E_Book=2,
    E_Horse=3,
    E_Cloak=4,
    E_Shield=5,
    --------------------------------------------------------------
    --
    INVALID_ID=-1 ,                         --无效值
    RATE_LIMITE=10000 ,                     --百分比例限制
    RATE_LIMITE_100=100,
}

--------------------------------------------------------------
return CommonDefine
--------------------------------------------------------------