
--[[--

 同时 执行一组动作

~~~ lua

local spawn = transition.spawn({
    CCMoveTo:create(0.5, CCPoint(display.cx, display.cy)),
    CCFadeOut:create(0.2),
    CCDelayTime:create(0.5),
    CCFadeIn:create(0.3),
})
sprite:runAction(spawn)

~~~

@param table args 动作的表格对象

@return CCSpawn 动作序列对象

]]
function transition.spawn(actions)

	if #actions < 1 then return end
	if #actions < 2 then return actions[1] end

	local action = CCArray:create()
    for i = 1, #actions do
        action:addObject(actions[i])
    end
    return  CCSpawn:create(action)
end

--混合msas生成新精灵
function mixedGraph(originSp,maskSp)
	rt = CCRenderTexture:create(rectWidth, rectHeight)
	maskSp:setAnchorPoint(cc.p(0,0))
	originSp:setAnchorPoint(cc.p(0,0))
	--[[指定了新来的颜色(source values)如何被运算。九个枚举型被接受使用：
	GL_ZERO,
	GL_ONE,
	GL_DST_COLOR,
	GL_ONE_MINUS_DST_COLOR,
	GL_SRC_ALPHA,
	GL_ONE_MINUS_SRC_ALPHA,
	GL_DST_ALPHA,
	GL_ONE_MINUS_DST_ALPHA,
	GL_SRC_ALPHA_SATURATE.

	参数 destfactor:
	指定帧缓冲区的颜色(destination values)如何被运算。八个枚举型被接受使用：
	GL_ZERO,
	GL_ONE,
	GL_SRC_COLOR,
	GL_ONE_MINUS_SRC_COLOR,
	GL_SRC_ALPHA,
	GL_ONE_MINUS_SRC_ALPHA,
	GL_DST_ALPHA,
	GL_ONE_MINUS_DST_ALPHA]]--

	blendFunc=ccBlendFunc:new()
	blendFunc.src = 1
	blendFunc.dst = 1
	maskSp:setBlendFunc(blendFunc)

	blendFunc.src = 6			-- mask图片的当前alpha值是多少，如果是0（完全透明），那么就显示mask的。如果是1（完全不透明）
	blendFunc.dst = 0				-- maskSprite不可见
	maskSp:setBlendFunc(blendFunc)


	local org_visit = originSp.visit

	function originSp.visit(self)
		glEnable(GL_SCISSOR_TEST)
		glScissor(0, 0, rectWidth, rectHeight)
		org_visit(self)
		glDisable(GL_SCISSOR_TEST);
	end
	rt:begin()
	maskSp:visit()
	originSp:visit()
	rt:endToLua()




	local retval = CCSprite:createWithTexture(rt:getSprite():getTexture())
	retval:setFlippedY(true)--是否翻转
	return retval
end

