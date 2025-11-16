-- Guda Database Module
-- Handles saving and loading character data

local addon = Guda

local DB = {}
addon.Modules.DB = DB

-- Current player info
local playerName, playerRealm, playerFaction

-- Initialize database
function DB:Initialize()
    -- Get player info
    playerName = UnitName("player")
    playerRealm = GetRealmName()
    playerFaction = UnitFactionGroup("player")

    local fullName = playerName .. "-" .. playerRealm

    -- Initialize global DB
    if not Guda_DB then
        Guda_DB = {
            version = addon.VERSION,
            characters = {},
        }
    end

    -- Initialize character DB
    if not Guda_CharDB then
        Guda_CharDB = {
            settings = {
                showBankInBags = true,
                showOtherChars = true,
                bagColumns = 10,
                bankColumns = 15,
                sortMethod = "quality", -- quality, name, type
                iconSize = addon.Constants and addon.Constants.BUTTON_SIZE or 37,
                iconFontSize = 12,
            },
        }
    end

    -- Ensure new settings exist for existing installations
    if not Guda_CharDB.settings.bagColumns then
        Guda_CharDB.settings.bagColumns = 10
    end
    if not Guda_CharDB.settings.bankColumns then
        Guda_CharDB.settings.bankColumns = 15
    end
    if not Guda_CharDB.settings.iconSize then
        Guda_CharDB.settings.iconSize = addon.Constants and addon.Constants.BUTTON_SIZE or 37
    end
    if not Guda_CharDB.settings.iconFontSize then
        Guda_CharDB.settings.iconFontSize = 12
    end

    -- Initialize this character's data
    if not Guda_DB.characters[fullName] then
        Guda_DB.characters[fullName] = {
            name = playerName,
            realm = playerRealm,
            faction = playerFaction,
            class = UnitClass("player"),
            level = UnitLevel("player"),
            money = 0,
            bags = {},
            bank = {},
            lastUpdate = time(),
        }
    end

    addon:Debug("Database initialized for %s", fullName)
end

-- Get current player's full name
function DB:GetPlayerFullName()
    return playerName .. "-" .. playerRealm
end

-- Get current character data
function DB:GetCurrentCharacter()
    local fullName = self:GetPlayerFullName()
    return Guda_DB.characters[fullName]
end

-- Save bag data
function DB:SaveBags(bagData)
    local char = self:GetCurrentCharacter()
    if char then
        char.bags = bagData
        char.lastUpdate = time()
        addon:Debug("Saved bag data")
    end
end

-- Save bank data
function DB:SaveBank(bankData)
    local char = self:GetCurrentCharacter()
    if char then
        char.bank = bankData
        char.lastUpdate = time()
        addon:Debug("Saved bank data")
    end
end

-- Save money
function DB:SaveMoney(copper)
    local char = self:GetCurrentCharacter()
    if char then
        char.money = copper
        char.level = UnitLevel("player")
        addon:Debug("Saved money: %d copper", copper)
    end
end

-- Get all characters (optionally filter by faction)
function DB:GetAllCharacters(sameFactionOnly)
    local chars = {}
    for fullName, data in pairs(Guda_DB.characters) do
        if not sameFactionOnly or data.faction == playerFaction then
            table.insert(chars, {
                fullName = fullName,
                name = data.name,
                realm = data.realm,
                class = data.class,
                level = data.level,
                faction = data.faction,
                money = data.money,
                lastUpdate = data.lastUpdate,
            })
        end
    end

    -- Sort by name
    table.sort(chars, function(a, b)
        return a.name < b.name
    end)

    return chars
end

-- Get character's bags
function DB:GetCharacterBags(fullName)
    local char = Guda_DB.characters[fullName]
    return char and char.bags or {}
end

-- Get character's bank
function DB:GetCharacterBank(fullName)
    local char = Guda_DB.characters[fullName]
    return char and char.bank or {}
end

-- Get total money across all characters
function DB:GetTotalMoney(sameFactionOnly)
    local total = 0
    for fullName, data in pairs(Guda_DB.characters) do
        if not sameFactionOnly or data.faction == playerFaction then
            total = total + (data.money or 0)
        end
    end
    return total
end

-- Get character setting
function DB:GetSetting(key)
    -- SavedVariables may not be initialized yet when some UI OnLoad scripts run
    if not Guda_CharDB or not Guda_CharDB.settings then
        return nil
    end
    return Guda_CharDB.settings[key]
end

-- Set character setting
function DB:SetSetting(key, value)
    -- Ensure tables exist even if called early
    if not Guda_CharDB then
        Guda_CharDB = { settings = {} }
    elseif not Guda_CharDB.settings then
        Guda_CharDB.settings = {}
    end
    Guda_CharDB.settings[key] = value
end

-- Cleanup old characters (not updated in 90 days)
function DB:CleanupOldCharacters()
    local cutoff = time() - (90 * 24 * 60 * 60) -- 90 days
    local removed = 0

    for fullName, data in pairs(Guda_DB.characters) do
        if data.lastUpdate and data.lastUpdate < cutoff then
            Guda_DB.characters[fullName] = nil
            removed = removed + 1
        end
    end

    if removed > 0 then
        addon:Print("Cleaned up %d old character(s)", removed)
    end
end
