local addonName, TIC = ...
local L = TIC.L

-------------------------------------------
-- event frame
-------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function TIC:RegisterEvent(event)
    frame:RegisterEvent(event)
end

function TIC:UnregisterEvent(event)
    frame:UnregisterEvent(event)
end

-------------------------------------------
-- events
-------------------------------------------
function TIC:ADDON_LOADED(arg1)
    if arg1 == "TooltipItemCount" then
        if type(TIC_DB) ~= "table" then TIC_DB = {} end
    end
end

function TIC:PLAYER_ENTERING_WORLD()
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    TIC.name, TIC.realm = UnitFullName("player")
    TIC.faction = UnitFactionGroup("player")

    -- init
    if type(TIC_DB[TIC.realm]) ~= "table" then TIC_DB[TIC.realm] = {} end
    if type(TIC_DB[TIC.realm][TIC.name]) ~= "table" then TIC_DB[TIC.realm][TIC.name] = {
        ["faction"] = TIC.faction,
        ["class"] = select(2, UnitClass("player")),
        ["bags"] = {},
        ["bank"] = {},
        ["equipped"] = {},
    } end
end

frame:SetScript("OnEvent", function(self, event, ...)
    TIC[event](TIC, ...)
end)

-------------------------------------------
-- functions
-------------------------------------------
-- save to SavedVariables
function TIC:Save(temp, category)
    TIC_DB[TIC.realm][TIC.name][category] = temp
end

local function ColorByClass(class, str)
    return "|c" .. RAID_CLASS_COLORS[class].colorStr .. str .. "|r"
end

-- prepare tooltip text on each character
local function CountOnCharacter(name, id)
    local equipped, bags, bank = 0, 0, 0
    local result = {}

    -- equipped
    if TIC_DB[TIC.realm][name]["equipped"][id] then
        bank = TIC_DB[TIC.realm][name]["equipped"][id][1]
        table.insert(result, L["Equipped"] .. ": " .. bank)
    end
    -- bags
    if TIC_DB[TIC.realm][name]["bags"][id] then
        bags = TIC_DB[TIC.realm][name]["bags"][id][1]
        table.insert(result, L["Bags"] .. ": " .. bags)
    end
    -- bank
    if TIC_DB[TIC.realm][name]["bank"][id] then
        bank = TIC_DB[TIC.realm][name]["bank"][id][1]
        table.insert(result, L["Bank"] .. ": " .. bank)
    end
    
    if equipped + bags + bank > 0 then
        local class = TIC_DB[TIC.realm][name]["class"]
        local cname = ColorByClass(class, name)
        if #result == 1 then
            return cname, ColorByClass(class, result[1])
        else
            return cname, ColorByClass(class, equipped + bags + bank).." |cFFBBBBBB("..table.concat(result, ", ")..")"
        end
    end
end

-- count by id
function TIC:Count(id)
    local result = {}
    -- search in current realm and same faction
    for name, t in pairs(TIC_DB[TIC.realm]) do
        if t["faction"] == TIC.faction then
            local text1, text2 = CountOnCharacter(name, id)
            if text1 and text2 then
                table.insert(result, {text1, text2})
            end
        end
    end
    return result
end

-------------------------------------------
-- slash
-------------------------------------------
local tic = "|cFF00CCFFTooltipItemCount|r "
SLASH_TOOLTIPITEMCOUNT1 = "/tic"
function SlashCmdList.TOOLTIPITEMCOUNT(msg, editbox)
    -- TODO: frame: search, delete
end