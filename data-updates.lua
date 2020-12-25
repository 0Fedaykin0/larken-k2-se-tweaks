if krastorio.general.getSafeSettingValue("kr-pipes-and-belts-changes") then
    -- space underground-belt 
    if data.raw["underground-belt"]["se-space-underground-belt"] then
        data.raw["underground-belt"]["se-space-underground-belt"].max_distance = data.raw["underground-belt"]["express-underground-belt"].max_distance
    end
    if data.raw.recipe["se-space-underground-belt"] then
        data.raw.recipe["se-space-underground-belt"].result_count = data.raw.recipe["express-underground-belt"].result_count 
    end

    -- space underground-pipe  
    if data.raw["pipe-to-ground"]["se-space-pipe-to-ground"] then
        for index, connection in pairs(data.raw["pipe-to-ground"]["se-space-pipe-to-ground"].fluid_box.pipe_connections) do
            if connection.max_underground_distance then
            -- see prototypes\vanilla-changes\optional\pipes-and-belts-changes.lua
                data.raw["pipe-to-ground"]["se-space-pipe-to-ground"].fluid_box.pipe_connections[index].max_underground_distance = 20
            end
        end
    end
end

-- SE & K2 Fluids Changes
if data.raw.recipe["se-space-pipe-to-ground"] then
    data.raw.recipe["se-space-pipe-to-ground"].result_count = data.raw.recipe["pipe-to-ground"].result_count 
end

krastorio.technologies.addUnlockRecipe("se-electric-boiler", "se-electric-boiling-steam-415")
krastorio.technologies.addUnlockRecipe("se-electric-boiler", "se-electric-boiling-steam-975")

-- Allow large tanks
tank1 = data.raw["storage-tank"]["kr-fluid-storage-1"]
if tank1 then
    tank1.se_allow_in_space = true
end

tank2 = data.raw["storage-tank"]["kr-fluid-storage-2"]
if tank2 then
    tank2.se_allow_in_space = true
end

-- Space Exploration Pipes (Unset the fast replace group)
-- data.raw["pipe-to-ground"]["se-space-pipe-to-ground"].fast_replaceable_group = nil
-- data.raw["pipe"]["se-space-pipe"].fast_replaceable_group = nil

-- Allow steel pipes & make them the same collision mask as SE pipes
steelPipeUnderground = data.raw["pipe-to-ground"]["kr-steel-pipe-to-ground"]
if steelPipeUnderground then
    steelPipeUnderground.se_allow_in_space = true
end

steelPipe = data.raw["pipe"]["kr-steel-pipe"]
if steelPipe then
    steelPipe.se_allow_in_space = true

end

-- Moon Logic Combinator placeable in Space
moonLogicCombinator = data.raw["item"]["mlc"]
if moonLogicCombinator then
    moonLogicCombinator.se_allow_in_space = true
end

-- nixie tubes
nixtube = data.raw["lamp"]["nixie-tube"]
if nixtube then
    nixtube.se_allow_in_space = true
end

nixtubeSmall = data.raw["lamp"]["nixie-tube-small"]
if nixtubeSmall then
    nixtubeSmall.se_allow_in_space = true
end

nixtubeAlpha = data.raw["lamp"]["nixie-tube-alpha"]
if nixtubeAlpha then
    nixtubeAlpha.se_allow_in_space = true
end

-- improved combinator
improvedCombinator = data.raw["container"]["improved-combinator"]
if improvedCombinator then
    improvedCombinator.se_allow_in_space = true
end

-- make singularity lab a direct upgrade over space lab. faster speed, but same 
-- # of modules
singularityLab = data.raw["lab"]["kr-singularity-lab"]
if singularityLab then
    singularityLab.researching_speed = 15
    singularityLab.module_specification = {
        max_entity_info_module_icon_rows = 1,
        max_entity_info_module_icons_per_row = 7,
        module_info_icon_shift = { 0, 2 },
        module_slots = 6
      }
end