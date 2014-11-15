--
-- Author: wangshaopei
-- Date: 2014-09-02 15:49:59
--
local CommonDefine = {}
--------------------------------------------------------------
--人物属性
-- CommonDefine.RoleAttr_Max_Hp=1
-- CommonDefine.RoleAttr_Max_Rage=2
-- 一级属性
CommonDefine.RoleAttr_Con         =  "Con"    -- 体质
CommonDefine.RoleAttr_ConInc      =  "ConInc" -- 成长值
CommonDefine.RoleAttr_Captain     =  "Captain"    -- 统帅
CommonDefine.RoleAttr_CaptainInc  =  "CaptainInc"
CommonDefine.RoleAttr_Str         =  "Str"    -- 武力
CommonDefine.RoleAttr_StrInc      =  "StrInc"
CommonDefine.RoleAttr_Int         =  "Int"    -- 智力
CommonDefine.RoleAttr_IntInc      =  "IntInc"
CommonDefine.RoleAttr_Cha         =  "Cha"    -- 魅力
CommonDefine.RoleAttr_ChaInc      =  "ChaInc"
CommonDefine.RoleAttr_AtkSpeed    =  "AtkSpeed"   -- 攻击速度
CommonDefine.RoleAttr_AtkSpeedInc =  "AtkSpeedInc"
-- 二级属性
CommonDefine.RoleAttr_MaxRage     =  "MaxRage"    -- 最大怒气
CommonDefine.RoleAttr_MaxHP       =  "MaxHP"  -- 最大hp
CommonDefine.RoleAttr_MaxMP       =  "MaxMP"  -- 最大mp
CommonDefine.RoleAttr_Hit         =  "Hit"    -- 命中率
CommonDefine.RoleAttr_Evd         =  "Evd"    -- 闪避率
CommonDefine.RoleAttr_Crt         =  "Crt"    -- 暴击率
CommonDefine.RoleAttr_Crtdef      =  "Crtdef" -- 抗暴击率
CommonDefine.RoleAttr_Block       =  "Block" -- 格挡率
CommonDefine.RoleAttr_PhysicsAtk  =  "PhysicsAtk" -- 物理攻击力
CommonDefine.RoleAttr_PhysicsDef  =  "PhysicsDef" -- 物理防御力
CommonDefine.RoleAttr_MagicAtk    =  "MagicAtk"   -- 魔法攻击力
CommonDefine.RoleAttr_MagicDef    =  "MagicDef"   -- 魔法防御力
CommonDefine.RoleAttr_TacticsAtk  =  "TacticsAtk" -- 战法攻击力
CommonDefine.RoleAttr_TacticsDef  =  "TacticsDef" -- 战法防御力
--------------------------------------------------------------
--人物修改属性
CommonDefine.RoleAttrRefix_MoveFlag=1
CommonDefine.RoleAttrRefix_AktFlag=2
CommonDefine.RoleAttrRefix_UnbreakableFlag=3
CommonDefine.RoleAttrRefix_MaxRage     =  4    -- 最大怒气
CommonDefine.RoleAttrRefix_MaxHP       =  5  -- 最大hp
CommonDefine.RoleAttrRefix_MaxMP       =  6  -- 最大mp
CommonDefine.RoleAttrRefix_Hit         =  7    -- 命中率
CommonDefine.RoleAttrRefix_Evd         =  8    -- 闪避率
CommonDefine.RoleAttrRefix_Crt         =  9    -- 暴击率
CommonDefine.RoleAttrRefix_Crtdef      =  10 -- 抗暴击率
CommonDefine.RoleAttrRefix_Block       =  11 -- 格挡率
CommonDefine.RoleAttrRefix_PhysicsAtk  =  12 -- 物理攻击力
CommonDefine.RoleAttrRefix_PhysicsDef  =  13 -- 物理防御力
CommonDefine.RoleAttrRefix_MagicAtk    =  14   -- 魔法攻击力
CommonDefine.RoleAttrRefix_MagicDef    =  15   -- 魔法防御力
CommonDefine.RoleAttrRefix_TacticsAtk  =  16 -- 战法攻击力
CommonDefine.RoleAttrRefix_TacticsDef  =  17 -- 战法防御力
--------------------------------------------------------------
--物品属性类型
-- 一级属性
CommonDefine.ItemAttrType_Con         =  "Con"    -- 体质
CommonDefine.ItemAttrType_ConInc      =  "ConInc" -- 成长值
CommonDefine.ItemAttrType_Captain     =  "Captain"    -- 统帅
CommonDefine.ItemAttrType_CaptainInc  =  "CaptainInc"
CommonDefine.ItemAttrType_Str         =  "Str"    -- 武力
CommonDefine.ItemAttrType_StrInc      =  "StrInc"
CommonDefine.ItemAttrType_Int         =  "Int"    -- 智力
CommonDefine.ItemAttrType_IntInc      =  "IntInc"
CommonDefine.ItemAttrType_Cha         =  "Cha"    -- 魅力
CommonDefine.ItemAttrType_ChaInc      =  "ChaInc"
CommonDefine.ItemAttrType_AtkSpeed    =  "AtkSpeed"   -- 攻击速度
CommonDefine.ItemAttrType_AtkSpeedInc =  "AtkSpeedInc"
-- 二级属性
CommonDefine.ItemAttrType_MaxRage     =  "MaxRage"    -- 最大怒气
CommonDefine.ItemAttrType_MaxHP       =  "MaxHP"  -- 最大hp
CommonDefine.ItemAttrType_MaxMP       =  "MaxMP"  -- 最大mp
CommonDefine.ItemAttrType_Hit         =  "Hit"    -- 命中率
CommonDefine.ItemAttrType_Evd         =  "Evd"    -- 闪避率
CommonDefine.ItemAttrType_Crt         =  "Crt"    -- 暴击率
CommonDefine.ItemAttrType_Crtdef      =  "Crtdef" -- 抗暴击率
CommonDefine.ItemAttrType_Block       =  "Block" -- 格挡率
CommonDefine.ItemAttrType_PhysicsAtk  =  "PhysicsAtk" -- 物理攻击力
CommonDefine.ItemAttrType_PhysicsDef  =  "PhysicsDef" -- 物理防御力
CommonDefine.ItemAttrType_MagicAtk    =  "MagicAtk"   -- 魔法攻击力
CommonDefine.ItemAttrType_MagicDef    =  "MagicDef"   -- 魔法防御力
CommonDefine.ItemAttrType_TacticsAtk  =  "TacticsAtk" -- 战法攻击力
CommonDefine.ItemAttrType_TacticsDef  =  "TacticsDef" -- 战法防御力
--------------------------------------------------------------
--英雄装备
CommonDefine.HEquip_Num=0
--------------------------------------------------------------
--初始化数据类型
CommonDefine.InitRageValType=1
CommonDefine.InitHpValType=2
--------------------------------------------------------------
--建筑类型
CommonDefine.Build_BingYing=1-- 兵营
CommonDefine.Build_CangKu=2-- 仓库
CommonDefine.Build_CeLveFu=3-- 策略府
CommonDefine.Build_DaTing=4-- 大厅
CommonDefine.Build_JiaoChang=5-- 校场
CommonDefine.Build_JiShi=6-- 集市
CommonDefine.Build_JiuGuan=7-- 酒馆
CommonDefine.Build_MinJu=8-- 民居
CommonDefine.Build_LiangCang=9-- 粮仓
CommonDefine.Build_NongTian=10-- 农田
CommonDefine.Build_ZhuBiChang=11-- 铸币厂
CommonDefine.Build_TieJiangBu=12-- 铁匠部
CommonDefine.Build_ZuoFang=13-- 作坊
--------------------------------------------------------------
--资源ID
CommonDefine.HomeRes_BG=14
--------------------------------------------------------------
--阵型ID
CommonDefine.Fmt_YuLin=1
--------------------------------------------------------------
-- 装备位置
CommonDefine.E_Weapon=0
CommonDefine.E_Cloth=1
CommonDefine.E_Book=2
CommonDefine.E_Horse=3
CommonDefine.E_Cloak=4
CommonDefine.E_Shield=5
--------------------------------------------------------------
--
CommonDefine.INVALID_ID=-1                          --无效值
CommonDefine.RATE_LIMITE=10000                      --百分比例限制
--------------------------------------------------------------
return CommonDefine
--------------------------------------------------------------