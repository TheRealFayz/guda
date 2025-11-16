-- Guda Main Initialization
-- Sets up all modules and auto-save system

local addon = Guda

local Main = {}
addon.Modules.Main = Main

-- Auto-save timer
local autoSaveFrame = CreateFrame("Frame")
local timeSinceLastSave = 0
local SAVE_INTERVAL = addon.Constants.SAVE_INTERVAL

-- Auto-save update
autoSaveFrame:SetScript("OnUpdate", function()
    timeSinceLastSave = timeSinceLastSave + arg1

    if timeSinceLastSave >= SAVE_INTERVAL then
        Main:AutoSave()
        timeSinceLastSave = 0
    end
end)

-- Perform auto-save
function Main:AutoSave()
    addon:Debug("Auto-saving data...")

    -- Save bags
    addon.Modules.BagScanner:SaveToDatabase()

    -- Save bank (if available)
    if addon.Modules.BankScanner:IsBankOpen() then
        addon.Modules.BankScanner:SaveToDatabase()
    end

    -- Save money
    addon.Modules.MoneyTracker:Update()

    addon:Debug("Auto-save complete")
end

-- Initialize addon
function Main:Initialize()
    -- Wait for PLAYER_LOGIN to ensure saved variables are loaded
    addon.Modules.Events:OnPlayerLogin(function()
        addon:Print("Initializing...")

        -- Initialize database
        addon.Modules.DB:Initialize()

        -- Initialize scanners
        addon.Modules.BagScanner:Initialize()
        addon.Modules.BankScanner:Initialize()
        addon.Modules.MoneyTracker:Initialize()

        -- Initialize UI
        addon.Modules.BagFrame:Initialize()
        addon.Modules.BankFrame:Initialize()
        addon.Modules.SettingsPopup:Initialize()

        -- Save on logout
        addon.Modules.Events:OnPlayerLogout(function()
            addon:Print("Saving data on logout...")
            Main:AutoSave()
        end, "Main")

        -- Setup slash commands
        Main:SetupSlashCommands()

        addon:Debug("Initialization complete")

        -- Delay initial save to ensure everything is loaded
        local frame = CreateFrame("Frame")
        local elapsed = 0
        frame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            if elapsed >= 5 then
                frame:SetScript("OnUpdate", nil)
                Main:AutoSave()
                addon:Print("Ready! Type /guda to open bags")
            end
        end)
    end, "Main")
end

-- Setup slash commands
function Main:SetupSlashCommands()
    SLASH_Guda1 = "/Guda"
    SLASH_Guda2 = "/guda"
    SLASH_Guda3 = "/gn"

    SlashCmdList["Guda"] = function(msg)
        msg = string.lower(msg or "")

        if msg == "" or msg == "bags" then
            -- Toggle bags
            addon.Modules.BagFrame:Toggle()

        elseif msg == "bank" then
            -- Toggle bank
            addon.Modules.BankFrame:Toggle()

        elseif msg == "char" or msg == "chars" or msg == "characters" then
            -- Toggle character selector
            addon.Modules.CharacterSelector:Toggle()

        elseif msg == "sort" then
            -- Sort bags
            addon.Modules.SortEngine:SortBags()

        elseif msg == "sortbank" then
            -- Sort bank
            addon.Modules.SortEngine:SortBank()

        elseif msg == "save" then
            -- Manual save
            Main:AutoSave()
            addon:Print("Data saved manually")

        elseif msg == "debug" then
            -- Toggle debug
            addon.DEBUG = not addon.DEBUG
            addon:Print("Debug mode: %s", addon.DEBUG and "ON" or "OFF")

        elseif msg == "cleanup" then
            -- Cleanup old characters
            addon.Modules.DB:CleanupOldCharacters()

        elseif msg == "help" then
            -- Show help
            addon:Print("Commands:")
            addon:Print("/guda - Toggle bags")
            addon:Print("/guda bank - Toggle bank")
            addon:Print("/guda chars - Select character")
            addon:Print("/guda sort - Sort bags")
            addon:Print("/guda sortbank - Sort bank")
            addon:Print("/guda save - Manual save")
            addon:Print("/guda debug - Toggle debug mode")
            addon:Print("/guda cleanup - Remove old characters")

        else
            addon:Print("Unknown command. Type /guda help for commands")
        end
    end

    addon:Debug("Slash commands registered")
end

-- Run initialization
Main:Initialize()
