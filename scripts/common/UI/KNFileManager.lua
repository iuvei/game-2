KNFileManager = {}

function KNFileManager.readfile(filename , key , reg)
	if not io.exists(filename) then
		return ""
	end

    local data = io.open(filename , "r")
	local back_str = nil
	for line in data:lines() do
		line = string.trim(line)
		local str = string.split(line , reg)
		if str[1] == key then
			back_str = str[2]
		end
	end
	data:close()
	return back_str
end

function KNFileManager.updatafile(filename , key , reg , value)
	local connect = ""

	if not io.exists(filename) then
		connect = key .. reg .. value .. "\n"
	else
		local data_old = io.open(filename , "r")
		local has_set = false
		for line in data_old:lines() do
			line = string.trim(line)
			local str = string.split(line , reg)
			if str[1] == key then
				connect = connect .. str[1] .. reg .. value .. "\n"
				has_set = true
			else
				connect = connect .. line .. "\n"
			end
		end

		if not has_set then
			connect = connect .. key .. reg .. value .. "\n"
		end

		data_old:close()
	end

	-- 写文件
	local data = io.open(filename , "w")
    if data then
        data:write(connect)
        data:close()
    end

	return true
end

