-- Guda Character Selector
-- Select character to view bags/bank

local addon = Guda

local CharacterSelector = {}
addon.Modules.CharacterSelector = CharacterSelector

local charButtons = {}

-- OnLoad
function Guda_CharacterSelector_OnLoad(self)
    getglobal(self:GetName().."_Title"):SetText("Select Character")
    addon:Debug("Character selector loaded")
end

-- OnShow
function Guda_CharacterSelector_OnShow(self)
    CharacterSelector:Update()
end

-- Toggle visibility
function CharacterSelector:Toggle()
    if Guda_CharacterSelector:IsShown() then
        Guda_CharacterSelector:Hide()
    else
        Guda_CharacterSelector:Show()
    end
end

-- Update character list
function CharacterSelector:Update()
    -- Clear existing buttons
    for _, button in ipairs(charButtons) do
        button:Hide()
    end
    charButtons = {}

    -- Get all characters
    local characters = addon.Modules.DB:GetAllCharacters(true) -- Same faction only
    local characterList = getglobal("Guda_CharacterSelector_CharacterList")

    -- Create buttons for each character
    local yOffset = -10
    for i, char in ipairs(characters) do
        local button = self:GetCharacterButton(i)

        -- Set text with class color
        local classColor = addon.Modules.Utils:GetClassColor(char.class)
        local coloredName = addon.Modules.Utils:ColorText(char.name, classColor.r, classColor.g, classColor.b)

        button:SetText(string.format("%s (Lv %d)", coloredName, char.level))
        button.charData = char

        -- Position
        button:ClearAllPoints()
        button:SetPoint("TOP", characterList, "TOP", 0, yOffset)
        yOffset = yOffset - 35

        button:Show()
        table.insert(charButtons, button)
    end

    if table.getn(characters) == 0 then
        addon:Debug("No other characters found")
    end
end

-- Get or create character button
function CharacterSelector:GetCharacterButton(index)
    local name = "Guda_CharButton" .. index
    local characterList = getglobal("Guda_CharacterSelector_CharacterList")

    local button = getglobal(name)
    if not button then
        button = CreateFrame("Button", name, characterList, "Guda_CharacterButtonTemplate")
    end

    return button
end

-- Character button OnClick
function Guda_CharacterButton_OnClick(self)
    if not self.charData then
        return
    end

    addon:Print("Viewing %s's bags", self.charData.name)

    -- Show bags for this character
    addon.Modules.BagFrame:ShowCharacter(self.charData.fullName)

    -- Close selector
    Guda_CharacterSelector:Hide()

    -- Show bag frame if not visible
    if not Guda_BagFrame:IsShown() then
        Guda_BagFrame:Show()
    end
end

-- Character button OnEnter
function Guda_CharacterButton_OnEnter(self)
    if not self.charData then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(self.charData.name, 1, 1, 1)
    GameTooltip:AddLine("Level " .. self.charData.level .. " " .. self.charData.class, 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Money: " .. addon.Modules.Utils:FormatMoney(self.charData.money))

    if self.charData.lastUpdate then
        GameTooltip:AddLine("Last seen: " .. addon.Modules.Utils:FormatTimeAgo(self.charData.lastUpdate), 0.5, 0.5, 0.5)
    end

    GameTooltip:Show()
end

-- Show current character
function Guda_CharacterSelector_ShowCurrent()
    addon.Modules.BagFrame:ShowCurrentCharacter()
    Guda_CharacterSelector:Hide()

    if not Guda_BagFrame:IsShown() then
        Guda_BagFrame:Show()
    end
end
