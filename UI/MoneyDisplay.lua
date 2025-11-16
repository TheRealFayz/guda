-- Guda Money Display
-- Handles money display in UI

local addon = Guda

local MoneyDisplay = {}
addon.Modules.MoneyDisplay = MoneyDisplay

-- Create a money display frame
function MoneyDisplay:CreateDisplay(parent, x, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    frame:SetWidth(200)
    frame:SetHeight(20)

    -- Gold text
    frame.gold = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.gold:SetPoint("LEFT", frame, "LEFT", 0, 0)

    -- Silver text
    frame.silver = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.silver:SetPoint("LEFT", frame.gold, "RIGHT", 2, 0)

    -- Copper text
    frame.copper = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.copper:SetPoint("LEFT", frame.silver, "RIGHT", 2, 0)

    return frame
end

-- Update money display
function MoneyDisplay:Update(frame, copper)
    if not frame or not copper then
        return
    end

    local gold = math.floor(copper / 10000)
    local silver = math.floor(mod(copper, 10000) / 100)
    local bronze = mod(copper, 100)

    if gold > 0 then
        frame.gold:SetText(gold .. "|cFFFFD700g|r")
        frame.gold:Show()
    else
        frame.gold:Hide()
    end

    if silver > 0 or gold > 0 then
        frame.silver:SetText(silver .. "|cFFC0C0C0s|r")
        frame.silver:Show()
    else
        frame.silver:Hide()
    end

    frame.copper:SetText(bronze .. "|cFFFF6600c|r")
    frame.copper:Show()
end
