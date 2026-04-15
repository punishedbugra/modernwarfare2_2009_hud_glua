local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x)  return math.Round(x * GetUIScale()) end
local function SX(x) return math.Round(x * GetUIScale()) end
local function SY(y) return math.Round(y * GetUIScale()) end

local CFG = {
    -- Base Bar
    BAR_W     = 776,
    BAR_H     = 96,
    BAR_X_OFF = 0,
    BAR_Y_OFF = 44,

    -- Faction Icon
    ICON_SCALE = 1.28,
    ICON_X     = 12,
    ICON_Y     = 8,

    -- Timer
    TIMER_FONT_SIZE  = 34,
    TIMER_X          = 86,
    TIMER_Y          = -32,
    TIMER_SHIFT_2DIG = -10,
    TIMER_SHIFT_3DIG = -12,
    TIMER_OUTLINE_W  = 2,

    -- Winning / Losing / Tie Text Position
    STATUS_X = 150,
    STATUS_Y = 5,
    STATUS_FONT_SIZE = 34,

    -- Squeeze Values
    SQUEEZE            = -2,
    SQUEEZE_ONE        = -6,
    SQUEEZE_ONE_BEFORE = -4,
}

local SCORES_CFG = {
    -- Text Config
    X = 162,
    Y = 974,
    GAP_OFFSET = 32,
    SQUEEZE = -4,
    SQUEEZE_ONE = -10,
    SQUEEZE_ONE_BEFORE = -10,
    OUTLINE_W = 2,

    -- Score Limit for Bar Scaling
    SCORE_LIMIT = 7500,

    -- Active Bar Config (Green/Red)
    HUD_X = 200,
    HUD_Y = 1015,
    HUD_W_BASE = 28,
    HUD_W_MAX = 282,
    HUD_H = 10,
    SLANT_SIZE = 11,
    VERTICAL_GAP = 10,
    SHADOW_OFFSET = 2,

    -- Base Bar Config (Black Backgrounds)
    BASE_X = 190,
    BASE_Y = 1012,
    BASE_W = 298,
    BASE_H = 11,
    BASE_SLANT = 10,
    BASE_GAP = 4,

    -- End Cap Config
    CAP_W = 3,
    CAP_H_OFFSET = 2,
    CAP_SLANT = 10,
    CAP_COLOR = Color(255, 255, 255, 155),

    -- Active Slant Config
    SLANT_W = 7,
    SLANT_H_OFFSET = 0.4,
    SLANT_SEP_W = 1,
    SLANT_Y_OFFSET_TOP = 0,
    SLANT_COLOR = Color(255, 255, 255, 220),
}

local ARROW_CFG = {
    x = 140,
    y = 978,
    w = 27,
    h = 31,
    outline = 4,
    color = Color(140, 220, 140, 255),
    outlineColor = Color(0, 0, 0, 255),
    material = Material("hud/ui_arrow_right.png", "smooth noclamp"),
}

-- fucktion data
FACTIONS = {
    ["rangers"]      = {
		name = "MW2_MP_US_ARMY_NAME",
		short = "MW2_MP_US_ARMY_SHORT_NAME",
		voice = "US",
		scoreIcon = "factions/faction_128_rangers_fade.png",
		color = Color(100, 105, 80)
	},
	
    ["taskforce141"] = {
		name = "MW2_MP_TASKFORCE_NAME",
		short = "MW2_MP_TASKFORCE_SHORT_NAME",
		voice = "UK",
		scoreIcon = "factions/faction_128_taskforce141_fade.png",
		color = Color(70, 80, 80)
	},
	
    ["seals"]        = {
		name = "MW2_MP_SEALS_UDT_NAME",
		short = "MW2_MP_SEALS_UDT_SHORT_NAME",
		voice = "NS",
		scoreIcon = "factions/faction_128_seals_fade.png",
		color = Color(65, 90, 130)
	},
	
    ["ussr"]         = {
		name = "MW2_MP_SPETSNAZ_NAME",
		short = "MW2_MPUI_SPETSNAZ_SHORT",
		voice = "RU",
		scoreIcon = "factions/faction_128_ussr_fade.png",
		color = Color(105, 40, 45)
	},
	
    ["arab"]         = {
		name = "MW2_MP_OPFOR_NAME",
		short = "MW2_MPUI_OPFOR_SHORT",
		voice = "AB",
		scoreIcon = "factions/faction_128_arab_fade.png",
		color = Color(105, 60, 45)
	},
	
    ["militia"]      = {
		name = "MW2_MP_MILITIA_NAME",
		short = "MW2_MP_MILITIA_SHORT_NAME",
		voice = "PG",
		scoreIcon = "factions/faction_128_militia_fade.png",
		color = Color(100, 10, 15)
	},
	
}

