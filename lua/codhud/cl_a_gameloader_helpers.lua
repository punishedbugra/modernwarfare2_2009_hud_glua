---- [ GAME LOADER & GLOBAL CLIENT HELPERS ] ----

-- Automatically add all files to client and server
local path = "codhud/games/"
local files = file.Find(path .. "*.lua", "LUA")

table.sort(files)

for _, f in ipairs(files) do
    AddCSLuaFile(path .. f)
    if CLIENT then
        include(path .. f)
    end
end

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

function CoDHUD_GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

function CoDHUD_S(x)  return math.Round(x * CoDHUD_GetUIScale()) end
function CoDHUD_SX(x) return math.Round(x * CoDHUD_GetUIScale()) end
function CoDHUD_SY(y) return math.Round(y * CoDHUD_GetUIScale()) end


function CoDHUD_GetHUDType()
    local c = GetConVar("codhud_game")
    return c and c:GetString() or "mw2"
end
