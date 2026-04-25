-- [[ cl_mw2_killfeed.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x) return math.Round(x * GetUIScale()) end

-- DONT TOUCH THESE, dude these are fragile as FUCK, keep it as they are, if you really want to tinker with them create a backup file
local CFG = {
    X_POS = 10,
    Y_POS = 210,
    SPACING = 26, 
    MAX_MESSAGES = 6,
    LIFETIME = 8,

    -- 1. CUSTOM ICONS (Headshot, Suicide, Blast, Fall, etc.)
    ICON_W       = 36,  
    ICON_H       = 36,  
    ICON_ALPHA   = 165,
    ICON_X_MOD   = 25,   -- Manual shift for custom icons
    ICON_Y_MOD   = -3,   -- Manual shift for custom icons

    -- 2. WEAPON ICONS (Standard Killicons)
    WEP_ICON_ALPHA = 165,
    WEP_ICON_X_MOD = 50,
    WEP_ICON_Y_MOD = 10,

    -- GAP TINKERING
    GAP_LARGE_L = 5,
    GAP_LARGE_R = 5,
    GAP_SMALL_L = -10, 
    GAP_SMALL_R = 40,
    SMALL_ICON_THRESHOLD = 52, 

    TEXT_ALPHA = 155,
    FONT_SIZE = 30,
    
    -- Animation Settings
    ANIM_TIME = 0.25, 
    ANIM_RISE = 15,   
}

-- [[ FONT ]]
local function MW2_InitKillfeedFont()
    surface.CreateFont("MW2_KillfeedFont", {
        font = "Conduit ITC",
        size = S(CFG.FONT_SIZE),
        weight = 400,
        antialias = true,
        shadow = true,
        outline = false,
    })
end

MW2_InitKillfeedFont()

hook.Add("OnScreenSizeChanged", "MW2_ReinitKillfeedFont", function()
    MW2_InitKillfeedFont()
end)

local KillFeed = {}

-- [[ COLORS & FACTION MAPPING ]]
local COL_WEST  = Color(100, 110, 120) 
local COL_EAST  = Color(120, 110, 100)
local COL_WHITE = Color(255, 255, 255)

local function GetFactionColor(ent)
    if not IsValid(ent) then return COL_WHITE end
    local faction = ent:GetNW2String("MW2_Faction", "none")
    local axis = { ["arab"] = true, ["ussr"] = true, ["militia"] = true }
    local allies = { ["rangers"] = true, ["taskforce141"] = true, ["seals"] = true }

    if axis[faction] then return COL_EAST end
    if allies[faction] then return COL_WEST end
    return COL_WHITE
end

-- [[ SPECIAL ICONS REGISTRATION ]]
local CustomIconMats = {
    ["MW2_Suicide"]  = Material("killfeed/death_suicide.png", "smooth"),
    ["MW2_Headshot"] = Material("killfeed/death_headshot.png", "smooth"),
    ["MW2_Blast"]    = Material("killfeed/death_explosion.png", "smooth"),
    ["MW2_Fall"]     = Material("killfeed/death_falling.png", "smooth"),
    ["MW2_Crush"]    = Material("killfeed/death_crush.png", "smooth"),
    ["MW2_Impale"]   = Material("killfeed/death_impale.png", "smooth")
}

-- Registry for GMod's system
for k, _ in pairs(CustomIconMats) do
    killicon.Add(k, "killfeed/" .. string.lower(string.Replace(k, "MW2_", "death_")) .. ".png", Color(255, 255, 255, 0))
end

-- no default hud
hook.Add("HUDShouldDraw", "MW2_Killfeed_HideDefault", function(name)
    if name == "CHudDeathNotice" then return false end
end)

hook.Add("DrawDeathNotice", "MW2_Killfeed_ForceSuppression", function()
    return false
end)

-- [[ NETWORKING ]]
net.Receive("MW2_Killfeed_Death", function()
    local ct = CurTime()
    local vEnt = net.ReadEntity()
    local aEnt = net.ReadEntity()
    local weaponClass = net.ReadString()

    local isHeadshot = (weaponClass == "MW2_Headshot")

    local attackerName = "World"
    if IsValid(aEnt) then
        if aEnt:IsPlayer() then attackerName = aEnt:Nick()
        elseif aEnt:IsNPC() then attackerName = language.GetPhrase(aEnt:GetClass()) or aEnt:GetClass()
        else attackerName = aEnt:GetClass() end
    end

    local victimName = "Unknown"
    if IsValid(vEnt) then
        if vEnt:IsPlayer() then victimName = vEnt:Nick()
        elseif vEnt:IsNPC() then victimName = language.GetPhrase(vEnt:GetClass()) or vEnt:GetClass()
        else victimName = vEnt:GetClass() end
    end

    if aEnt == vEnt or not IsValid(aEnt) or aEnt:IsWorld() then
        attackerName = ""
    end

    table.insert(KillFeed, {
        type = "kill",
        attackerName = attackerName,
        victimName   = victimName,
        attackerEnt  = aEnt,
        victimEnt    = vEnt,
        weaponClass  = weaponClass,
        spawnTime    = ct,
        dieTime      = ct + CFG.LIFETIME,
        isHeadshot   = isHeadshot
    })

    if #KillFeed > CFG.MAX_MESSAGES then table.remove(KillFeed, 1) end
end)

net.Receive("MW2_Killfeed_MetaEvent", function()
    local name = net.ReadString()
    local isConnect = net.ReadBool()
    local text = string.format(isConnect and "%s Connected" or "%s left the game", name)

    table.insert(KillFeed, {
        type = "meta",
        text = text,
        spawnTime = CurTime(),
        dieTime = CurTime() + CFG.LIFETIME
    })

    if #KillFeed > CFG.MAX_MESSAGES then table.remove(KillFeed, 1) end
end)

-- [[ RENDERING ]]
hook.Add("HUDPaint", "MW2_Killfeed_Draw", function()
    if not GetConVar("mw2_enable_killfeed"):GetBool() then return end

    local ct = CurTime()
    local xPos = S(CFG.X_POS)
    local yPos = S(CFG.Y_POS)
    local spacing = S(CFG.SPACING)
    local baseY = ScrH() - yPos

    for i = #KillFeed, 1, -1 do
        local data = KillFeed[i]
        local age = ct - data.spawnTime
        local timeLeft = data.dieTime - ct

        if timeLeft <= 0 then
            table.remove(KillFeed, i)
            continue
        end

        local animProgress = math.Clamp(age / CFG.ANIM_TIME, 0, 1)
        local fadeFactor = (age < CFG.ANIM_TIME) and animProgress or math.Clamp(timeLeft, 0, 1)

        local yOffset = (1 - animProgress) * S(CFG.ANIM_RISE)
        local currentY = baseY - ((#KillFeed - i) * spacing) + yOffset

        local x = xPos
        local finalTxtAlpha = CFG.TEXT_ALPHA * fadeFactor
        surface.SetFont("MW2_KillfeedFont")

        if data.type == "kill" then
            local cls = data.weaponClass
            local customMat = CustomIconMats[cls]
            local isCustom = customMat ~= nil
            
            local w, h
            if isCustom then
                w, h = CFG.ICON_W, CFG.ICON_H
            else
                w, h = killicon.GetSize(cls)
                w, h = w or 32, h or 32
            end

            local sw, sh = S(w), S(h)

            local aColBase = GetFactionColor(data.attackerEnt)
            local vColBase = GetFactionColor(data.victimEnt)
            local aCol = Color(aColBase.r, aColBase.g, aColBase.b, finalTxtAlpha)
            local vCol = Color(vColBase.r, vColBase.g, vColBase.b, finalTxtAlpha)

            -- 1. Attacker
            if data.attackerName != "" then
                draw.SimpleText(data.attackerName, "MW2_KillfeedFont", x, currentY, aCol)
                local tw, _ = surface.GetTextSize(data.attackerName)
                x = x + tw
            end

            -- 2. Gaps
            local useSmall = sw < S(CFG.SMALL_ICON_THRESHOLD)
            local gL = useSmall and S(CFG.GAP_SMALL_L) or S(CFG.GAP_LARGE_L)
            local gR = useSmall and S(CFG.GAP_SMALL_R) or S(CFG.GAP_LARGE_R)

            -- 3. Icon Logic
            x = x + gL
            
            if isCustom then
                local drawX = x + S(CFG.ICON_X_MOD)
                local drawY = currentY + S(CFG.ICON_Y_MOD)
                surface.SetDrawColor(255, 255, 255, math.min(CFG.ICON_ALPHA * fadeFactor, 255))
                surface.SetMaterial(customMat)
                surface.DrawTexturedRect(drawX, drawY, sw, sh)
            else
                local drawX = x + S(CFG.WEP_ICON_X_MOD)
                local drawY = currentY + S(CFG.WEP_ICON_Y_MOD)
                killicon.Draw(drawX, drawY, cls, math.min(CFG.WEP_ICON_ALPHA * fadeFactor, 255))
            end

            x = x + sw + gR

            -- 4. Victim
            draw.SimpleText(data.victimName, "MW2_KillfeedFont", x, currentY, vCol)

        elseif data.type == "meta" then
            local mCol = Color(255, 255, 255, finalTxtAlpha)
            draw.SimpleText(data.text, "MW2_KillfeedFont", x, currentY, mCol)
        end
    end
end)