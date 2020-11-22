local _, TIC = ...

TIC:RegisterEvent("MAIL_SHOW")
TIC:RegisterEvent("MAIL_CLOSED")
TIC:RegisterEvent("MAIL_INBOX_UPDATE")

local function GetMailItems(bag)
    local tempItemArray = {}

    for msgIndex = 1, GetInboxNumItems() do
        local _, _, _, _, _, _, _, numItems = GetInboxHeaderInfo(msgIndex);
        for itemIndex = 1, ATTACHMENTS_MAX_RECEIVE do
            local name, itemId, icon, count, quality =
                GetInboxItem(msgIndex, itemIndex)

            if itemId then
                if not tempItemArray[itemId] then
                    tempItemArray[itemId] = {}
                    tempItemArray[itemId][1] = count
                    tempItemArray[itemId][2] = name
                    tempItemArray[itemId][3] = "|T" .. icon .. ":0|t"
                    tempItemArray[itemId][4] = quality
                else
                    tempItemArray[itemId][1] = tempItemArray[itemId][1] + count
                end
            end
        end
    end

    TIC:Save(tempItemArray, "mail")
end

local updateRequired

function TIC:MAIL_CLOSED() GetMailItems() end

function TIC:MAIL_SHOW() GetMailItems() end

function TIC:MAIL_INBOX_UPDATE() GetMailItems() end
