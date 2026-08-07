-- Table to store custom tints globally so fakethreed.lua can read it
player_tint = {}

-- Map of Luanti dye names to Hex Colors
local DYE_COLORS = {
    ["dye:white"]      = "#FFFFFF",
    ["dye:grey"]       = "#808080",
    ["dye:dark_grey"]  = "#404040",
    ["dye:black"]      = "#111111",
    ["dye:violet"]     = "#800080",
    ["dye:blue"]       = "#0000FF",
    ["dye:cyan"]       = "#00FFFF",
    ["dye:dark_green"] = "#006400",
    ["dye:green"]      = "#00FF00",
    ["dye:yellow"]     = "#FFFF00",
    ["dye:brown"]      = "#A52A2A",
    ["dye:orange"]     = "#FFA500",
    ["dye:red"]        = "#FF0000",
    ["dye:magenta"]    = "#FF00FF",
    ["dye:pink"]       = "#FFC0CB",
}

-- Inventory interaction detector: triggers when moving items
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" and inventory_info.from_list and inventory_info.to_list then
        local inv = player:get_inventory()
        if not inv then return end

        local from_list = inv:get_list(inventory_info.from_list)
        if from_list then
            local moved_stack = from_list[inventory_info.from_index]
            if moved_stack then
                local moved_item = moved_stack:get_name()
                local moved_color = DYE_COLORS[moved_item]

                -- If the moved item is a dye, update the player's tint immediately!
                if moved_color then
                    local pname = player:get_player_name()
                    player_tint[pname] = moved_color
                    minetest.chat_send_player(pname, "Tint updated to " .. moved_item)
                end
            end
        end
    end
end)

-- Cleanup when player leaves
minetest.register_on_leaveplayer(function(player)
    local pname = player:get_player_name()
    player_tint[pname] = nil
end)
