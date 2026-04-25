---- [ GAME LOADER ] ----

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