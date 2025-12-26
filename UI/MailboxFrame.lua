-- Mailbox Frame
-- Mailbox viewing UI

local addon = Guda

local MailboxFrame = {}
addon.Modules.MailboxFrame = MailboxFrame

local currentViewChar = nil
local searchText = ""
local isReadOnlyMode = true -- Mailbox is always read-only in this addon (viewing offline data)
local itemButtons = {}
local mailboxClickCatcher = nil

-- OnLoad
function Guda_MailboxFrame_OnLoad(self)
    -- Set up initial backdrop
    addon:ApplyBackdrop(self, "DEFAULT_FRAME")

    -- Set up search box placeholder
    local searchBox = getglobal(self:GetName().."_SearchBar_SearchBox")
    if searchBox then
        searchBox:SetText("Search mailbox...")
        searchBox:SetTextColor(0.5, 0.5, 0.5, 1)
    end

    -- Create invisible full-screen frame to catch clicks outside the mailbox frame while typing in search
    if not mailboxClickCatcher then
        mailboxClickCatcher = CreateFrame("Frame", "Guda_MailboxClickCatcher", UIParent)
        mailboxClickCatcher:SetFrameStrata("BACKGROUND")
        mailboxClickCatcher:SetAllPoints(UIParent)
        mailboxClickCatcher:EnableMouse(true)
        mailboxClickCatcher:Hide()

        mailboxClickCatcher:SetScript("OnMouseDown", function()
            if Guda_MailboxFrame_ClearSearch then
                Guda_MailboxFrame_ClearSearch()
            end
        end)
    end
end

-- Clear search focus
function Guda_MailboxFrame_ClearSearch()
    local searchBox = getglobal("Guda_MailboxFrame_SearchBar_SearchBox")
    if searchBox then
        searchBox:ClearFocus()
    end
end

-- OnShow
function Guda_MailboxFrame_OnShow(self)
    -- Apply frame transparency
    if Guda_ApplyBackgroundTransparency then
        Guda_ApplyBackgroundTransparency()
    end

    MailboxFrame:Update()
end

-- Toggle visibility
function MailboxFrame:Toggle()
    if Guda_MailboxFrame:IsShown() then
        Guda_MailboxFrame:Hide()
    else
        Guda_MailboxFrame:Show()
    end
end

-- Show specific character's mailbox
function MailboxFrame:ShowCharacter(fullName)
    currentViewChar = fullName
    self:Update()
end

-- Initialize module
function MailboxFrame:Initialize()
    -- Register events if needed
end

-- Update the mailbox frame
function MailboxFrame:Update()
    if not Guda_MailboxFrame:IsShown() then return end

    -- Determine which character to show
    local charFullName = currentViewChar or addon.Modules.DB:GetPlayerFullName()
    local mailboxData = addon.Modules.DB:GetCharacterMailbox(charFullName)
    
    -- Extract character name from fullName
    local charName = charFullName
    local dashPos = string.find(charFullName, "-")
    if dashPos then
        charName = string.sub(charFullName, 1, dashPos - 1)
    end

    getglobal("Guda_MailboxFrame_Title"):SetText(charName .. "'s Mailbox")

    -- Filter items based on search text
    local filteredItems = {}
    for i, mail in ipairs(mailboxData) do
        local matchesSearch = true
        if searchText ~= "" then
            matchesSearch = false
            if mail.sender and string.find(string.lower(mail.sender), searchText) then
                matchesSearch = true
            elseif mail.subject and string.find(string.lower(mail.subject), searchText) then
                matchesSearch = true
            elseif mail.item and mail.item.name and string.find(string.lower(mail.item.name), searchText) then
                matchesSearch = true
            end
        end

        if matchesSearch then
            table.insert(filteredItems, mail)
        end
    end

    -- Display items
    self:DisplayItems(filteredItems, charFullName)

    -- Update footer info
    local totalItems = table.getn(mailboxData)
    local displayedItems = table.getn(filteredItems)
    local footerText = string.format("Items: %d", totalItems)
    if searchText ~= "" then
        footerText = string.format("Filtered: %d / %d", displayedItems, totalItems)
    end
    getglobal("Guda_MailboxFrame_Footer_Text"):SetText(footerText)

    -- Update money (total money in mailbox)
    local totalMoney = 0
    for _, mail in ipairs(mailboxData) do
        totalMoney = totalMoney + (mail.money or 0)
    end
    MoneyFrame_Update("Guda_MailboxFrame_MoneyFrame", totalMoney)
end

