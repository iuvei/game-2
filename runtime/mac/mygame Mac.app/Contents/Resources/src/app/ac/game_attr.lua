--
-- Author: Anthony
-- Date: 2014-10-20 18:10:02
-- geme_attr

local geme_attr = {}

function geme_attr.gen_attr( data )
	local attr = {
		-- 一级属性
		Con 		= data.Con or 0,	-- 体质
		Captain 	= data.Captain or 0,	-- 统帅
		Str			= data.Str or 0, 	-- 力量
		Int			= data.Int or 0,	-- 智力
		Cha			= data.Cha or 0,	-- 魅力
		Speed	= data.Speed or 0,	-- 攻击速度
		-- 二级属性
		Hit			= data.Hit or 0,	-- 命中值
		Evd			= data.Evd or 0,	-- 闪避值
		Crt			= data.Crt or 0,	-- 暴击值
		Crtdef		= data.Crtdef or 0,	-- 抗暴击值
		DecDef		= data.DecDef or 0, -- 破防伤害
		DecDefRed	= data.DecDefRed or 0, -- 破防伤害减免

		MaxRage		= data.MaxRage or 0,	-- 最大怒气
		MaxHP		= data.MaxHP or 0,	-- 最大hp
		MaxMP		= data.MaxMP or 0,	-- 最大mp
		PhysicsAtk	= data.PhysicsAtk or 0,	-- 物理攻击力
		PhysicsDef	= data.PhysicsDef or 0,	-- 物理防御力
		MagicAtk	= data.MagicAtk or 0,	-- 魔法攻击力
		MagicDef	= data.MagicDef or 0,	-- 魔法防御力
		TacticsAtk	= data.TacticsAtk or 0,	-- 战法攻击力
		TacticsDef	= data.TacticsDef or 0,	-- 战法防御力
	}

	-- attr.get = function ( key )
	-- 	return attr[key]
	-- end

	-- attr.set = function ( key, value )
	-- 	attr[key] = value
	-- end

	return attr
end
-- hero attr
function geme_attr.gen_hero_attr( data )
	local attr = {
		-- 一级属性
		Con 		= data.Con or 0,	-- 体质
		ConInc 		= data.ConInc or 0, -- 成长值
		Captain 	= data.Captain or 0,	-- 统帅
		CaptainInc 	= data.CaptainInc or 0,
		Str			= data.Str or 0, 	-- 武力
		StrInc		= data.StrInc or 0,
		Int			= data.Int or 0,	-- 智力
		IntInc		= data.IntInc or 0,
		Cha			= data.Cha or 0,	-- 魅力
		ChaInc		= data.ChaInc or 0,
		Speed	= data.Speed or 0,	-- 攻击速度
		SpeedInc	= data.SpeedInc or 0,
		-- 二级属性
		Hit			= data.Hit or 0,	-- 命中值
		Evd			= data.Evd or 0,	-- 闪避值
		Crt			= data.Crt or 0,	-- 暴击值
		Crtdef		= data.Crtdef or 0,	-- 抗暴击值
		DecDef		= data.DecDef or 0, -- 破防伤害
		DecDefRed	= data.DecDefRed or 0, -- 破防伤害减免

		MaxRage		= data.MaxRage or 0,	-- 最大怒气
		MaxHP		= data.MaxHP or 0,	-- 最大hp
		MaxMP		= data.MaxMP or 0,	-- 最大mp
		PhysicsAtk	= data.PhysicsAtk or 0,	-- 物理攻击力
		PhysicsDef	= data.PhysicsDef or 0,	-- 物理防御力
		MagicAtk	= data.MagicAtk or 0,	-- 魔法攻击力
		MagicDef	= data.MagicDef or 0,	-- 魔法防御力
		TacticsAtk	= data.TacticsAtk or 0,	-- 战法攻击力
		TacticsDef	= data.TacticsDef or 0,	-- 战法防御力
	}

	return attr
end

return geme_attr