--[[ 获取所有子节点里的 CCSprite ]]
function getAllSprites( root )
	local sprites = {}

	local function _getAllSprites( _root )
		local childs_num = _root:getChildrenCount()
		if childs_num == 0 then return end

		local childs = _root:getChildren()
		for i = 1 , childs_num do
			local child = tolua.cast( childs[i] , "CCNode")

			if child:getTag() == 102 then
				sprites[#sprites + 1] = tolua.cast( child , "CCSprite")
			end

			_getAllSprites(child)
		end
	end

	_getAllSprites( root )

	return sprites
end

--设置锚点与位置,x,y默认为0，锚点默认为0
function setAnchPos(node,x,y,anX,anY)
	local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
	node:setAnchorPoint(cc.p(aX,aY))
	node:setPosition(cc.p(posX,posY))
end

--自定义table遍历的顺序，原理，将原table的索引取出，按自定义顺序存在数组中，然后按照顺序取即可
function tableIterator(t,sortRule)
	local index = {}
	for key in pairs(t) do
		index[#index + 1] = key
	end
	table.sort(index,sortRule)
	local i = 0
	return function()
		i = i + 1
		return index[i], t[index[i]]
	end
end

function getSortList(t, sortRule)
	local index = {}
	for key in pairs(t) do
		index[#index + 1] = key
	end
	table.sort(index,sortRule)
	return index
end

--时间转换
 function timeConvert( value , key )
	local hour,min,sec
	hour = math.floor(value / 3600)
	if hour >= 1 then
		min = math.floor((value - hour * 3600) / 60)
	else
		min = math.floor(value / 60)
	end
	sec = math.floor(value % 60 )

	hour = hour<10 and "0"..hour or hour
	min = min<10 and "0"..min or min
	sec = sec<10 and "0"..sec or sec

	if key == "hour" then
		return hour
	end
	if key == "min" then
		return min
	end
	if key == "sec" then
		return sec
	end

	return hour .. "：" .. min .. "：" .. sec
end

--
function newFramesWithImage(image , num)
 --    if  io.exists(image) then

	-- else
	-- 	local array = string.split(image, "/")
	-- 	local str = ""
	-- 	for i = 5 ,table.getn(array) do
	-- 		if i == table.getn(array) then
	-- 			str = str ..array[i]
	-- 		else
	-- 			str = str ..array[i].."/"
	-- 		end
	-- 	end
	-- 	image = str
	-- end

    local frames = {}

    local texture = CCTextureCache:sharedTextureCache():addImage( image )
    local size = texture:getContentSize()

    --每张图的宽度和高度
    local frameWidth = size.width / num
    local frameHeight = size.height

    for i = 1 , num do
        local rect = CCRectMake(frameWidth * ( i - 1 ) , 0 , frameWidth , frameHeight)
        local frame = CCSpriteFrame:createWithTexture(texture , rect)
        frames[#frames + 1] = frame
    end

    return frames
end

-- 获取美术字
function getImageNum( num , imagePath , params )
	if type(params) ~= "table" then params = {} end
	local decimals = params.decimals and true or false

	if not decimals then
		num = math.round( num )
	end
	num = num < 0 and 0 or num

	local image_path = imagePath
	local frames = newFramesWithImage( image_path , decimals and 11 or 10 )

	local count_str = tostring( num )
	local len = string.len( count_str )

    local sprite = display.newSprite( frames[1] )
    -- if sprite == nil then
    -- 	return
    -- end
    -- local offset = params.offset or 0
    local skewing =  params.offset or 0
    local offset = 0
    local height = sprite:getContentSize().height

	local width = sprite:getContentSize().width

    local render = CCRenderTexture:create( width * len , sprite:getContentSize().height )
	render:begin()

    for i = 1 , len do
        local label = ( string.sub( count_str , i , i ) == "." ) and 10 or ( string.sub( count_str , i , i ) )

        local sprite = display.newSprite( frames[label + 1])
        display.align(sprite, display.LEFT_BOTTOM , offset , 0)

        offset = offset + (width or sprite:getContentSize().width) + skewing

        sprite:visit()
    end

    render:endToLua()

    local final_sprite = CCSprite:createWithTexture( render:getSprite():getTexture() )
    final_sprite:setFlippedY(true)

    return final_sprite , offset , height
end
-- 图片为不规则
function getImageNum_( num , frist_name , params )
	if type(params) ~= "table" then params = {} end
	local decimals = params.decimals and true or false
	if not decimals then
		num = math.round( num )
	end
	local count_str=""
	if num < 0 then
		count_str = "-"..tostring( math.abs(num) )
	else
		count_str = "+"..tostring( math.abs(num) )
	end

	-- 创建图片
	local width=0
	local height=0
	local len = string.len( count_str )
	local frames = {}
	for i = 1 , len do
		local label = ( string.sub( count_str , i , i ) == "." ) and 10 or ( string.sub( count_str , i , i ) )
        local sprite = display.newSprite("#"..frist_name..tostring(label)..".png")
        assert(sprite ~= nil,"getImageNum_() failed !")
		frames[#frames+1]=sprite
		width = width + sprite:getContentSize().width
		height=sprite:getContentSize().height
	end
	-- local sprite = display.newSprite("#"..frist_name.."0.png")

    local skewing =  params.offset or 0
    local offset = 0
    -- 位置调整
    local render = CCRenderTexture:create( width ,height )
	render:begin()
    for i = 1 , #frames do
        local sprite =frames[i]
        display.align(sprite, display.LEFT_BOTTOM , offset , 0)
        offset = offset + sprite:getContentSize().width + skewing
        sprite:visit()
    end
    render:endToLua()

    local final_sprite = CCSprite:createWithTexture( render:getSprite():getTexture() )
    final_sprite:setFlippedY(true)

    return final_sprite , offset , height
end
-- -- 获取CID对应的类型
-- function getCidType( _cid )
--     return DATA_IDTYPE:getType( _cid )
-- end


-- --[[功能对应等级开放]]
-- function checkOpened(type)
-- 	local Config_Open = requires(IMG_PATH , "GameLuaScript/Config/Open")
-- 	local cur = DATA_Guide:get()

-- 	if not isset(Config_Open , type) then return true end

-- 	local config = Config_Open[type]
-- 	if cur["map_id"] > config[1] or (cur["map_id"] == config[1] and cur["mission_id"] >= config[2]) then
-- 		return true
-- 	else
-- 		return "需要玩家您打过关卡" .. config[1] .. "-" .. config[2] .. "才能开启"
-- 	end
-- end

-- --[[获取引导提示信息]]
-- function getGuideInfo()
-- 	local Config_Open = requires(IMG_PATH , "GameLuaScript/Config/Open")
-- 	local cur = DATA_Guide:get()
-- 	local old = DATA_Guide:getOld()

-- 	-- 关卡无变化
-- 	if cur["map_id"] == old["map_id"] and cur["mission_id"] == old["mission_id"] then
-- 		return false
-- 	end

-- 	local id = cur["map_id"] .. "-" .. cur["mission_id"]
-- 	if not isset(Config_Open , id) then return false end

-- 	return Config_Open[id]
-- end

--文字换行处理
function createLabel( params )
	params = params or {}
	local str = params.str or ""
	local total_width = params.width or 100		-- 文字总宽度
	local color = params.color or ccc3( 0x2c , 0x00 , 0x00 )
	local size = params.size or 20
	local x = params.x or 0
	local y = params.y or 0
	local line = 1														-- 行数
	-- 估算一行的字符数量
	local enter_num = string.len(str) - string.len(string.gsub(str , "\n" , ""))
	local label = CCLabelTTF:create(str , FONT , size )
	local label_size = label:getContentSize()
	local line_height = label_size.height

	if enter_num > 0 then
		line_height = CCLabelTTF:create("测" , FONT , size ):getContentSize().height
	end

	if label_size.width > total_width then			-- 大于一行
		line = math.ceil( label_size.width / total_width )
	end

	line = line + enter_num

	if line > 1 then
		label:setDimensions( CCSize:new( total_width , line * line_height ) )
	end

	label:setColor( color )
	label:setHorizontalAlignment( 0 )			-- 文字左对齐
	setAnchPos(label , x , y )

	return label, line
end
function formatMsg(str , replace)
	if not str then return "" end

	if type(replace) == "table" and table.nums(replace) > 0 then
		local nums = 0

		str = string.gsub(str , "#s#" , function()
			nums = nums + 1
			if replace[nums] ~= nil then
				local replace_type = type(replace[nums])
				if replace_type == "string" or replace_type == "number" then
					return replace[nums]
				else
					return ""
				end
			end

			return ""
		end)
	end

	local return_str = ""
	while true do
		local start_pos , end_pos , color = string.find(str , "%[color=(#[a-f0-9]+)%]")
		if start_pos == nil then break end
		local start_pos_2 , end_pos_2 = string.find(str , "%[/color%]" , end_pos)
		if start_pos_2 == nil then break end
		local first_str = string.sub(str , 0 , start_pos - 1)
		local second_str = string.sub(str , end_pos + 1 , start_pos_2 - 1)

		return_str = return_str .. first_str .. second_str
		str = string.sub(str , end_pos_2 + 1)
	end


	return return_str .. str
end
function showTableInfo(t)
	print("-----------------------------------------------------")
	table.walk(t, function(v,k)
            print(k,v)
        end)
	print("-----------------------------------------------------")
end