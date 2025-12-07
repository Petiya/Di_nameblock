------------------------------------------
-- Di_nameblock - Full server.lua
------------------------------------------

-- Load Config
Config = Config or {}

local function Debug(msg)
    if Config.Debug then
        print("^5[Di_nameblock DEBUG]^7 " .. msg)
    end
end



-- Print banner on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local green = "\27[32m"
    local blue = "\27[34m"
    local reset = "\27[0m"

    print(green.."DDDDDDDDDDDDD             IIIIIIIIII                    AAA                       SSSSSSSSSSSSSSS "..reset)
    print(blue.."D::::::::::::DDD          I::::::::I                   A:::A                    SS:::::::::::::::S"..reset)
    print(green.."D:::::::::::::::DD        I::::::::I                  A:::::A                  S:::::SSSSSS::::::S"..reset)
    print(blue.."DDD:::::DDDDD:::::D       II::::::II                 A:::::::A                 S:::::S     SSSSSSS"..reset)
    print(green.."  D:::::D    D:::::D        I::::I                  A:::::::::A                S:::::S            "..reset)
    print(blue.."  D:::::D     D:::::D       I::::I                 A:::::A:::::A               S:::::S            "..reset)
    print(green.."  D:::::D     D:::::D       I::::I                A:::::A A:::::A               S::::SSSS         "..reset)
    print(blue.."  D:::::D     D:::::D       I::::I               A:::::A   A:::::A               SS::::::SSSSS    "..reset)
    print(green.."  D:::::D     D:::::D       I::::I              A:::::A     A:::::A                SSS::::::::SS  "..reset)
    print(blue.."  D:::::D     D:::::D       I::::I             A:::::AAAAAAAAA:::::A                  SSSSSS::::S "..reset)
    print(green.."  D:::::D     D:::::D       I::::I            A:::::::::::::::::::::A                      S:::::S"..reset)
    print(blue.."  D:::::D    D:::::D        I::::I           A:::::AAAAAAAAAAAAA:::::A                     S:::::S"..reset)
    print(green.."DDD:::::DDDDD:::::D       II::::::II        A:::::A             A:::::A        SSSSSSS     S:::::S"..reset)
    print(blue.."D:::::::::::::::DD        I::::::::I       A:::::A               A:::::A       S::::::SSSSSS:::::S"..reset)
    print(green.."D::::::::::::DDD          I::::::::I      A:::::A                 A:::::A      S:::::::::::::::SS "..reset)
    print(blue.."DDDDDDDDDDDDD             IIIIIIIIII     AAAAAAA                   AAAAAAA      SSSSSSSSSSSSSSS   "..reset)
end)



------------------------------------------
-- QBCORE AUTO-DETECT
------------------------------------------
local QBCore = nil

local function tryGetCore(name)
    local ok, core = pcall(function()
        return exports[name]:GetCoreObject()
    end)
    if ok and core then
        print("[Di_nameblock] Found QBCore via: " .. name)
        return core
    end
    return nil
end

if Config.CoreName and Config.CoreName ~= "" then
    QBCore = tryGetCore(Config.CoreName)
end

QBCore = QBCore
    or tryGetCore('qbx-core')
    or tryGetCore('qb-core')
    or tryGetCore('qb-core-old')

if not QBCore then
    print("[Di_nameblock ERROR] Could NOT find QBCore exports!")
    QBCore = { Functions = { GetPlayer = function() return nil end } }
end

------------------------------------------
-- Name Validation Function
------------------------------------------
local function NameAllowed(name)
    if not name or name == "" then
        return false, "Name is empty"
    end

    if not string.match(name, Config.AllowedPattern) then
        return false, "Name contains invalid characters."
    end

    for _, banned in ipairs(Config.BannedNames) do
        if string.find(string.lower(name), string.lower(banned)) then
            return false, "Name contains a banned word: " .. banned
        end
    end

    return true, ""
end

------------------------------------------
-- Discord Logging
------------------------------------------
local function SendDiscordLog(title, description, color)
    if not Config.Webhook or Config.Webhook == "" then
        Debug("No Discord webhook set, skipping log.")
        return
    end

    local embed = {{
        ["title"] = title,
        ["description"] = description,
        ["color"] = color or 16711680,
        ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") }
    }}

    PerformHttpRequest(
        Config.Webhook,
        function() end,
        "POST",
        json.encode({ embeds = embed }),
        { ["Content-Type"] = "application/json" }
    )
end

------------------------------------------
-- 1. FiveM Name Check (Before Join)
------------------------------------------
AddEventHandler("playerConnecting", function(fivemName, setKickReason, deferrals)
    deferrals.defer()
    Wait(0)

    Debug("Checking FiveM name: " .. fivemName)

    local allowed, reason = NameAllowed(fivemName)
    if not allowed then
        SendDiscordLog(
            "Player Kicked - FiveM Name Invalid",
            "**FiveM Name:** " .. fivemName .. "\n**Reason:** " .. reason,
            16711680 -- red
        )
        deferrals.done("Kicked: Invalid FiveM Name\nReason: " .. reason)
        return
    end

    deferrals.done()
end)

------------------------------------------
-- 2. Character Name Check (After Join)
------------------------------------------
RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function()
    local src = source
    Debug("PlayerLoaded event fired for: " .. tostring(src))

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        Debug("Failed to get Player object for src " .. tostring(src))
        return
    end

    local char = Player.PlayerData.charinfo
    if not char then
        Debug("No charinfo for src " .. tostring(src))
        return
    end

    local fullCharName = (char.firstname .. " " .. char.lastname)
    local fivemName = GetPlayerName(src)

    Debug("FiveM Name: " .. fivemName .. " | Character Name: " .. fullCharName)

    -- Check allowed pattern & banned words on character name too
    local allowedChar, reasonChar = NameAllowed(fullCharName)
    if not allowedChar then
        SendDiscordLog(
            "Player Kicked - Character Name Invalid",
            "**FiveM Name:** " .. fivemName ..
            "\n**Character Name:** " .. fullCharName ..
            "\n**Reason:** " .. reasonChar,
            16753920 -- orange
        )
        DropPlayer(src, "Invalid Character Name\nReason: " .. reasonChar)
        return
    end

    -- Check if FiveM name matches character name
    if fivemName ~= fullCharName then
        SendDiscordLog(
            "Player Kicked - Name Mismatch",
            "**FiveM Name:** " .. fivemName ..
            "\n**Character Name:** " .. fullCharName ..
            "\n**Reason:** Names do not match",
            16711680 -- red
        )
        DropPlayer(src, "Kicked: Your FiveM name does not match your character name.")
        return
    end

    -- Name matches → send confirmation
    SendDiscordLog(
        "Player Name Confirmed ✔️",
        "**FiveM Name:** " .. fivemName ..
        "\n**Character Name:** " .. fullCharName ..
        "\n**Status:** Name match ✔️",
        65280 -- green
    )
    Debug("Names match for src " .. tostring(src))
end)
