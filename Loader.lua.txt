local Base = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/"

local Umbra = loadstring(game:HttpGet(Base .. "UmbraUI.lua", true))()

local Env = (getgenv and getgenv()) or _G
Env.Umbra = Umbra

loadstring(game:HttpGet(Base .. "Example.lua", true))()
