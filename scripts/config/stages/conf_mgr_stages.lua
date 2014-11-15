--
-- Author: Anthony
-- Date: 2014-08-13 11:09:05
--
------------------------------------------------------------------------------
local M = {}
------------------------------------------------------------------------------
function M:getChaptersCount()
    local config = require("config.stages.chapters")
    return #(config.all_type)
end
------------------------------------------------------------------------------
function M:getChapterData( typeId, index )
    local c = require("config.stages.chapters").all_type[typeId][index]
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
-- function M:getChapterRes( Id )
--     local typeId = math.floor(Id/1000)
--     local id = Id%1000
--     return require("config.stages.chapterRes").all_type[typeId][id]
-- end
------------------------------------------------------------------------------
function M:getStagesByTypeId( typeId )
    return require("config.stages.stages").all_type[typeId]
end
------------------------------------------------------------------------------
function M:getStage( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.stages").all_type[typeId][id]
end
------------------------------------------------------------------------------
function M:getStageRes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.stageRes").all_type[typeId][id]
end
------------------------------------------------------------------------------
function M:getDeplete( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.depletes").all_type[typeId][id]
end
------------------------------------------------------------------------------
function M:getMapResByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMapRes(stage.mapResId)
end
------------------------------------------------------------------------------
function M:getMapRes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.mapRes").all_type[typeId][id]
end
------------------------------------------------------------------------------
function M:getMonstersByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMonsters(stage.monstersTypeId)
end
------------------------------------------------------------------------------
function M:getMonsters( typeId )
    return require("config.stages.monsters").all_type[typeId]
end
------------------------------------------------------------------------------
function M:getMasterByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.monstersTypeId)
    for i=1,#ms do
        if ms[i].isMaster == 1 then return ms[i].HeorId end
    end
    return 0
end
------------------------------------------------------------------------------
function M:getFormationByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.monstersTypeId)
    return ms[1].Fid
end
------------------------------------------------------------------------------
function M:getDepletes( Id )
    local typeId = math.floor(Id/100)
    local id = Id%100
    return require("config.stages.depletes").all_type[typeId][id]
end
------------------------------------------------------------------------------
function M:getDepleteByStageId( stageId )
    local stage = self:getStage(stageId)
    return self:getDepletes(stage.DepleteId)
end
------------------------------------------------------------------------------
return M
------------------------------------------------------------------------------