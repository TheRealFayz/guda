-- Guda Mailbox Scanner
-- Scans and stores mailbox contents

local addon = Guda

local MailboxScanner = {}
addon.Modules.MailboxScanner = MailboxScanner

local mailboxOpen = false

-- Scan all mailbox items and return data
function MailboxScanner:ScanMailbox()
    if not mailboxOpen then
        addon:Debug("Cannot scan mailbox - not open")
        return {}
    end

    local mailboxData = {}
    local numItems = GetInboxNumItems()

    for i = 1, numItems do
        mailboxData[i] = self:ScanMailItem(i)
    end

    return mailboxData
end

-- Scan a single mail item
function MailboxScanner:ScanMailItem(index)
    -- GetInboxItem(index) returns: packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM
    local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxItem(index)
    
    local itemData = nil
    if hasItem then
        addon:Debug("Scanning mail item %d", index)
        -- In 1.12.1, GetInboxItemLink(index) returns the link
        local itemLink = GetInboxItemLink(index)
        
        -- GetInboxItemInfo(index) returns: name, texture, count, quality, canUse
        local infoName, infoTexture, infoCount, infoQuality, infoCanUse = GetInboxItemInfo(index)
        
        addon:Debug("Mail item %d: infoName=%s, infoTexture=%s", index, tostring(infoName), tostring(infoTexture))

        -- Even if link is missing (not cached), we can store what we have from GetInboxItemInfo
        itemData = {
            link = itemLink,
            texture = infoTexture or packageIcon or "Interface\\Icons\\INV_Misc_Bag_08",
            count = infoCount or 1,
            quality = infoQuality or 0,
            name = infoName or subject or "Unknown Item",
        }

        -- If we have a link, try to get more detailed info
        if itemLink then
            local itemName, link, itemQuality, iLevel, itemCategory, itemType, itemStackCount, itemSubType, itemTexture, itemEquipLoc, itemSellPrice = addon.Modules.Utils:GetItemInfo(itemLink)
            if itemName then
                itemData.name = itemName
                itemData.quality = itemQuality or itemData.quality
                itemData.iLevel = iLevel
                itemData.type = itemType
                itemData.class = itemCategory
                itemData.subclass = itemSubType
                itemData.equipSlot = itemEquipLoc
                if itemTexture then itemData.texture = itemTexture end
            end
        end
    end

    return {
        sender = sender,
        subject = subject,
        money = money,
        CODAmount = CODAmount,
        daysLeft = daysLeft,
        hasItem = hasItem,
        item = itemData,
        wasRead = wasRead,
        packageIcon = packageIcon,
    }
end

-- Save current mailbox to database
function MailboxScanner:SaveToDatabase()
    if not mailboxOpen then
        return
    end

    local mailboxData = self:ScanMailbox()
    addon.Modules.DB:SaveMailbox(mailboxData)
    addon:Debug("Mailbox data saved")
end

-- Initialize mailbox scanner
function MailboxScanner:Initialize()
    -- Mailbox opened
    addon.Modules.Events:OnMailShow(function()
        mailboxOpen = true
        addon:Debug("Mailbox opened")
        
        -- Delay scan slightly to ensure item info is available
        local frame = CreateFrame("Frame")
        local elapsed = 0
        frame:SetScript("OnUpdate", function()
            elapsed = elapsed + arg1
            if elapsed >= 0.5 then
                frame:SetScript("OnUpdate", nil)
                if mailboxOpen then
                    MailboxScanner:SaveToDatabase()
                end
            end
        end)
    end, "MailboxScanner")

    -- Mailbox closed
    addon.Modules.Events:OnMailClosed(function()
        -- Final save on close
        self:SaveToDatabase()
        mailboxOpen = false
        addon:Debug("Mailbox closed")
    end, "MailboxScanner")
end

-- Check if mailbox is currently open
function MailboxScanner:IsMailboxOpen()
    return mailboxOpen
end
