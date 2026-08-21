sprite_lib = sprite_lib or {}

function sprite_lib.get_face_mapping(diff)
    local slice = math.pi * 0.25
    
    -- Normalizing diff to 0 to 2*pi
    diff = diff % (math.pi * 2)
    if diff < 0 then diff = diff + (math.pi * 2) end

    -- 8-way directional mapping using front/back bases with left/right/straight variants
    if diff >= (slice * 0.5) and diff < (slice * 1.5) then
        return "front", "2" 
    elseif diff >= (slice * 1.5) and diff < (slice * 2.5) then
        return "right", "1"
    elseif diff >= (slice * 2.5) and diff < (slice * 3.5) then
        return "back", "2"
    elseif diff >= (slice * 3.5) and diff < (slice * 4.5) then
        return "back", "1"
    elseif diff >= (slice * 4.5) and diff < (slice * 5.5) then
        return "back", "0" 
    elseif diff >= (slice * 5.5) and diff < (slice * 6.5) then
        return "left", "1" 
    elseif diff >= (slice * 6.5) and diff < (slice * 7.5) then
        return "front", "0" 
    else
        return "front", "1"
    end
end
