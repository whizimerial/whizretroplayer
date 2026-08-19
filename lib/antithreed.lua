local MOD_NAME = minetest.get_current_modname() or "your_mod_name"

-- Target assets to completely nullify the 3D model footprint
local EMPTY_MESH = MOD_NAME .. "_empty.obj"
local BLANK_TEXTURE = "whizretroplayer_blank.png"

-- Overwrite models and textures

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if player and player:is_player() then
            local props = player:get_properties()
            
 -- Check if another mod changed the visual model away from "mesh" or changed our blank texture
            if props.visual ~= "mesh" or props.mesh ~= (MOD_NAME .. ":whizretroplayer_empty.obj") then
                player:set_properties({
                    visual = "mesh",
                    mesh = MOD_NAME .. ":whizretroplayer_empty.obj",
                    visual_size = {x = 1, y = 1, z = 1},
                    textures = {
                        BLANK_TEXTURE,
                        BLANK_TEXTURE,
                        BLANK_TEXTURE,
                        BLANK_TEXTURE
                    },
                })
            end
        end
    end
end)
