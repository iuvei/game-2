--
-- Author: wangshaopei
-- Date: 2014-09-02 15:49:59
--
local CommonDefine = {}
--------------------------------------------------------------
--人物属性
CommonDefine.RoleAttr_Max_Hp=1
CommonDefine.RoleAttr_Max_Rage=2
--------------------------------------------------------------
--人物修改属性
CommonDefine.RoleAttrRefix_Atk_Phy=1
CommonDefine.RoleAttrRefix_Defend_Phy=2
CommonDefine.RoleAttrRefix_MoveFlag=3
CommonDefine.RoleAttrRefix_AktFlag=4
CommonDefine.RoleAttrRefix_UnbreakableFlag=5
CommonDefine.RoleAttrRefix_Max_Rage=6
CommonDefine.RoleAttrRefix_Max_Hp=7
--------------------------------------------------------------
--物品属性类型
CommonDefine.ItemAttrType_Point_MaxHp=1
CommonDefine.ItemAttrType_Rate_MaxHp=2
CommonDefine.ItemAttrType_Point_MaxRage=3
CommonDefine.ItemAttrType_Rate_MaxRage=4
CommonDefine.ItemAttrType_Num=4
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
CommonDefine.INVALID_ID=-1                          --无效值
CommonDefine.RATE_LIMITE=10000                      --百分比例限制
--------------------------------------------------------------
return CommonDefine
--------------------------------------------------------------