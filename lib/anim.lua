sprite_lib = sprite_lib or {}

sprite_lib.default_animations = {
 	idle = { frames = 1, speed = 0.15 },
 	walk = { frames = 4, speed = 0.15 },
 	use  = { frames = 1, speed = 0.15 },
}

function sprite_lib.set_animation(player, action_name, frame_count, speed)
 	if not player then return end
 	local pname = player:get_player_name()
 	if not action_name then
 	 	sprite_lib.animation_overrides[pname] = nil
 	else
 	 	sprite_lib.animation_overrides[pname] = {
 	action = action_name,
 	frames = frame_count or 1,
 	speed = speed or 0.15
 	 	}
 	end
end

function sprite_lib.get_current_animation(pname, is_moving, is_using)
 	if sprite_lib.animation_overrides and sprite_lib.animation_overrides[pname] then
 	 	local ov = sprite_lib.animation_overrides[pname]
 	 	return ov.action, ov.frames, ov.speed
 	end

 	if is_using then
 	 	local anim = sprite_lib.default_animations.use
 	 	return "use", anim.frames, anim.speed
 	elseif is_moving then
 	 	local anim = sprite_lib.default_animations.walk
 	 	return "walk", anim.frames, anim.speed
 	else
 	 	local anim = sprite_lib.default_animations.idle
 	 	return "idle", anim.frames, anim.speed
 	end
end
