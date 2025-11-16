-- Guda Bank Scanner
-- Scans and stores bank contents

local addon = Guda

local BankScanner = {}
addon.Modules.BankScanner = BankScanner

local bankOpen = false

-- Scan all bank bags and return data
function BankScanner:ScanBank()
    if not bankOpen then
        addon:Debug("Cannot scan bank - not open")
        return {}
    end

    local bankData = {}

    for _, bagID in ipairs(addon.Constants.BANK_BAGS) do
        bankData[bagID] = self:ScanBankBag(bagID)
    end

    return bankData
end

-- Scan a single bank bag
function BankScanner:ScanBankBag(bagID)
    local bag = {
        slots = {},
        numSlots = addon.Modules.Utils:GetBagSlotCount(bagID),
        freeSlots = 0,
    }

    if not addon.Modules.Utils:IsBagValid(bagID) then
        return bag
    end

    for slot = 1, bag.numSlots do
        local itemData = addon.Modules.BagScanner:ScanSlot(bagID, slot)
        bag.slots[slot] = itemData

        if not itemData then
            bag.freeSlots = bag.freeSlots + 1
        end
    end

    return bag
end

-- Save current bank to database
function BankScanner:SaveToDatabase()
    if not bankOpen then
        return
    end

    local bankData = self:ScanBank()
    addon.Modules.DB:SaveBank(bankData)
    addon:Debug("Bank data saved")
end

-- Initialize bank scanner
function BankScanner:Initialize()
    -- Bank opened
    addon.Modules.Events:OnBankOpen(function()
        bankOpen = true
        addon:Debug("Bank opened")

        -- Delay scan to ensure bank is fully loaded
        local frame = CreateFrame("Frame")
        local elapsed = 0
        frame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            if elapsed >= 0.5 then
                frame:SetScript("OnUpdate", nil)
                BankScanner:SaveToDatabase()
            end
        end)
    end, "BankScanner")

    -- Bank closed
    addon.Modules.Events:OnBankClose(function()
        bankOpen = false
        addon:Debug("Bank closed")
    end, "BankScanner")

    -- Update on bag changes while bank is open
    addon.Modules.Events:OnBagUpdate(function()
        if bankOpen then
            BankScanner:SaveToDatabase()
        end
    end, "BankScanner")
end

-- Check if bank is currently open
function BankScanner:IsBankOpen()
    return bankOpen
end
