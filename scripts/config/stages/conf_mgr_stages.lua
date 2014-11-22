--
-- Author: Anthony
-- Date: 2014-08-13 11:09:05
--
local math = math
------------------------------------------------------------------------------
local conf_mgr_stages = {}
------------------------------------------------------------------------------
function conf_mgr_stages:getChaptersCount()
    local config = require("config.stages.chapters")
    -- return #(config)
    return table.nums(config)
end
------------------------------------------------------------------------------
function conf_mgr_stages:getChapterData( typeId, index )
    local c = require("config.stages.chapters")[typeId][index]
    if c == nil then
        return nil
    end

    local data = {
        chapter = c,
        -- chapterRes = self:getChapterRes(c.ChapterResId),
        stages  = self:getStagesByTypeId(c.StagesTypeId),
    }
    return data
end
-- ------------------------------------------------------------------------------
-- function conf_mgr_stages:getChapterRes( Id )
--     local typeId = math.floor(Id/1000)
--     local id = Id%1000
--     return require("config.stages.chapterRes")[typeId][id]
-- end
------------------------------------------------------------------------------
function conf_mgr_stages:getStagesByTypeId( typeId )
    return require("config.stages.stages")[typeId]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getStage( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.stages")[typeId][id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getStageRes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.stageRes")[typeId][id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getDeplete( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.depletes")[typeId][id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMapResByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMapRes(stage.mapResId)
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMapRes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.mapRes")[typeId][id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMonstersByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMonsters(stage.monstersTypeId)
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMonsters( typeId )
    return require("config.stages.monsters")[typeId]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMasterByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.monstersTypeId)
    for i=1,#ms do
        if ms[i].isMaster == 1 then return ms[i].HeorId end
    end
    return 0
end
------------------------------------------------------------------------------
function conf_mgr_stages:getFormationByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.monstersTypeId)
    return ms[1].Fid
end
------------------------------------------------------------------------------
function conf_mgr_stages:getDepletes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.depletes")[typeId][id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getDepleteByStageId( stageId )
    local stage = self:getStage(stageId)
    return self:getDepletes(stage.DepleteId)
end
------------------------------------------------------------------------------
return conf_mgr_stages
------------------------------------------------------------------------------