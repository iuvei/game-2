--
-- Author: wangshaopei
-- Date: 2014-08-15 11:45:47
--
local SkillDefine= {}
SkillDefine.EffType_Origin=1            --原点
SkillDefine.EffType_FakeFly=2           --假飞
SkillDefine.EffType_Line=3              --直线
SkillDefine.EffType_Parabolic=4         --抛物线

SkillDefine.UseType_Auto=1              --主动
SkillDefine.UseType_Passivity=2         --被动
SkillDefine.UseType_Specific=3          --特殊
SkillDefine.UseType_Hero=4              --主将

SkillDefine.LogicType_Impact=1
SkillDefine.LogicType_Skill=2

--效果逻辑类ID定义
SkillDefine.LogicImpact001=1
SkillDefine.LogicImpact002=2
SkillDefine.LogicImpact003=3
SkillDefine.LogicImpact004=4
SkillDefine.LogicImpact010=10
SkillDefine.LogicImpact011=11
SkillDefine.LogicImpact014=14
SkillDefine.LogicImpact015=15
-------------------------------------------------------------
--效果逻辑参数类型
--LogicID001
SkillDefine.ImpactParamL001_Damage=1
SkillDefine.ImpactParamL001_DamageRate=2
--LogicID003
SkillDefine.ImpactParamL003_DamagePhy=1
SkillDefine.ImpactParamL003_DamagePhyRate=2
SkillDefine.ImpactParamL003_DamageZhanFa=3                     --战法伤害
SkillDefine.ImpactParamL003_DamageZhanFaRate=4
SkillDefine.ImpactParamL003_DamageJiCe=5                       --计策伤害
SkillDefine.ImpactParamL003_DamageJiCeRate=6
--LogicID004
SkillDefine.ImpactParamL004_Hp=1
SkillDefine.ImpactParamL004_HpRate=2
SkillDefine.ImpactParamL004_Rage=3
SkillDefine.ImpactParamL004_RageRate=4
--LogicID010
SkillDefine.ImpactParamL010_ImpactId=1
--LogicID011
SkillDefine.ImpactParamL011_MaxHp=1
SkillDefine.ImpactParamL011_MaxHpRate=2
SkillDefine.ImpactParamL011_MaxRage=3
SkillDefine.ImpactParamL011_MaxRageRate=4
--LogicID014
SkillDefine.ImpactParamL014_DamagePhyAtk=1
SkillDefine.ImpactParamL014_DamagePhyAtkRate=2
SkillDefine.ImpactParamL014_DamagePhyDefence=3
SkillDefine.ImpactParamL014_DamagePhyDefenceRate=4
--LogicID015
SkillDefine.ImpactParamL015_MoveFlag=1
SkillDefine.ImpactParamL015_AktFlag=2
SkillDefine.ImpactParamL015_UnbreakableFlag=3
--被动技能的LogicID none
SkillDefine.ImpactParamPassvieSkill_MaxHp=1
SkillDefine.ImpactParamPassvieSkill_MaxHpRate=2
SkillDefine.ImpactParamPassvieSkill_MaxRage=3
SkillDefine.ImpactParamPassvieSkill_MaxRageRate=4
-------------------------------------------------------------
--技能逻辑类ID定义
SkillDefine.LogicSkill_ImpToTar=1
SkillDefine.LogicSkill_PassiveSkill=2
--技能逻辑参数类型
--LogicSkill_ImpToTar
SkillDefine.SkillParamL_ImpToTar_Type=1
SkillDefine.SkillParamL_ImpToTar_TarLogic=2
SkillDefine.SkillParamL_ImpToTar_ImpID=3
SkillDefine.SkillParamL_ImpToTar_ActivateRate=4
--LogicSkill_PassiveSkill
SkillDefine.SkillParamL_PassiveSkill_ImpID=1
-------------------------------------------------------------
--appendImpact表的type类型
SkillDefine.AppendSkillImpType_ToTar=1
SkillDefine.AppendSkillImpType_ToCustomTar=2

--目标逻辑
SkillDefine.TargetLogic_Self=0
SkillDefine.TargetLogic_Enemy_Unit=1
SkillDefine.TargetLogic_AllEnemy=2
SkillDefine.TargetLogic_Team_Unit=3
SkillDefine.TargetLogic_AllTeam=4
--SkillDefine.TargetLogic_Specific_Unit=1
--SkillDefine.TargetLogic_

--技能攻击范围逻辑
SkillDefine.AtkRange_None=0
SkillDefine.AtkRange_Hor=1                                      --竖向
SkillDefine.AtkRange_Ver=2                                      --横向
SkillDefine.AtkRange_Frist=3                                    --前排
SkillDefine.AtkRange_Back=4                                     --后排
SkillDefine.AtkRange_Around=5                                   --周围

return SkillDefine