-- Display mailbox items in a grid
function MailboxFrame:DisplayItems(items, charFullName)
    local container = getglobal("Guda_MailboxFrame_ItemContainer")
    -- Explicitly set container ID to -100 to avoid being picked up as a bag
    if container.SetID then container:SetID(-100) end
    
    local columns = 10
    local buttonSize = 34
    local spacing = 2
    
    -- Hide all existing buttons first
    for _, button in pairs(itemButtons) do
        button:Hide()
        button.inUse = false
    end

    local row = 0
    local col = 0
    
    for i, mail in ipairs(items) do
        local button = itemButtons[i]
        if not button then
            button = Guda_GetItemButton(container)
            itemButtons[i] = button
        end

        -- Consistently set button size for the mailbox grid
        button:SetWidth(buttonSize)
        button:SetHeight(buttonSize)

        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", container, "TOPLEFT", col * (buttonSize + spacing), -row * (buttonSize + spacing))
        
        -- Set button data
        button.isBank = false
        button.otherChar = charFullName
        button.isMail = true -- Custom flag for mailbox items
        button.inUse = true
        
        if mail.item and (mail.item.texture or mail.item.link) then
            Guda_ItemButton_SetItem(button, nil, nil, mail.item, false, charFullName, true, true)
            -- Re-enforce size because SetItem overrides it with global settings
            button:SetWidth(buttonSize)
            button:SetHeight(buttonSize)
            button.isMail = true -- Re-apply after SetItem clears it
        else
            -- Use SetItem with nil itemData to clear the button properly first
            Guda_ItemButton_SetItem(button, nil, nil, nil, false, charFullName, true, true)
            button:SetWidth(buttonSize)
            button:SetHeight(buttonSize)
            button.isMail = true -- Re-apply after SetItem clears it

            -- Then show our custom icon for money/mail
            button.itemData = nil
            local icon = getglobal(button:GetName().."IconTexture") or getglobal(button:GetName().."Icon")
            if icon then
                if (mail.money or 0) > 0 then
                    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
                elseif mail.packageIcon then
                    icon:SetTexture(mail.packageIcon)
                else
                    icon:SetTexture("Interface\\Icons\\INV_Letter_15")
                end
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                icon:Show()
            end
            
            if button.qualityBorder then button.qualityBorder:Hide() end
        end

        -- Custom Tooltip for mail items
        button.mailData = mail -- Store data on button to avoid closure issues in Lua 5.0
        button.isMail = true -- Redundant set to be safe
        button:SetScript("OnEnter", function()
            -- Force detachment from Blizzard logic inside the closure as well
            if this.SetID then this:SetID(0) end
            this.isMail = true
            
            local mailData = this.mailData
            if not mailData then return end

            -- Explicitly use GameTooltip:ClearLines() and SetOwner to ensure a clean tooltip
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()

            if mailData.item and mailData.item.link then
                GameTooltip:SetHyperlink(mailData.item.link)
                -- Add a gap if there's also sender/subject info to show
                GameTooltip:AddLine(" ")
            elseif mailData.item and mailData.item.name then
                -- Fallback if we have item data but no link (e.g. not in cache yet)
                GameTooltip:AddLine(mailData.item.name, 1, 1, 1)
                GameTooltip:AddLine(" ")
            end
            
            GameTooltip:AddLine("From: " .. (mailData.sender or "Unknown"), 1, 1, 1)
            GameTooltip:AddLine("Subject: " .. (mailData.subject or "No Subject"), 1, 1, 0.8)
            
            if (mailData.money or 0) > 0 then
                GameTooltip:AddLine("Money: " .. addon.Modules.Utils:FormatMoney(mailData.money), 1, 1, 1)
            end
            if (mailData.CODAmount or 0) > 0 then
                GameTooltip:AddLine("COD: " .. addon.Modules.Utils:FormatMoney(mailData.CODAmount), 1, 0, 0)
            end
            
            if mailData.daysLeft then
                GameTooltip:AddLine("Days left: " .. math.floor(mailData.daysLeft), 0.5, 0.5, 0.5)
            end
            
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Mailbox is read-only, so no clicking/dragging
        button:RegisterForClicks()
        button:SetScript("OnClick", nil)
        button:SetScript("OnDragStart", nil)
        button:SetScript("OnReceiveDrag", nil)

        button:Show()

        col = col + 1
        if col >= columns then
            col = 0
            row = row + 1
        end
    end

    -- Adjust container height
    local totalRows = row + (col > 0 and 1 or 0)
    container:SetHeight(math.max(420, totalRows * (buttonSize + spacing)))
end

-- Search text changed
function Guda_MailboxFrame_OnSearchTextChanged()
    local searchBox = getglobal("Guda_MailboxFrame_SearchBar_SearchBox")
    local text = searchBox:GetText()
    if text == "Search mailbox..." then
        searchText = ""
    else
        searchText = string.lower(text)
    end
    MailboxFrame:Update()
end

-- Show character selection menu
function Guda_MailboxFrame_ShowCharacterMenu()
    local characters = addon.Modules.DB:GetAllCharacters(true, true)
    local menu = {}
    
    for i, char in ipairs(characters) do
        local charFullName = char.fullName
        table.insert(menu, {
            text = char.name,
            func = function() MailboxFrame:ShowCharacter(charFullName) end,
            checked = (currentViewChar == char.fullName or (not currentViewChar and char.fullName == addon.Modules.DB:GetPlayerFullName()))
        })
    end
    
    -- EasyMenu is available in 1.12.1
    local menuFrame = CreateFrame("Frame", "Guda_MailboxCharacterMenu", UIParent, "UIDropDownMenuTemplate")
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
end
