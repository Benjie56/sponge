--[[
  -  Minetest Sponge mod
  -  Water removing sponges for Minetest
  -  Created by Benjie/fiftysix/56 2018-08-27 - Last updated 2023-02-21
  -  Copyright Benjie 2018-2023

Soggy sponges can rarely be found deep in the sea where the darkness begins.
These can be cooked into dry sponges, and then placed near a liquid to remove the surrounding sphere of it
They will hold the water away until they are removed.
This will cause them to become soggy, so to use them again they have to be cooked.

Sponges create a diameter 9 sphere of air-like nodes that water can't flow through (checks for protection)
If sponges have cleared more than 3 nodes of liquid, they become soggy sponges
removing a sponge or soggy sponge will turn a diameter 9 sphere of air-like nodes back into air
(air-like nodes can be removed in protection by removing a sponge outside the protection, they are not meant to be permanent)
]]--


local modname = minetest.get_current_modname()

local keep_dry = 3  -- The maximum amount of water cleared where the sponge doesn't turn soggy
-- Load configurable options
local replace_air_nodes = minetest.settings:get_bool("sponge_replace_air_nodes", true)
local group_list = minetest.settings:get("sponge_group_list", false) or "water"
local group_list_type = minetest.settings:get("sponge_group_list_type") or "whitelist_source"
local radius = tonumber(minetest.settings:get("sponge_radius") or 4.5)
local shape_sphere = minetest.settings:get_bool("sponge_shape_sphere", true)
local replace_with_air = minetest.settings:get_bool("sponge_replace_with_air", false)

-- returns true if groups contains anything in list
local compare_groups = function(list, groups)
    for group in list:gmatch("([^,]+)") do
        if groups[group] and groups[group] > 0 then
            return true
        end
    end
    return false
end


-- called by after_destruct()
local destruct = function(pos)  -- removing the air-like nodes
    -- if air was used, there is nothing to remove
    if replace_with_air then return end

    local edge_distance = math.floor(radius)
    
    -- find all sponges that intersect with this sponge's radius
    local sponge_info = minetest.find_nodes_in_area(
        vector.new(pos.x-edge_distance*2, pos.y-edge_distance*2, pos.z-edge_distance*2),
        vector.new(pos.x+edge_distance*2, pos.y+edge_distance*2, pos.z+edge_distance*2),
        {modname..":soggy_sponge", modname..":sponge"}, true
    )
    local sponges = {}
    for _, p in pairs(sponge_info) do
        local node = minetest.get_node(p[1])
        if node.param1 == 1 or node.name == modname..":sponge" then
            table.insert(sponges, p[1])
        end
    end

    for x = pos.x-edge_distance, pos.x+edge_distance do
        for y = pos.y-edge_distance, pos.y+edge_distance do
            for z = pos.z-edge_distance, pos.z+edge_distance do
                local p = vector.new(x, y, z)
                if (not shape_sphere or p:distance(pos) <= radius) then
                    local n = minetest.get_node(p).name
                    if n == modname..":liquid_stop" then

                        -- check if position intersects with another sponge
                        local intersect = false
                        for _, s_pos in pairs(sponges) do
                            if (
                                (shape_sphere and p:distance(s_pos) <= radius) or
                                (not shape_sphere and
                                 math.abs(s_pos.x-x) <= radius and math.abs(s_pos.y-y) <= radius and math.abs(s_pos.z-z) <= radius)
                               ) then

                                intersect = true
                                break
                            end
                        end

                        if not intersect then
                            minetest.remove_node(p)
                        end
                    end
                end
            end
        end
    end
end

-- called by after_place_node()
local construct = function(pos, placer, itemstack, pointed_thing)
    local playername = placer:get_player_name()

    if not minetest.is_protected(pos, playername) then
        local count = 0
        
        local edge_distance = math.floor(radius)
        for x = pos.x-edge_distance, pos.x+edge_distance do
            for y = pos.y-edge_distance, pos.y+edge_distance do
                for z = pos.z-edge_distance, pos.z+edge_distance do
                    local p = vector.new(x, y, z)

                    if (not shape_sphere or p:distance(pos) <= radius) then

                        local n = minetest.get_node(p).name
                        local def = minetest.registered_nodes[n]
                        local replace = false
                        if def == nil or minetest.is_protected(p, playername) then
                            -- replace = false
                        elseif replace_air_nodes and n == "air" then
                            replace = true
                        elseif def["drawtype"] == "flowingliquid" then
                            if group_list_type == "whitelist" then
                                if compare_groups(group_list, def.groups or {}) then
                                    replace = true
                                end
                            elseif group_list_type == "blacklist" then
                                if not compare_groups(group_list, def.groups or {}) then
                                    replace = true
                                end
                            else
                                replace = true
                            end
                        elseif def["drawtype"] == "liquid" then
                            if group_list_type == "whitelist" or group_list_type == "whitelist_source" then
                                if compare_groups(group_list, def.groups or {}) then
                                    replace = true
                                end
                            elseif group_list_type == "blacklist" or group_list_type == "blacklist_source" then
                                if not compare_groups(group_list, def.groups or {}) then
                                    replace = true
                                end
                            else
                                replace = true
                            end
                        end

                        if replace then
                            if n ~= "air" then
                                count = count + 1  -- counting liquids
                            end
                            if replace_with_air then
                                minetest.remove_node(p)
                            else
                                minetest.set_node(p, {name=modname..":liquid_stop"})
                            end
                        end
                    end
                end
            end
        end
        
        if count > keep_dry then  -- turns soggy if it removed more than `keep_dry` nodes
            minetest.swap_node(pos, {name=modname..":soggy_sponge", param1=1})
        end
    end
end

if replace_with_air then
    minetest.register_alias(modname..":liquid_stop", "air")
else
    minetest.register_node(modname..":liquid_stop", {  -- air-like node
        description = "liquid blocker for sponges",
        drawtype = "airlike",
        drop = {max_items=0, items={}},
        groups = {not_in_creative_inventory=1},
        pointable = false,
        walkable = false,
        floodable = false,
        sunlight_propagates = true,
        paramtype = "light",
        buildable_to = true,
    })
end


minetest.register_node(modname..":sponge", {  -- dry sponge
    description = "Sponge",
    tiles = {"sponge_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
    
    after_place_node = construct,
    
    after_destruct = destruct,
})


minetest.register_node(modname..":soggy_sponge", {  -- soggy sponge
    description = "Soggy sponge",
    tiles = {"sponge_soggy_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
    
    after_destruct = destruct,
})

minetest.register_craft({  -- cooking soggy sponge back into dry sponge
    type = "cooking",
    recipe = modname..":soggy_sponge",
    output = modname..":sponge",
    cooktime = 2,
})

minetest.register_decoration({  -- sponges are found deep in the sea
    name = modname..":sponges",
    deco_type = "simple",
    place_on = {"default:sand"},
    spawn_by = "default:water_source",
    num_spawn_by = 3,
    fill_ratio = 0.0003,
    y_max = -12,
    flags = "force_placement",
    decoration = modname..":soggy_sponge",
})
