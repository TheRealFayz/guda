# Guda

A comprehensive **bag and bank management addon** for **World of Warcraft 1.12.1**, fully compatible with **Turtle WoW**.

Guda provides a modern, unified bag/bank experience with multi-character support, sorting, item tracking, and quality-of-life tools.

---

## 📦 Features

### 🎒 Bag Management

- **Unified Bag View** – All bags displayed in one window
- **Category View** – Group items by category for easier organization
- **Smart Sorting** – Sort by quality, name, or item type
- **Search Box** – Quickly find items
- **Quality Borders** – Items are visually color-coded based on rarity

### 🏦 Bank Management

- **Remote Bank Viewing** – View cached bank contents from anywhere
- **One-Click Sorting** – Organize your bank easily
- **Category View** – Group bank items by category
- **Persistent Storage** – Bank data saved between sessions

### 📊 Tracked Item Bar

- **Item Tracking** – Alt + Left-Click on any bag item to track it
- **Stack Display** – Shows tracked items as a single stack with total count
- **Farm Counter** – Displays how many items you currently have in your bags
- **Grinding Helper** – Perfect for tracking materials while farming
- **Draggable** – Shift + Left-Click to drag the bar anywhere on screen

### 📜 Quest Item Bar

- **Quest Item Display** – Shows usable quest items in up to 2 dedicated bars
- **Quick Swap** – Hover over a quest item bar slot to see available quest items
- **One-Click Replace** – Click on a popup item to swap it into the bar slot
- **Keybindable** – Set custom keybindings for quick quest item use
- **Draggable** – Shift + Left-Click to drag the bar anywhere on screen

### 👥 Multi-Character Support

- **Cross-Character Viewing** – View bags & banks of any character
- **Money Tracking** – See total gold across all characters
- **Character Selector** – Switch characters quickly
- **Faction Filtering** – Shows only characters from the same faction
- **Global Item Counting** – Item totals across all characters, including:
    - Bags
    - Banks
    - Equipped items
    - Tooltip breakdown per character

### 💰 Money Display

- **Current Character Money**
- **Total Money Across All Characters**
- **Per-Character Overview** in the selector

---

## 📝 Slash Commands

| Command | Description |
|---------|-------------|
| `/guda` or `/gn` | Toggle bags |
| `/guda bank` | Toggle bank view |
| `/guda sort` | Sort your bags |
| `/guda sortbank` | Sort your bank (must be at bank) |
| `/guda debug` | Toggle debug mode |
| `/guda cleanup` | Remove characters not seen in 90 days |
| `/guda help` | Show help |

---

## 🚀 How to Use

### Basic Usage

1. Press **B** or type `/guda` to open your bags
2. Click **Characters** to switch characters
3. Click **Bank** to view your cached bank
4. Click **Sort** to organize your bags

### Sorting

- **Sort Bags**: Press **Sort** or use `/guda sort`
- **Sort Bank**: Use **Sort Bank** or `/guda sortbank`
- Sorting modes:
    - **Quality** (Epic → Rare → Uncommon → Common)
    - **Name** (A → Z)
    - **Type** (Item class & subclass)

### Category View

- Toggle category view in bags or bank to group items by type
- Easily find items organized by their category

### Tracked Item Bar

1. Open your bags
2. Hold **Alt** and **Left-Click** on any item to start tracking it
3. The item appears in the Tracked Item Bar with total count
4. Use **Shift + Left-Click** on the bar to drag it to your preferred location

![Tracked Item Bar](https://i.imgur.com/tISDLwo.png)

### Quest Item Bar

1. Quest items automatically appear in the Quest Item Bar
2. Set keybindings via **Esc → Key Bindings → Guda** for quick use
3. Hover over a bar slot to see other available quest items
4. Click a popup item to swap it into that slot
5. Use **Shift + Left-Click** on the bar to drag it to your preferred location

![Quest Item Bar](https://i.imgur.com/orMsS06.png)
---

## 🧠 Internal Systems

### 🔍 Bag Scanner

- Scans all bags at login
- Updates when looting, moving, or modifying items
- Stores item details (count, quality, name, link, etc.)

### 🏦 Bank Scanner

- Scans on bank open
- Saves snapshot for offline viewing
- Updates live while the bank is open

### 💰 Money Tracker

- Tracks money changes in real time
- Displays per-character, current character, and total money

### 🗄️ Data Storage

| Variable | Description |
|----------|-------------|
| `Guda_DB` | Global data: bag & bank contents, character money, timestamps, tracked items |
| `Guda_CharDB` | Per-character UI settings: bar positions, tracked item selections |

---


## ⚠️ Known Limitations

| Area | Limitation |
|------|------------|
| Sorting | Advanced sorting requires handling bag restrictions (soul bags, profession bags). Locked and soulbound items need special handling. |
| Bank Access | Must open the bank at least once to cache contents |
| Faction Restriction | Only shows characters from the same faction |

---

## 🖼️ Screenshots

| Guda Settings | Bag Single View                          | Bag Category View                  | Bank View                                    |
|---------------|------------------------------------------|------------------------------------|----------------------------------------------|
| ![Settings](https://i.imgur.com/h6XrtxM.png) | ![Bags](https://i.imgur.com/00iOF0I.png) | ![Category](https://i.imgur.com/khywIwv.png) | ![Bank](https://i.imgur.com/rV1f8Lu.png)     |

---

## 🐞 Common Issues

### Cannot open bags using B

Set the keybinding: **Esc → Key Bindings → Guda → Toggle Bags**

![Keybindings Fix](https://i.imgur.com/IJv36Lg.png)

### Issues after updating the addon

Delete outdated saved variables:

```
WTF/Account/<ACCOUNT_NAME>/SavedVariables/Guda.lua
WTF/Account/<ACCOUNT_NAME>/SavedVariables/Guda.lua.bak
```

---

## 📢 Support

For bugs or feature requests, please open an issue. Your feedback helps improve the addon!
