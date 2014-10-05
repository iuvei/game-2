--
-- Author: Anthony
-- Date: 2014-09-11 11:54:54
--
------------------------------------------------------------------------------
local uiscript = import(".loginUILayer")
------------------------------------------------------------------------------
local loginScene = class("loginScene", function()
    return display.newScene("loginScene")
end)
----------------------------------------------------------------
function loginScene:ctor()

    params = params or {}

    -- NETWORK:reset()

    -----------
    -- test数据
    local data = {  {GUID= 100, dataID = 1001,camp=0},
                    {GUID= 101, dataID = 2001,camp=0},
                    {GUID= 102, dataID = 3001,camp=0},
                    {GUID= 103, dataID = 4001,camp=0},
                    {GUID= 104, dataID = 5001,camp=0},
                    {GUID= 105, dataID = 6001,camp=0},
                }
    DATA_Hero:insert(data)

    -- 上阵数据
    local Formationdata = { {index= 2, data = data[1]},
                            {index= 4, data = data[2]},
                            {index= 5, data = data[3]},
                            {index= 6, data = data[4]},
                            {index= 8, data = data[5]},
                        }
    DATA_Formation:insert(Formationdata)
    -----------


    ---------------插入layer---------------------
        -- UI管理层
    self.UIlayer = uiscript.new(self)
    ---------------------------------------------
end
----------------------------------------------------------------
function loginScene:onEnter()
    INIT_FUNCTION.AppExistsListener(self)

    -- 初始
    if self.UIlayer then self.UIlayer:init() end
end
----------------------------------------------------------------
function loginScene:onExit()

    if self.UIlayer then
        self.UIlayer:removeFromParent()
        self.UIlayer = nil
    end
end
----------------------------------------------------------------
return loginScene
----------------------------------------------------------------