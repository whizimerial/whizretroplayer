-- Table to store custom tints globally in memory so fakethreed.lua can read it instantly
player_tint = {}

-- Helper function to load tint data from mod storage when a player joins or server starts
local mod_storage = minetest.get_mod_storage()

local function load_player_tint(pname)
    local saved_color = mod_storage:get_string("tint_" .. pname)
    if saved_color and saved_color ~= "" then
        player_tint[pname] = saved_color
    end
end

-- Load tints for players already online (e.g. on reload) and when they join
minetest.register_on_joinplayer(function(player)
    load_player_tint(player:get_player_name())
end)

-- Register the /color chat command
minetest.register_chatcommand("color", {
    params = "<rrggbb>",
    description = "Set your custom player tint using a hex code (e.g. /color FF0000)",
    privs = {interact = true},
    func = function(name, param)
        -- Clean up string (trim spaces)
        param = param:trim()
        
        if param == "" then
            local current = player_tint[name]
            if current then
                return true, "Your current tint is: " .. current
            else
                return false, "Usage: /color <rrggbb> (e.g., /color FF0000 or /color #FF0000)"
            end
        end

        -- Ensure it starts with '#' properly using concatenation (..)
        if not param:find("^#") then
            param = "#" .. param
        end
        param = "#" .. param:gsub("^#+", "")

        -- Validate Hex format (#RRGGBB)
        if not param:match("^#%x%x%x%x%x%x$") then
            return false, "Invalid color format! Please use a 6-digit hex code, e.g., /color FF0000"
        end

        -- Save to global table for fakethreed.lua
        player_tint[name] = param

        -- Save permanently to Mod Storage (persists through leaving and server restarts)
        mod_storage:set_string("tint_" .. name, param)

        return true, "Tint successfully updated to " .. param
    end,
})
