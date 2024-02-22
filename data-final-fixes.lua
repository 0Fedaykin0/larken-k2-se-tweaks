local function get_recipe_name(recipe)
    if recipe.name ~= nil then return recipe.name end
    local main_product = recipe.main_product
    if main_product == nil then
        if recipe.results and recipe.results[0] then
            return recipe.results[0].name
        elseif recipe.result and recipe.result.name then
            return recipe.result.name
        elseif recipe.result and recipe.result ~= nil then
            return recipe.result
        end
    else
        return main_product
    end
end

local function remove_ingredient(recipe, name)
    if recipe["ingredients"] then
        for i = #recipe.ingredients, 1, -1 do
            if recipe.ingredients[i] then
                for _, value in pairs(recipe.ingredients[i]) do
                    if value == name then
                        table.remove(recipe.ingredients, i)
                    end
                end
            end
        end
    end

end

local function remove_all_ingredients(recipe, name)

    if recipe["ingredients"] then remove_ingredient(recipe, name) end

    if recipe["normal"] then remove_ingredient(recipe.normal, name) end

    if recipe["expensive"] then remove_ingredient(recipe.expensive, name) end
end

local function remove_result(recipe, name)
    for i = #recipe.results, 1, -1 do
        if recipe.results[i] then
            for _, value in pairs(recipe.results[i]) do
                if value == name then
                    table.remove(recipe.results, i)
                end
            end
        end
    end
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
end

