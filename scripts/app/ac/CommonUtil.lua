--
-- Author: wangshaopei
-- Date: 2014-10-29 22:02:55
--
local StringData = require("config.zhString")
local CommonUtil = {}
-- item attribute index map
function CommonUtil:GetItemAttrIndexMap()
    local attr_map = {
        -- 一级属性
        "Con"    ,      -- 体质
        "Captain" ,      -- 统帅
        "Str"  ,     -- 力量
        "Int"    ,     -- 智力
        "Cha"   ,        -- 魅力
        "AtkSpeed",    -- 攻击速度
        -- 二级属性
        "Hit"    ,      -- 命中率
        "Evd"   ,       -- 闪避率
        "Crt"    ,       -- 暴击率
        "Crtdef"  ,    -- 抗暴击率
        "Block"  ,      -- 格挡率
        "MaxRage"    ,    -- 最大怒气
        "MaxHP"     ,  -- 最大hp
        "MaxMP"     ,  -- 最大mp
        "PhysicsAtk" , -- 物理攻击力
        "PhysicsDef"  , -- 物理防御力
        "MagicAtk"    ,   -- 魔法攻击力
        "MagicDef"   ,   -- 魔法防御力
        "TacticsAtk" , -- 战法攻击力
        "TacticsDef"  , -- 战法防御力
    }
    return attr_map
end
return CommonUtil