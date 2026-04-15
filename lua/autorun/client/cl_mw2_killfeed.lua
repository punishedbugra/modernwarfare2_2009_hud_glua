-- [[ cl_mw2_killfeed.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x) return math.Round(x * GetUIScale()) end

-- ==========================================
-- CONFIGURATION & TINKERING
-- ==========================================
local CFG = {
    X_POS = 10,
    Y_POS = 210,
    SPACING = 26,
    MAX_MESSAGES = 6,
    LIFETIME = 6,

    ICON_W = 32,
    ICON_H = 32,
    ICON_ALPHA = 165,
    ICON_OFFSET_Y = 0,

    TEXT_ALPHA = 155,

    FONT_SIZE = 34,
    
    -- Animation Settings
    ANIM_TIME = 0.25, -- How long the fade-in lasts
    ANIM_RISE = 15,   -- How many pixels it rises from below
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

-- [[ HELPER: GET DISPLAY NAME ]]
local function GetDisplayName(ent)
    if not IsValid(ent) then return "Unknown" end
    if ent:IsPlayer() then return ent:Nick() end
    
    local name = "Unknown"
    if ent.GetPrintName and ent:GetPrintName() != "" then
        name = ent:GetPrintName()
    else
        name = language.GetPhrase(ent:GetClass())
    end
    
    return name
end

-- [[ ICON LOGIC ]]
local function GetDeathIcon(dmg, weapon)
    local base = "killfeed/"
    
    -- 1. Try Weapon Class Icon first
    if IsValid(weapon) then
        local wepClass = weapon:GetClass()
        local iconPath = base .. wepClass .. ".png"
        
        -- Check if a matching weapon icon file exists
        if file.Exists("materials/" .. iconPath, "GAME") then
            return iconPath
        end
    end

    -- 2. Fallback to Damage Types (Using bit.band for accurate detection)
    if bit.band(dmg, DMG_BLAST) != 0 then return base .. "death_explosion.png" end
    if bit.band(dmg, DMG_FALL) != 0 then return base .. "death_falling.png" end
    if bit.band(dmg, DMG_CRUSH) != 0 then return base .. "death_crush.png" end
    if bit.band(dmg, DMG_PHYSGUN) != 0 then return base .. "death_impale.png" end

    -- 3. Fallback to Skull/Suicide Icon
    return base .. "death_suicide.png"
end

-- [[ SUPPRESSION OF DEFAULT HUD ]]
hook.Add("HUDShouldDraw", "MW2_Killfeed_HideDefault", function(name)
    if name == "CHudDeathNotice" then return false end
end)

hook.Add("DrawDeathNotice", "MW2_Killfeed_ForceSuppression", function()
    return false
end)

-- [[ NETWORKING ]]
net.Receive("MW2_Killfeed_Death", function()
    local victim = net.ReadEntity()
    local attacker = net.ReadEntity()
    local dmgType = net.ReadInt(32)
    local weapon = net.ReadEntity()

    if not IsValid(victim) then return end

    local vName = GetDisplayName(victim)
    local aName = GetDisplayName(attacker)

    if attacker == victim or not IsValid(attacker) or attacker:IsWorld() then
        aName = ""
    end

    local isHeadshot = (dmgType == -1) or victim.MW2_WasHeadshot or false

    table.insert(KillFeed, {
        type = "kill",
        vName = vName,
        vCol = GetFactionColor(victim),
        aName = aName,
        aCol = GetFactionColor(attacker),
        icon = Material(GetDeathIcon(dmgType, weapon), "smooth"),
        isHeadshot = isHeadshot,
        hsIcon = Material("killfeed/death_headshot.png", "smooth"),
        spawnTime = CurTime(),
        dieTime = CurTime() + CFG.LIFETIME
    })

    if #KillFeed > CFG.MAX_MESSAGES then table.remove(KillFeed, 1) end
end)

-- Meta Events
gameevent.Listen("player_connect_client")
hook.Add("player_connect_client", "MW2_Feed_Join", function(data)
    table.insert(KillFeed, { type = "meta", msg = data.name .. " Connected", spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "MW2_Feed_Leave", function(data)
    table.insert(KillFeed, { type = "meta", msg = data.name .. " left the game", spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

-- [[ RENDERING ]]
hook.Add("HUDPaint", "MW2_Killfeed_Draw", function()
    local ct = CurTime()

    -- Scale all layout values uniformly at draw time.
    local xPos = S(CFG.X_POS)
    local yPos = S(CFG.Y_POS)
    local spacing = S(CFG.SPACING)
    local iconW = S(CFG.ICON_W)
    local iconH = S(CFG.ICON_H)
    local iconOffY = S(CFG.ICON_OFFSET_Y)
    local gap_name = S(10)
    local gap_icon = S(5)
    local gap_extra = S(5)

    local baseY = ScrH() - yPos

    for i = #KillFeed, 1, -1 do
        local data = KillFeed[i]
        local age = ct - data.spawnTime
        local timeLeft = data.dieTime - ct

        if timeLeft <= 0 then
            table.remove(KillFeed, i)
            continue
        end

        -- Calculate Animation and Fading
        local animProgress = math.Clamp(age / CFG.ANIM_TIME, 0, 1)
        local fadeFactor = 1

        if age < CFG.ANIM_TIME then
            -- Fade in from below
            fadeFactor = animProgress
        elseif timeLeft < 1 then
            -- Fade out (standard)
            fadeFactor = math.Clamp(timeLeft, 0, 1)
        end

        -- Vertical Offset Logic: Start lower and rise up
        local yOffset = (1 - animProgress) * S(CFG.ANIM_RISE)
        local currentY = baseY - ((#KillFeed - i) * spacing) + yOffset

        local x = xPos
        local finalTxtAlpha = CFG.TEXT_ALPHA * fadeFactor

        surface.SetFont("MW2_KillfeedFont")

        if data.type == "kill" then
            -- 1. Attacker
            if data.aName != "" then
                local aCol = Color(data.aCol.r, data.aCol.g, data.aCol.b, finalTxtAlpha)
                draw.SimpleText(data.aName, "MW2_KillfeedFont", x, currentY, aCol)
                local tw, _ = surface.GetTextSize(data.aName)
                x = x + tw + gap_name
            end

            -- 2. Icon
            surface.SetDrawColor(255, 255, 255, math.min(CFG.ICON_ALPHA * fadeFactor, 255))
            if data.isHeadshot then
                surface.SetMaterial(data.hsIcon)
            else
                surface.SetMaterial(data.icon)
            end
            
            surface.DrawTexturedRect(x, currentY + iconOffY, iconW, iconH)
            x = x + iconW + gap_icon
            x = x + gap_extra

            -- 3. Victim
            local vCol = Color(data.vCol.r, data.vCol.g, data.vCol.b, finalTxtAlpha)
            draw.SimpleText(data.vName, "MW2_KillfeedFont", x, currentY, vCol)
        else
            draw.SimpleText(data.msg, "MW2_KillfeedFont", x, currentY, Color(255, 255, 255, finalTxtAlpha))
        end
    end
end)