if mods["space-exploration"] and mods["Krastorio2"] then
    if settings.startup["allow-matter-buildings-in-space"].value then
        -- 	type = "assembling-machine",
        -- name = "kr-matter-assembler",
        -- type = "assembling-machine",
        -- name = "kr-matter-plant",
        -- type = "furnace",
        -- name = "kr-stabilizer-charging-station",
        data.raw["assembling-machine"]["kr-matter-assembler"].se_allow_in_space =
            true
        data.raw["assembling-machine"]["kr-matter-plant"].se_allow_in_space =
            true
        data.raw["furnace"]["kr-stabilizer-charging-station"].se_allow_in_space =
            true
    end

    if settings.startup["allow-steel-pipe-in-space"].value then
        -- Pipes
        data.raw.pipe["pipe"].fast_replaceable_group = nil
        data.raw.pipe["pipe"].next_upgrade = nil

        -- Underground pipes
        data.raw["pipe-to-ground"]["pipe-to-ground"].fast_replaceable_group =
            nil
        data.raw["pipe-to-ground"]["pipe-to-ground"].next_upgrade = nil
    end

    if settings.startup["allow-upgrade-singularity-lab"].value then
        -- make singularity lab a direct upgrade over space lab. faster speed, but same
        -- # of modules
        local singularityLab = data.raw["lab"]["kr-singularity-lab"]
        local spaceScienceLab = data.raw["lab"]["se-space-science-lab"]
        if singularityLab then
            singularityLab.researching_speed = 15
            singularityLab.module_specification = {
                max_entity_info_module_icon_rows = 1,
                max_entity_info_module_icons_per_row = 7,
                module_info_icon_shift = {0, 2},
                module_slots = 6
            }
            singularityLab.inputs = spaceScienceLab.inputs
        end
    end

    if settings.startup["allow-remove-tesseract-from-stabilizer"].value then
        remove_all_ingredients(data.raw["recipe"]["matter-stabilizer"],
                               "se-naquium-tessaract")
    end

    if settings.startup["allow-remove-stabilizer-for-vulcanite"].value then
        remove_all_ingredients(data.raw["recipe"]["matter-to-se-vulcanite"],
                               "charged-matter-stabilizer")
        remove_result(data.raw["recipe"]["matter-to-se-vulcanite"],
                      "matter-stabilizer")
    end

    if settings.startup["allow-hypercooler-on-spaceship"].value then
        local allowed_collision_mask_values = {
            "water-tile", "ground-tile", "item-layer", "object-layer",
            "player-layer"
        }
        -- remove the spaceship collision layer from the hypercooler
        data.raw["assembling-machine"]["se-space-hypercooler"].collision_mask =
            allowed_collision_mask_values
        data.raw["assembling-machine"]["se-space-hypercooler"].se_allow_in_space =
            true
        -- in addition, the particle accelerator & thermal radiator recipes get disabled when grounded. causes some issues
        -- when landing because it can delete ingredients currently active
        local defaultSpaceRadiator =
            data.raw["assembling-machine"]["se-space-radiator"]
        local groundedSpaceRadiator =
            data.raw["assembling-machine"]["se-space-radiator-grounded"]
        groundedSpaceRadiator.crafting_categories =
            defaultSpaceRadiator.crafting_categories
        local defaultSpaceRadiator2 =
            data.raw["assembling-machine"]["se-space-radiator-2"]
        local groundedSpaceRadiator2 =
            data.raw["assembling-machine"]["se-space-radiator-2-grounded"]
        groundedSpaceRadiator2.crafting_categories =
            defaultSpaceRadiator2.crafting_categories

        local defaultAccelerator =
            data.raw["assembling-machine"]["se-space-particle-accelerator"]
        local groundedAccelerator =
            data.raw["assembling-machine"]["se-space-particle-accelerator-grounded"]
        groundedAccelerator.crafting_categories =
            defaultAccelerator.crafting_categories
    end

    -- ===================================================================================================
    -- Space Exploration nerfs by having a re-conversion effectivity of 50% (matter *= 2)
    -- we revert that but still re-nerf a bit (*=1.25)
    -- ===================================================================================================
    local excluded_recipes = {"charged-antimatter-fuel-cell", "matter-cube"}
    local nerf_factor = 1.25
    if settings.startup["matter-reconversion-ratio"] then
        nerf_factor = settings.startup["matter-reconversion-ratio"].value
    end

    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category == "matter-deconversion" then
            if recipe.ingredients ~= nil and
                not has_value(excluded_recipes, get_recipe_name(recipe)) and
                recipe.main_product ~= "matter-cube" and recipe.main_product ~=
                "charged-antimatter-fuel-cell" and recipe.result ~=
                "charged-antimatter-fuel-cell" then
                for _, ingredient in pairs(recipe.ingredients) do
                    if ingredient.name == "matter" then
                        -- Undo the Space Exploration 2x cost
                        -- space-exploration-postprocess\prototypes\phase-4\krastorio2\matter.lua
                        ingredient.amount = math.floor(ingredient.amount / 2)
                        if ingredient.catalyst_amount then
                            ingredient.catalyst_amount = math.floor(
                                                             ingredient.catalyst_amount /
                                                                 2)
                        end
                        -- Apply a new debuff based on the provided ratio
                        ingredient.amount = 
                                                0.5 + ingredient.amount *
                                                    nerf_factor
                        if ingredient.catalyst_amount then
                            ingredient.catalyst_amount = math.floor(0.5 +
                                                                        ingredient.catalyst_amount *
                                                                        nerf_factor)
                        end
                    end
                end
            end
        end
    end

    local total_matter_capacity = 1000 -- default k2 ingredient count
    local matter_cube_cost = 1000 -- default 1:1 ratio for conversion and deconversion
    if settings.startup["matter-cube-cost"] then
        matter_cube_cost = settings.startup["matter-cube-cost"].value
    end
    if settings.startup["matter-cube-density"] then
        total_matter_capacity = settings.startup["matter-cube-density"].value
    end
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category == "matter-deconversion" then
            if recipe.ingredients ~= nil then
                for _, ingredient in pairs(recipe.ingredients) do
                    if ingredient.name == "matter" then
                        if recipe.main_product == "matter-cube" then
                            ingredient.amount = total_matter_capacity
                            ingredient.catalyst_amount = matter_cube_cost
                        end
                    end
                end
            end
        end
    end

    -- this fix reduces the breaking percentage from 1/100 to 5/1000 for matter deconversion
    if settings.startup["allow-stabilizer-less-likely-to-break"].value then
        for _, recipe in pairs(data.raw.recipe) do
            if recipe.category == "matter-deconversion" then
                if recipe.results then
                    for _, result in pairs(recipe.results) do
                        if result.name == "matter-stabilizer" then
                            result.probability = 0.995
                        end
                    end
                end
            end
        end
    end

    if settings.startup["allow-se-ore-matter-changes"].value then
        local se_resources = {
            "se-vulcanite", "se-cryonite", "se-beryllium-ore", "se-holmium-ore",
            "se-iridium-ore", "se-vitamelange", "se-naquium-ore",
            "deadlock-stack-se-vulcanite", "deadlock-stack-se-cryonite",
            "deadlock-stack-se-beryllium-ore", "deadlock-stack-se-holmium-ore",
            "deadlock-stack-se-iridium-ore", "deadlock-stack-se-vitamelange",
            "deadlock-stack-se-naquium-ore"
        }

        local se_matter_ratio = 8.0
        if settings.startup["se-ore-matter-reconversion-ratio"] then
            se_matter_ratio =
                settings.startup["se-ore-matter-reconversion-ratio"].value
        end

        log("Fixing SE ores matter deconversion & conversion ratios")

        -- Fetch the cost of each matter deconversion ratio for SE resources, then set the conversion ratio of
        -- the matter resources to be that * the ratio we've selected (2x, 4x, etc)
        for _, se_resource in pairs(se_resources) do
            local matter_value = nil
            local matter_conversion_recipe =
                data.raw["recipe"][se_resource .. "-to-matter"]
            local matter_deconversion_recipe =
                data.raw["recipe"]["matter-to-" .. se_resource]
            log("Tweaking SE Resource matter ratios: " .. se_resource)
            if matter_conversion_recipe ~= nil and matter_deconversion_recipe ~=
                nil then
                -- Find the total matter value by getting its deconversion matter ingredient
                for _, ingredient in pairs(
                                         data.raw["recipe"]["matter-to-" ..
                                             se_resource].ingredients) do
                    if ingredient.name == "matter" then
                        matter_value = ingredient.amount
                        log("Cost to create " .. se_resource .. " is " ..
                                matter_value .. " matter")
                    end
                end

                -- Set the matter conversion ratio to be what we set in our settings above
                for _, result in pairs(matter_conversion_recipe.results) do
                    if result.name == "matter" then
                        result.amount = matter_value / se_matter_ratio
                        log(
                            "New matter gained when converting to matter for " ..
                                se_resource .. " is " .. result.amount)
                        break
                    end
                end
                log("New Recipes for " .. se_resource)
            else
                log("Could not find recipes for resource: " .. se_resource)
            end
        end
    end
end

-- for _, recipe in pairs(data.raw.recipe) do
--     if recipe.category == "matter-deconversion" then
--         main_product = get_recipe_name(recipe)

--         if main_product then
--             -- log(main_product)
--             if has_value(se_resources, main_product) then
--                 for _, ingredient in pairs(recipe.ingredients) do
--                     if ingredient.name == "matter" then
--                         -- Undo the SE Matter Multiplier of 8X
--                         ingredient.amount =
--                             math.floor(ingredient.amount / se_matter_multiplier)
--                         ingredient.catalyst_amount =
--                             math.floor(ingredient.catalyst_amount /
--                                            se_matter_multiplier)
--                     end
--                 end
--             end
--         else
--             log("no main product found for recipe")
--         end
--     end
-- end
