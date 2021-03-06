local addonName, TIC = ...
local L = TIC.L

-------------------------------------------
-- event frame
-------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function TIC:RegisterEvent(event) frame:RegisterEvent(event) end

function TIC:UnregisterEvent(event) frame:UnregisterEvent(event) end

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
    if type(TIC_DB[TIC.realm][TIC.name]) ~= "table" then
        TIC_DB[TIC.realm][TIC.name] = {
            ["faction"] = TIC.faction,
            ["class"] = select(2, UnitClass("player")),
            ["bags"] = {},
            ["bank"] = {},
            ["mail"] = {}
        }
    end
end

frame:SetScript("OnEvent", function(self, event, ...) TIC[event](TIC, ...) end)

-------------------------------------------
-- functions
-------------------------------------------
-- save to SavedVariables
function TIC:Save(temp, category) TIC_DB[TIC.realm][TIC.name][category] = temp end

local function ColorByClass(class, str)
    return "|c" .. RAID_CLASS_COLORS[class].colorStr .. str .. "|r"
end

-- prepare tooltip text on each character
local function CountOnCharacter(name, id)
    local bags, bank, mail = 0, 0, 0
    local result = {}

    -- bags
    if TIC_DB[TIC.realm][name]["bags"][id] then
        bags = TIC_DB[TIC.realm][name]["bags"][id][1]
        table.insert(result, "|cFFBBBBBB" .. L["Bags"] .. ":|cFFFFFFFF " .. bags)
    end
    -- bank
    if TIC_DB[TIC.realm][name]["bank"][id] then
        bank = TIC_DB[TIC.realm][name]["bank"][id][1]
        table.insert(result, "|cFFBBBBBB" .. L["Bank"] .. ":|cFFFFFFFF " .. bank)
    end
    -- mail
    if TIC_DB[TIC.realm][name]["mail"][id] then
        mail = TIC_DB[TIC.realm][name]["mail"][id][1]
        table.insert(result, "|cFFBBBBBB" .. L["Mail"] .. ":|cFFFFFFFF " .. mail)
    end

    if bags + bank + mail > 0 then
        local class = TIC_DB[TIC.realm][name]["class"]
        local cname = ColorByClass(class, name)
        if #result == 1 then
            return cname, "|cFFFFFFFF" .. result[1]
        else
            return cname,
                   "|cFFFFFFFF" .. bags + bank + mail .. "|cFFBBBBBB (" ..
                       table.concat(result, "|cFFFFFFFF, ") .. "|cFFBBBBBB)"
        end
    end
end

local function CountOnCurrentCharacter(id)
    local bags = GetItemCount(id)
    local bank = GetItemCount(id, true) - bags
    local mail = TIC:GetMailItemCount(id)
    local result = {}

    -- bags
    if bags > 0 then
        table.insert(result, "|cFFBBBBBB" .. L["Bags"] .. ":|cFFFFFFFF " .. bags)
    end
    -- update db bags -- FIXME: absolutely the same IN THEORY
    -- if TIC_DB[TIC.realm][TIC.name]["bags"][id] then
    --     if bags ~= TIC_DB[TIC.realm][TIC.name]["bags"][id][1] then
    --         if bags > 0 then
    --             TIC_DB[TIC.realm][TIC.name]["bags"][id][1] = bags
    --         else
    --             TIC_DB[TIC.realm][TIC.name]["bags"][id] = nil
    --         end
    --     end
    -- end

    -- banks
    if bank > 0 then
        table.insert(result, "|cFFBBBBBB" .. L["Bank"] .. ":|cFFFFFFFF " .. bank)
    end

    -- mails
    if mail > 0 then
        table.insert(result, "|cFFBBBBBB" .. L["Mail"] .. ":|cFFFFFFFF " .. mail)
    end

    -- update db bank
    if TIC_DB[TIC.realm][TIC.name]["bank"][id] then
        if bank ~= TIC_DB[TIC.realm][TIC.name]["bank"][id][1] then
            if bank > 0 then
                TIC_DB[TIC.realm][TIC.name]["bank"][id][1] = bank
            else
                TIC_DB[TIC.realm][TIC.name]["bank"][id] = nil
            end
        end
    end

    if bags + bank + mail > 0 then
        local class = TIC_DB[TIC.realm][TIC.name]["class"]
        local cname = ColorByClass(class, TIC.name)
        if #result == 1 then
            return cname, "|cFFFFFFFF" .. result[1]
        else
            return cname,
                   "|cFFFFFFFF" .. bags + bank + mail .. "|cFFBBBBBB (" ..
                       table.concat(result, "|cFFFFFFFF, ") .. "|cFFBBBBBB)"
        end
    end
end

-- count by id
function TIC:Count(id)
    local result = {}
    -- search in current realm and same faction
    for name, t in pairs(TIC_DB[TIC.realm]) do
        -- not current character, just count in db
        if name ~= TIC.name and t["faction"] == TIC.faction then
            local text1, text2 = CountOnCharacter(name, id)
            if text1 and text2 then
                table.insert(result, {text1, text2})
            end
        end
    end
    -- add current character
    local text1, text2 = CountOnCurrentCharacter(id)
    if text1 and text2 then table.insert(result, {text1, text2}) end
    return result
end

-- count items in mail by id
function TIC:GetMailItemCount(id)
    local item = TIC_DB[TIC.realm][TIC.name]["mail"][id];

    return item and item[1] or 0
end

-------------------------------------------
-- slash
-------------------------------------------
local tic = "|cFF00CCFFTooltipItemCount|r "
SLASH_TOOLTIPITEMCOUNT1 = "/tic"
function SlashCmdList.TOOLTIPITEMCOUNT(msg, editbox)
    -- TODO: frame: search, delete
end
