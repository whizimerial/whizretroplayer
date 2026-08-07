local MOD_NAME = minetest.get_current_modname()

local last_body_yaw = {}
local anim_timer = {}
local current_frame = {}

minetest.register_entity(MOD_NAME .. ":sprite_display", {
    physical = false,
    pointable = false,
    visual = "upright_sprite",
    textures = {"frontidle.png"},
    visual_size = {x = 1, y = 2},
    backface_culling = false,
    
    on_step = function(self, dtime)
        local parent = self.object:get_attach()
        if not parent or not parent:is_player() then
            self.object:remove()
            return
        end

        local pname = parent:get_player_name()
        local vel = parent:get_velocity()
        local is_moving = (math.abs(vel.x) + math.abs(vel.z)) > 0.1

        -- Detect item use/attack (LMB or RMB controls)
        local control = parent:get_player_control()
        local is_using = control.dig or control.place or control.LMB or control.RMB

        -- 1. Camera Yaw
        local cam_yaw = parent:get_look_horizontal()

        -- 2. Determine Body Yaw from velocity vector
        if is_moving then
            last_body_yaw[pname] = math.atan2(-vel.x, vel.z)
        elseif not last_body_yaw[pname] then
            last_body_yaw[pname] = cam_yaw
        end

        local body_yaw = last_body_yaw[pname]

        -- 3. Calculate Angle & Invert (+ math.pi)
        local diff = (body_yaw - cam_yaw + math.pi) % (math.pi * 2)

        -- 4. Animation Timer
        anim_timer[pname] = (anim_timer[pname] or 0) + dtime
        if anim_timer[pname] > 0.15 then
            anim_timer[pname] = 0
            current_frame[pname] = ((current_frame[pname] or 1) % 4) + 1
        end
        local frame = is_moving and current_frame[pname] or 1

        -- 5. Directional Mapping
        local dir_prefix = "front"

        if diff >= (math.pi * 0.25) and diff < (math.pi * 0.75) then
            dir_prefix = "left"
        elseif diff >= (math.pi * 0.75) and diff < (math.pi * 1.25) then
            dir_prefix = "back"
        elseif diff >= (math.pi * 1.25) and diff < (math.pi * 1.75) then
            dir_prefix = "right"
        else
            dir_prefix = "front"
        end

        -- 6. Select Texture (Priority: Using Item > Walking > Idle)
        local base_action_name = "idle"
        if is_using then
            base_action_name = "use"
        elseif is_moving then
            base_action_name = "walk" .. frame
        end

        local body_texture = dir_prefix .. base_action_name .. ".png"
        local clothes_texture = dir_prefix .. base_action_name .. "clothes.png"

        -- Use the 'pname' we already successfully got from 'parent' at the start of on_step!
        local hex = "#FFFFFF"
        if player_tint and player_tint[pname] then
            hex = player_tint[pname]
        end

        -- Apply colorize with a balanced ratio (140) to keep clothing texture details/shading intact
        local final_texture = body_texture .. "^(" .. clothes_texture .. "^[colorize:" .. hex .. ":140)"

        -- Update Sprite
        self.object:set_properties({
            textures = {final_texture}
        })
    end,
})

minetest.register_on_joinplayer(function(player)
    local pname = player:get_player_name()
    anim_timer[pname] = 0
    current_frame[pname] = 1

    player:set_properties({
        visual_size = {x = 1, y = 1},
        textures = {"blank.png", "blank.png", "blank.png", "blank.png"}
    })

    local sprite = minetest.add_entity(player:get_pos(), MOD_NAME .. ":sprite_display")
    if sprite then
        sprite:set_attach(player, "", {x = 0, y = 10, z = 0}, {x = 0, y = 0, z = 0})
    end
end)

minetest.register_on_leaveplayer(function(player)
    local pname = player:get_player_name()
    last_body_yaw[pname] = nil
    anim_timer[pname] = nil
    current_frame[pname] = nil
end)
