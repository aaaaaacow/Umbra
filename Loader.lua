local Base = "https://raw.githubusercontent.com/aaaaaacow/Umbra/main/"

local Umbra = loadstring(game:HttpGet(Base .. "UmbraUI.lua", true))()

local Env = (getgenv and getgenv()) or _G
Env.Umbra = Umbra

loadstring(game:HttpGet(Base .. "Example.lua", true))()
