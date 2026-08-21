sprite_lib = sprite_lib or {}
local MOD_NAME = minetest.get_current_modname()

sprite_lib.last_body_yaw = sprite_lib.last_body_yaw or {}
sprite_lib.anim_timer = sprite_lib.anim_timer or {}
sprite_lib.current_frame = sprite_lib.current_frame or {}
sprite_lib.animation_overrides = sprite_lib.animation_overrides or {}

local function get_safe_texture(texture_name)
    if minetest.registered_items[texture_name] or minetest.simplistic_texture_check and minetest.simplistic_texture_check(texture_name) then
        return texture_name
    end
    return texture_name
end

local function resolve_texture(base, overlay)
    local base_tex = base
    local overlay_tex = overlay
    return string.format("%s^(%s^[colorize:%s:120)", base_tex, overlay_tex, hex or "#00FF00")
end

minetest.register_entity(MOD_NAME .. ":sprite_display", {
    physical = false,
    pointable = false,
    visual = "upright_sprite",
    textures = {"blank.png"},
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
        
        -- Vehicle/Boat tracking fix
        local attach_parent = parent:get_attach()
        if attach_parent then
            local veh_vel = attach_parent:get_velocity()
            if veh_vel and (math.abs(veh_vel.x) + math.abs(veh_vel.z)) > 0.1 then
                vel = veh_vel
            end
        end

        local is_moving = (math.abs(vel.x) + math.abs(vel.z)) > 0.1
        local control = parent:get_player_control()
        local is_using = control.dig or control.place or control.LMB or control.RMB

        -- Yaw calculation
        local cam_yaw = parent:get_look_horizontal()
        if is_moving then
            sprite_lib.last_body_yaw[pname] = math.atan2(-vel.x, vel.z)
        elseif not sprite_lib.last_body_yaw[pname] then
            sprite_lib.last_body_yaw[pname] = cam_yaw
        end

        local body_yaw = sprite_lib.last_body_yaw[pname]
        local diff = (body_yaw - cam_yaw + math.pi) % (math.pi * 2)

        local dir_name, face_type = sprite_lib.get_face_mapping(diff)

        local action_name, max_frames, anim_speed = sprite_lib.get_current_animation(pname, is_moving, is_using)

        sprite_lib.anim_timer[pname] = (sprite_lib.anim_timer[pname] or 0) + dtime
        if sprite_lib.anim_timer[pname] > anim_speed then
            sprite_lib.anim_timer[pname] = 0
            sprite_lib.current_frame[pname] = ((sprite_lib.current_frame[pname] or 1) % max_frames) + 1
        end
        
        local frame_num = (max_frames > 1) and sprite_lib.current_frame[pname] or 1
        if action_name == "idle" then frame_num = 1 end

        local base_texture = string.format("%s_%s_%s_%d.png", dir_name, face_type, action_name, frame_num)
        local overlay_texture = string.format("%s_%s_%s_%d_clothes.png", dir_name, face_type, action_name, frame_num)

        local final_base = base_texture
        local final_overlay = overlay_texture

        local hex = sprite_lib.player_tint and sprite_lib.player_tint[pname] or "#00FF00"

        local final_texture = string.format("%s^(%s^[colorize:%s:120)", final_base, final_overlay, hex)

        self.object:set_properties({
            textures = {final_texture}
        })
    end,
})

minetest.register_on_joinplayer(function(player)
    local pname = player:get_player_name()
    sprite_lib.anim_timer[pname] = 0
    sprite_lib.current_frame[pname] = 1

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
    sprite_lib.last_body_yaw[pname] = nil
    sprite_lib.anim_timer[pname] = nil
    sprite_lib.current_frame[pname] = nil
    sprite_lib.animation_overrides[pname] = nil
end)