local function SyncFactionPersistence()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    local saved = cookie.GetString("MW2_SelectedFaction", "rangers")
    if not FACTIONS[saved] then saved = "rangers" end
    lp:SetNW2String("MW2_Faction", saved)
    RunConsoleCommand("mw2_setfaction", saved)
end

hook.Add("InitPostEntity", "MW2_SyncFactionOnJoin", function()
    timer.Simple(1.5, function()
        SyncFactionPersistence()
    end)
end)

hook.Add("NotifyShouldTransmit", "MW2_SyncFactionOnSpawn", function(ent, should)
    if ent == LocalPlayer() and should then
        SyncFactionPersistence()
    end
end)

local FACTION_MATS = {}
for key, data in pairs(FACTIONS) do
    FACTION_MATS[key] = Material(data.scoreIcon, "smooth")
end

local MAT_BAR      = Material("hud/hud_scorebar.png", "smooth")
local MAT_GRADIENT = Material("vgui/gradient-r")

local COLOR_SHADOW = Color(0, 0, 0, 100)
local COLOR_GREEN  = Color(110, 180, 90, 255)
local COLOR_RED    = Color(180, 55, 55, 255)

-- Status Colors
local COL_WINNING = Color(110, 220, 120, 255)
local COL_LOSING  = Color(215, 110, 120, 255)
local COL_TIE     = Color(230, 230, 110, 255)

local function MW2_InitScoreFonts()
    surface.CreateFont("MW2_Timer", {
        font      = "BankGothic Md BT",
        size      = S(CFG.TIMER_FONT_SIZE),
        weight    = 400,
        antialias = true,
        shadow    = false,
    })
    surface.CreateFont("MW2_Status", {
        font      = "BankGothic Md BT",
        size      = S(CFG.STATUS_FONT_SIZE),
        weight    = 400,
        antialias = true,
        shadow    = true,
    })
    surface.CreateFont("MW2_Font", {
        font      = "BankGothic Md BT",
        size      = S(36),
        weight    = 400,
        antialias = true,
    })
end

MW2_InitScoreFonts()

hook.Add("OnScreenSizeChanged", "MW2_ReinitScoreFonts", function()
    MW2_InitScoreFonts()
end)

concommand.Add("set_faction", function(ply, cmd, args)
    local faction = args[1] and string.lower(args[1]) or ""
    if FACTIONS[faction] then
        LocalPlayer():SetNW2String("MW2_Faction", faction)
        cookie.Set("MW2_SelectedFaction", faction)
        RunConsoleCommand("mw2_setfaction", faction)
        print("[MW2] Faction set to: " .. FACTIONS[faction].name)
    else
        print("[MW2] Unknown faction. Valid: rangers, taskforce141, seals, ussr, arab, militia")
    end
end)

local function DrawSqueezedText(text, font, x, y, color, squeeze, squeezeOne, align, squeezeOneBefore, outlineW)
    local str = tostring(text)
    surface.SetFont(font)

    local totalW = 0
    for i = 1, #str do
        local char     = str:sub(i, i)
        local nextChar = str:sub(i + 1, i + 1)
        local w = surface.GetTextSize(char)
        totalW = totalW + w
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            totalW = totalW + gap
        end
    end

    local runX = (align == 1) and (x - totalW/2) or (align == 2 and x or x - totalW)

    for i = 1, #str do
        local char     = str:sub(i, i)
        local nextChar = str:sub(i + 1, i + 1)
        local o        = outlineW or 0
        local outlineCol = Color(0, 0, 0, color.a)

        if o > 0 then
            draw.SimpleText(char, font, runX - o, y,     outlineCol, 0, 0)
            draw.SimpleText(char, font, runX + o, y,     outlineCol, 0, 0)
            draw.SimpleText(char, font, runX,     y - o, outlineCol, 0, 0)
            draw.SimpleText(char, font, runX,     y + o, outlineCol, 0, 0)
        end

        draw.SimpleText(char, font, runX, y, color, 0, 0)

        local w = surface.GetTextSize(char)
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            runX = runX + w + gap
        end
    end
end

