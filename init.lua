--[[
  -  Sponge mod for Minetest
  -  water removal for survival

made by Benjie/Fiftysix - 27/8/18

soggy sponges can be found quite rare, deep in the sea where it is dark
these can be cooked into dry sponges, and then placed near a liquid to remove an area of it
they will hold the water away until they are removed.
to use them again, they have to be cooked.

sponges create a 9x9 area of air-like nodes that water can't flow through (checks for protection)
if sponges have cleared more than 3 nodes of liquid, they become soggy sponges
removing a sponge or soggy sponge will turn a 9x9 area of air-like nodes back into air
(air-like nodes can be removed in protection by removing a sponge outside the protection, they are not meant to be permanent)
]]--

local area = 4


local destruct = function(pos)  -- removing the air-like nodes
    for x = pos.x-area, pos.x+area do
        for y = pos.y-area, pos.y+area do
            for z = pos.z-area, pos.z+area do
                local n = minetest.get_node({x=x, y=y, z=z}).name
                if n == "sponge:liquid_stop" then
                    minetest.remove_node({x=x, y=y, z=z})
                end
            end
        end
    end
end


minetest.register_node("sponge:liquid_stop", {  -- air-like node
    description = "liquid blocker for sponges",
    drawtype = "airlike",
    drop = {max_items=0, items={}},
    groups = {not_in_creative_inventory=1},
    pointable = false,
    walkable = false,
    sunlight_propagates = true,
    paramtype = "light",
    buildable_to = true,
})


minetest.register_node("sponge:sponge", {  -- dry sponge
    description = "Sponge",
    tiles = {"sponge_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
    
    on_place = function(itemstack, placer, pointed_thing)
        local pos = minetest.get_pointed_thing_position(pointed_thing, pointed_thing.above)
        local name = placer:get_player_name()
        
        if not minetest.is_protected(pos, name) then
            local count = 0
            for x = pos.x-area, pos.x+area do
                for y = pos.y-area, pos.y+area do
                    for z = pos.z-area, pos.z+area do
                        local n = minetest.get_node({x=x, y=y, z=z}).name
                        local d = minetest.registered_nodes[n]
                        if d ~= nil and (n == "air" or d["drawtype"] == "liquid" or d["drawtype"] == "flowingliquid") then
                            local p = {x=x, y=y, z=z}
                            if not minetest.is_protected(p, name) then
                                if n ~= "air" then
                                    count = count + 1  -- counting liquids
                                end
                                minetest.set_node(p, {name="sponge:liquid_stop"})
                            end
                        end
                    end
                end
            end
        
        
            if count > 3 then  -- only turns soggy if it removed more than 3 nodes
                minetest.set_node(pos, {name="sponge:soggy_sponge"})
            else
                minetest.set_node(pos, {name="sponge:sponge"})
            end
            itemstack:take_item(1)
        end
        return itemstack
    end,
    
    on_destruct = destruct
})


minetest.register_node("sponge:soggy_sponge", {  -- soggy sponge
    description = "Soggy sponge",
    tiles = {"sponge_soggy_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
    
    on_destruct = destruct
})

minetest.register_craft({  -- cooking soggy sponge back into dry sponge
    type = "cooking",
    recipe = "sponge:soggy_sponge",
    output = "sponge:sponge",
    cooktime = 2,
})

minetest.register_decoration({  -- sponges are found deep in the sea
    name = "sponge:sponges",
    deco_type = "simple",
    place_on = {"default:sand"},
    spawn_by = "default:water_source",
    num_spawn_by = 3,
    fill_ratio = 0.0003,
    y_max = -12,
    flags = "force_placement",
    decoration = "sponge:soggy_sponge",
})
