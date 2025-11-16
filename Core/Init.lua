-- Guda - Turtle WoW Bag Addon
-- Core initialization

-- Create addon namespace
Guda = {}
local addon = Guda

-- Version info
addon.VERSION = "1.0.0"
addon.BUILD = "TurtleWoW-1.12.1"

-- Debug flag
addon.DEBUG = false

-- Constants
addon.Constants = {
    -- Bag IDs
    BACKPACK = 0,
    BAG_1 = 1,
    BAG_2 = 2,
    BAG_3 = 3,
    BAG_4 = 4,
    BANK = -1,
    BANK_BAG_1 = 5,
    BANK_BAG_2 = 6,
    BANK_BAG_3 = 7,
    BANK_BAG_4 = 8,
    BANK_BAG_5 = 9,
    BANK_BAG_6 = 10,

    -- All bag IDs for easy iteration
    BAGS = {0, 1, 2, 3, 4},
    BANK_BAGS = {-1, 5, 6, 7, 8, 9, 10},
    ALL_BAGS = {0, 1, 2, 3, 4, -1, 5, 6, 7, 8, 9, 10},

    -- Item qualities (colors)
    QUALITY_COLORS = {
        [0] = {r = 0.62, g = 0.62, b = 0.62}, -- Poor (Gray)
        [1] = {r = 1.00, g = 1.00, b = 1.00}, -- Common (White)
        [2] = {r = 0.12, g = 1.00, b = 0.00}, -- Uncommon (Green)
        [3] = {r = 0.00, g = 0.44, b = 0.87}, -- Rare (Blue)
        [4] = {r = 0.64, g = 0.21, b = 0.93}, -- Epic (Purple)
        [5] = {r = 1.00, g = 0.50, b = 0.00}, -- Legendary (Orange)
    },

    -- Save intervals
    SAVE_INTERVAL = 1800, -- 30 minutes in seconds

    -- UI Constants
    BUTTON_SIZE = 40,
    BUTTON_SPACING = 0,
    BUTTONS_PER_ROW = 10,
    MIN_ICON_SIZE = 30,
    MAX_ICON_SIZE = 64,
}

-- Initialize modules storage
addon.Modules = {}

-- Print function with addon prefix
function addon:Print(msg, a1, a2, a3, a4, a5)
    local text = string.format(msg, a1, a2, a3, a4, a5)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF96Guda:|r " .. text)
end

-- Debug print
function addon:Debug(msg, a1, a2, a3, a4, a5)
    if self.DEBUG then
        local text = string.format(msg, a1, a2, a3, a4, a5)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[Debug]|r |cFF00FF96Guda:|r " .. text)
    end
end

-- Error handler
function addon:Error(msg, a1, a2, a3, a4, a5)
    local text = string.format(msg, a1, a2, a3, a4, a5)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Error]|r |cFF00FF96Guda:|r " .. text)
end

addon:Print("Loaded v%s", addon.VERSION)