hook.Add("HUDPaint", "MW2_ScoreBar", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local currentFaction = ply:GetNW2String("MW2_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("MW2_SelectedFaction", "rangers")
        if not FACTIONS[currentFaction] then currentFaction = "rangers" end
        ply:SetNW2String("MW2_Faction", currentFaction)
    end

    local scrW, scrH = ScrW(), ScrH()
    local barW, barH = SX(CFG.BAR_W), SY(CFG.BAR_H)
    -- Scorebar is anchored to the left edge (X=0 + offset) and bottom edge.
    local barX = SX(CFG.BAR_X_OFF)
    local barY = scrH - SY(CFG.BAR_Y_OFF) - barH

    -- 1. Base bar texture
    surface.SetMaterial(MAT_BAR)
    surface.SetDrawColor(255, 255, 255, 155)
    surface.DrawTexturedRect(barX, barY, barW, barH)

    -- 2. Faction icon
    local factionMat = FACTION_MATS[currentFaction]
    if factionMat then
        local iSize = math.Round(barH * CFG.ICON_SCALE)
        surface.SetMaterial(factionMat)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(barX + SX(CFG.ICON_X), barY + SY(CFG.ICON_Y), iSize, iSize)
    end

    -- 3. Timer
    local totalSecs = math.floor(CurTime())
    local mins, secs = math.floor(totalSecs / 60), totalSecs % 60
    local timeStr = string.format("%d:%02d", mins, secs)

    local xShift = (#tostring(mins) >= 3 and SX(CFG.TIMER_SHIFT_3DIG)) or (#tostring(mins) >= 2 and SX(CFG.TIMER_SHIFT_2DIG)) or 0
    DrawSqueezedText(timeStr, "MW2_Timer",
        barX + SX(CFG.TIMER_X) + xShift, barY + SY(CFG.TIMER_Y),
        Color(255, 255, 255, 255),
        CFG.SQUEEZE, CFG.SQUEEZE_ONE, 1, CFG.SQUEEZE_ONE_BEFORE,
        SX(CFG.TIMER_OUTLINE_W)
    )

    -- 4. Status Text (Winning / Losing / Tie)
    local lpScore = math.max(0, ply:Frags()) * 100
    local topEnemyScore = 0
    for _, p in ipairs(player.GetAll()) do
        if p == ply then continue end
        local pScore = math.max(0, p:Frags()) * 100
        if pScore > topEnemyScore then topEnemyScore = pScore end
    end

    local statusText = "#MW2_MPUI_TIED_CAPS"
    local statusCol  = COL_TIE

    if lpScore > topEnemyScore then
        statusText = "#MW2_MPUI_WINNING_CAPS"
        statusCol  = COL_WINNING
    elseif lpScore < topEnemyScore then
        statusText = "#MW2_MPUI_LOSING_CAPS"
        statusCol  = COL_LOSING
    end

    draw.SimpleText(statusText, "MW2_Status", barX + SX(CFG.STATUS_X), barY + SY(CFG.STATUS_Y), statusCol, TEXT_ALIGN_LEFT)
end)

hook.Add("HUDPaint", "MW2_Scorebar_Merged", function()
    if not IsValid(LocalPlayer()) then return end

    local client = LocalPlayer()
    local clientKills = math.max(0, client:Frags()) * 100

    local topEnemyKills = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply == client then continue end
        local pKills = math.max(0, ply:Frags()) * 100
        if pKills > topEnemyKills then topEnemyKills = pKills end
    end

    local S_CFG = SCORES_CFG
    local scrW, scrH = ScrW(), ScrH()

    -- All sizes/offsets scale uniformly with S(). Positions that sit near the left/top use S() from the edge directly. Positions near the bottom use scrH - S(distance_from_bottom).
    local baseX     = S(S_CFG.BASE_X)
    local baseY_raw = scrH - S(BASE_H - S_CFG.BASE_Y)
    local baseW     = S(S_CFG.BASE_W)
    local baseH     = S(S_CFG.BASE_H)
    local baseSlant = S(S_CFG.BASE_SLANT)
    local baseGap   = S(S_CFG.BASE_GAP)

    local capW      = S(S_CFG.CAP_W)
    local capSlant  = S(S_CFG.CAP_SLANT)
    local capHOff   = S(S_CFG.CAP_H_OFFSET)

    local hudX      = S(S_CFG.HUD_X)
    local hudY_raw  = scrH - S(BASE_H - S_CFG.HUD_Y)
    local hudWBase  = S(S_CFG.HUD_W_BASE)
    local hudWMax   = S(S_CFG.HUD_W_MAX)
    local hudH      = S(S_CFG.HUD_H)
    local slantSize = S(S_CFG.SLANT_SIZE)
    local vertGap   = S(S_CFG.VERTICAL_GAP)
    local shadowOff = S(S_CFG.SHADOW_OFFSET)

    local slantW    = S(S_CFG.SLANT_W)
    local slantHOff = S(S_CFG.SLANT_H_OFFSET)
    local slantSepW = S(S_CFG.SLANT_SEP_W)

    -- Base bars (black backgrounds)
    local BASE_X   = baseX
    local BASE_Y   = baseY_raw
    local BASE_W   = baseW
    local BASE_H   = baseH
    local BASE_SLANT = baseSlant
    local top_y_base = BASE_Y - baseGap - BASE_H

    surface.SetMaterial(MAT_GRADIENT)
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawTexturedRect(BASE_X, BASE_Y, BASE_W, BASE_H)

    draw.NoTexture()
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawPoly({
        { x = BASE_X + BASE_W,              y = BASE_Y },
        { x = BASE_X + BASE_W + BASE_SLANT, y = BASE_Y },
        { x = BASE_X + BASE_W,              y = BASE_Y + BASE_H },
    })

    surface.SetMaterial(MAT_GRADIENT)
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawTexturedRect(BASE_X, top_y_base, BASE_W, BASE_H)

    draw.NoTexture()
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawPoly({
        { x = BASE_X + BASE_W,              y = top_y_base },
        { x = BASE_X + BASE_W + BASE_SLANT, y = top_y_base + BASE_H },
        { x = BASE_X + BASE_W,              y = top_y_base + BASE_H },
    })

    -- End caps
    surface.SetDrawColor(S_CFG.CAP_COLOR)
    surface.DrawPoly({
        { x = BASE_X + BASE_W,                  y = top_y_base - (capHOff / 2) },
        { x = BASE_X + BASE_W + capW,            y = top_y_base - (capHOff / 2) },
        { x = BASE_X + BASE_W + capSlant + capW, y = top_y_base + BASE_H + (capHOff / 2) },
        { x = BASE_X + BASE_W + capSlant,        y = top_y_base + BASE_H + (capHOff / 2) },
    })
    surface.DrawPoly({
        { x = BASE_X + BASE_W + capSlant,        y = BASE_Y - (capHOff / 2) },
        { x = BASE_X + BASE_W + capSlant + capW, y = BASE_Y - (capHOff / 2) },
        { x = BASE_X + BASE_W + capW,            y = BASE_Y + BASE_H + (capHOff / 2) },
        { x = BASE_X + BASE_W,                  y = BASE_Y + BASE_H + (capHOff / 2) },
    })

    -- [SCALING LOGIC MERGE: Safely get the limit from the ConVar, fallback to SCORES_CFG.SCORE_LIMIT]
    local liveScoreLimit = S_CFG.SCORE_LIMIT
    local cv_limit = GetConVar("mw2_score_limit")
    if cv_limit then
        local val = cv_limit:GetInt()
        if val > 0 then
            liveScoreLimit = val
        end
    end

    -- Active bars (green = client, red = enemy)
    local maxAddedWidth = hudWMax - hudWBase
    local client_w = math.Round(hudWBase + math.Clamp((clientKills / liveScoreLimit) * maxAddedWidth, 0, maxAddedWidth))
    local enemy_w  = math.Round(hudWBase + math.Clamp((topEnemyKills / liveScoreLimit) * maxAddedWidth, 0, maxAddedWidth))
    local HUD_X    = hudX
    local HUD_Y    = hudY_raw
    local top_y    = HUD_Y - vertGap - hudH
    local white    = Color(255, 255, 255, 255)

    -- Shadows
    surface.SetMaterial(MAT_GRADIENT)
    surface.SetDrawColor(COLOR_SHADOW)
    surface.DrawTexturedRect(HUD_X + shadowOff, top_y + shadowOff, client_w, hudH)
    surface.DrawTexturedRect(HUD_X + shadowOff, HUD_Y + shadowOff, enemy_w, hudH)

    draw.NoTexture()
    surface.SetDrawColor(COLOR_SHADOW)
    surface.DrawPoly({
        { x = HUD_X + client_w + shadowOff,             y = top_y + shadowOff },
        { x = HUD_X + client_w + slantSize + shadowOff, y = top_y + hudH + shadowOff },
        { x = HUD_X + client_w + shadowOff,             y = top_y + hudH + shadowOff },
    })
    surface.DrawPoly({
        { x = HUD_X + enemy_w + shadowOff,             y = HUD_Y + shadowOff },
        { x = HUD_X + enemy_w + slantSize + shadowOff, y = HUD_Y + shadowOff },
        { x = HUD_X + enemy_w + shadowOff,             y = HUD_Y + hudH + shadowOff },
    })

    -- Client bar (green)
    surface.SetMaterial(MAT_GRADIENT)
    surface.SetDrawColor(COLOR_GREEN)
    surface.DrawTexturedRect(HUD_X, top_y, client_w, hudH)

    draw.NoTexture()
    surface.SetDrawColor(COLOR_GREEN)
    surface.DrawPoly({
        { x = HUD_X + client_w,             y = top_y },
        { x = HUD_X + client_w + slantSize, y = top_y + hudH },
        { x = HUD_X + client_w,             y = top_y + hudH },
    })

    -- Enemy bar (red)
    surface.SetMaterial(MAT_GRADIENT)
    surface.SetDrawColor(COLOR_RED)
    surface.DrawTexturedRect(HUD_X, HUD_Y, enemy_w, hudH)

    draw.NoTexture()
    surface.SetDrawColor(COLOR_RED)
    surface.DrawPoly({
        { x = HUD_X + enemy_w,             y = HUD_Y },
        { x = HUD_X + enemy_w + slantSize, y = HUD_Y },
        { x = HUD_X + enemy_w,             y = HUD_Y + hudH },
    })

    -- Client slant accent
    local tx1, ty1 = HUD_X + client_w, top_y
    local tx2, ty2 = HUD_X + client_w + slantSize, top_y + hudH

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawPoly({
        { x = tx1 - slantSepW, y = ty1 },
        { x = tx1,             y = ty1 },
        { x = tx2,             y = ty2 },
        { x = tx2 - slantSepW, y = ty2 },
    })
    surface.SetDrawColor(S_CFG.SLANT_COLOR)
    surface.DrawPoly({
        { x = tx1,           y = ty1 - (slantHOff / 2) },
        { x = tx1 + slantW,  y = ty1 - (slantHOff / 2) },
        { x = tx2 + slantW,  y = ty2 + (slantHOff / 2) },
        { x = tx2,           y = ty2 + (slantHOff / 2) },
    })

    -- Enemy slant accent
    local bx1, by1 = HUD_X + enemy_w + slantSize, HUD_Y
    local bx2, by2 = HUD_X + enemy_w, HUD_Y + hudH

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawPoly({
        { x = bx1,             y = by1 },
        { x = bx1 + slantSepW, y = by1 },
        { x = bx2 + slantSepW, y = by2 },
        { x = bx2,             y = by2 },
    })
    surface.SetDrawColor(S_CFG.SLANT_COLOR)
    surface.DrawPoly({
        { x = bx1 + slantSepW,          y = by1 - (slantHOff / 2) },
        { x = bx1 + slantSepW + slantW, y = by1 - (slantHOff / 2) },
        { x = bx2 + slantSepW + slantW, y = by2 + (slantHOff / 2) },
        { x = bx2 + slantSepW,          y = by2 + (slantHOff / 2) },
    })

-- Score text
    local textX   = S(S_CFG.X)
    -- Calculate Y based on the distance from the HUD_Y bar to maintain the layout
    local textY   = HUD_Y - S(41) -- Adjust 41 to change vertical distance from the bars
    local textGap = S(S_CFG.GAP_OFFSET)

    DrawSqueezedText(clientKills,   "MW2_Font", textX, textY,          white, S_CFG.SQUEEZE, S_CFG.SQUEEZE_ONE, 2, S_CFG.SQUEEZE_ONE_BEFORE, S_CFG.OUTLINE_W)
    DrawSqueezedText(topEnemyKills, "MW2_Font", textX, textY + textGap, white, S_CFG.SQUEEZE, S_CFG.SQUEEZE_ONE, 2, S_CFG.SQUEEZE_ONE_BEFORE, S_CFG.OUTLINE_W)end)

hook.Add("HUDPaint", "DrawMyCustomArrow", function()
    local scrW, scrH = ScrW(), ScrH()
    local ax = S(ARROW_CFG.x)
    local ay = scrH - S(BASE_H - ARROW_CFG.y)
    local aw = S(ARROW_CFG.w)
    local ah = S(ARROW_CFG.h)
    local ao = S(ARROW_CFG.outline)

    surface.SetMaterial(ARROW_CFG.material)

    surface.SetDrawColor(ARROW_CFG.outlineColor)
    surface.DrawTexturedRectUV(
        ax - ao,
        ay - ao,
        aw + (ao * 2),
        ah + (ao * 2),
        0, 0, 1, 1
    )

    surface.SetDrawColor(ARROW_CFG.color)
    surface.DrawTexturedRectUV(ax, ay, aw, ah, 0, 0, 1, 1)
end)