Config = {}

-- Debug prints to server console
Config.Debug = true

Config.BannedNames = {
    "test",
    "admin",
    "staff",
    "owner",
}

-- Only letters + spaces
Config.AllowedPattern = "^[A-Za-z%s]+$"

-- Your Discord webhook here (optional)
Config.Webhook = "https://discord.com/api/webhooks/****"
