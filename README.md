Di_NameBlock – FiveM Name Verification System

Di_NameBlock is a FiveM server-side security script that verifies player identity by matching their FiveM profile name with their in-game character name. It also checks for invalid characters, banned words, and logs all actions to Discord.

Useful for roleplay servers that want to maintain professionalism and prevent troll or fake names.

✨ Features

✔ Validates FiveM name during player connecting

✔ Validates character full name after character load

✔ Automatically kicks players if names do not match

✔ Blocks special characters, numbers, and banned words

✔ Sends Discord webhook logs for:

Kicks

Invalid names

Successful matches

✔ Easy-to-edit config.lua

✔ Works with QBCore, qbx-core, and auto-detects core export

✔ Supports Tebex asset escrow (if used)

🛠️ Installation

Drag the folder Di_NameBlock into your server’s resources directory.

Check your config.lua settings.

Add this to your server.cfg:

ensure Di_NameBlock


Restart the server.

⚙️ Configuration (config.lua)
Config = {}

-- Enable or disable debug logs in console
Config.Debug = true

-- Block these words from names
Config.BannedNames = {
    "test",
    "admin",
    "staff",
    "owner",
}

-- Allow only letters and spaces
Config.AllowedPattern = "^[A-Za-z%s]+$"

-- Discord webhook for logging actions
Config.Webhook = "https://discord.com/api/webhooks/XXXX/YYYY"

🚫 Kick Reasons

Players may be kicked for:

❌ FiveM name contains special characters

❌ Character name contains banned words

❌ FiveM name does not match character name

❌ Name contains invalid formatting

Kick message includes the reason.

📩 Discord Logging

Every event is logged to Discord:

🟥 Invalid FiveM name (kicked)

🟧 Invalid character name (kicked)

🟥 Name mismatch (kicked)

🟩 Valid name + successful match

Great for staff monitoring.
