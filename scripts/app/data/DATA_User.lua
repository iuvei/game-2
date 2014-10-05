--[[

用户数据

]]
DATA_User = {}
------------------------------------------------------------------------------
-- 私有变量
local _data = {}
------------------------------------------------------------------------------
-- 函数
function DATA_User:init()
	_data = {}
end
------------------------------------------------------------------------------
--
function DATA_User:set(data,isall)

	if isall ==nil then isall = false end

	if isall then
		_data = data
		--	dump(data)
		return _data
	end

	_data.name 			= data.name or ""		-- 角色名字
	_data.exp 			= data.exp				-- 角色经验
	_data.level 		= data.level			-- 等级
	_data.RMB 			= data.RMB				-- RMB
	_data.money 		= data.money			-- 游戏币
	_data.createTime 	= data.createTime		-- 创建时间
	_data.lastLoginTime	= data.lastLoginTime	-- 上次登陆时间
	--	dump(data)

	-- local tab = os.date("*t",content.createTime)
	-- print(tab.year, tab.month, tab.day, tab.hour, tab.min, tab.sec);
	-- print(os.date("%x",content.createTime))
	-- tab = os.date("*t",content.lastLoginTime)
	-- print(tab.year, tab.month, tab.day, tab.hour, tab.min, tab.sec);
	-- print(os.date("%x",content.lastLoginTime))

	return _data
end
------------------------------------------------------------------------------
-- 设置单个key的值
function DATA_User:setkey(key , data)
	_data[key] = data
end
------------------------------------------------------------------------------
--得到某个key的值，key为nil时，得到所有数据
function DATA_User:get(key)
	if key == nil then return _data end
	return _data[key]
end
------------------------------------------------------------------------------
return DATA_User
------------------------------------------------------------------------------