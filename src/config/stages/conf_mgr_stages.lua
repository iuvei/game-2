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
    return require("config.stages.stages")[math.floor(Id/100)][Id%100]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getStageRes( Id )
     -- package.loaded["config.stages.stageRes"] = nil
    return require("config.stages.stageRes")[math.floor(Id/100)][Id%100]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMapResByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMapRes(stage.mapResId)
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMapRes( Id )
    return require("config.stages.mapRes")[math.floor(Id/100)][Id%100]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMonstersByStageId( Id )
    local stage = self:getStage(Id)
    return self:getMonsters(stage.mId)
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMonsters( id )
    return require("config.stages.monsters")[id]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMasterByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.mId)
    return ms["heroId"..ms.master_pos]
end
------------------------------------------------------------------------------
function conf_mgr_stages:getMonster_walk( Id,callback )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.mId)
    for i=1,5 do
        callback(i, ms["heroId"..i], (ms.master_pos == i))
    end
end
------------------------------------------------------------------------------
function conf_mgr_stages:getFormationByStageId( Id )
    local stage = self:getStage(Id)
    local ms = self:getMonsters(stage.mId)
    return ms.Fid
end
------------------------------------------------------------------------------
function conf_mgr_stages:getDepleteByStageId( stageId )
    local stage = self:getStage(stageId)
    return stage.d_vigour
end
------------------------------------------------------------------------------
return conf_mgr_stages
------------------------------------------------------------------------------