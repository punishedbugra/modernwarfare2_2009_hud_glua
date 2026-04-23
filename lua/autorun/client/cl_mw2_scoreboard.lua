-- [[ cl_mw2_scoreboard.lua ]]

-- [[ RESOLUTION SCALING ]]
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
    -- Player Row Background
    BAR_W = 1086,
    BAR_H = 38,
    BAR_X_OFF = 0,
    BAR_Y_OFF = 290,
    BAR_ALPHA = 200,

    -- Spacing & Layout
    ROW_GAP = 2,
    TEAM_GAP = 120,

    -- Faction Icon
    ICON_SIZE = 77,
    ICON_X_OFF = 0,
    ICON_Y_OFF = -86,

    -- Faction Name Position
    FAC_NAME_X = 96,
    FAC_NAME_Y = -44,

    -- Stats Header Y Position
    STATS_HEADER_Y = -45,

    -- Full-Width Header Bar
    HEADER_Y_POS = 90,
    HEADER_H = 50,
    HEADER_ALPHA = 255,
    HEADER_ICON_SIZE = 86,
    HEADER_ICON_X = 140,
    HEADER_ENEMY_ICON_X = 340,

    -- Map Display
    MAP_Y_OFF = 98,

    -- Ping Indicator
    PING_BOX_SIZE = 38,
    PING_BOX_ALPHA = 155,
    PING_X_OFF = 5,
    PING_BAR_W = 6,
    PING_BAR_SPACING = 3,

    -- Timer / Header Score
    TIMER_X_POS = 245,
    TIMER_Y_OFF = 98,
    SQUEEZE = -2,
    SQUEEZE_ONE = -6,
    SQUEEZE_ONE_BEFORE = -4,
    TIMER_OUTLINE_W = 2,

    -- Stat Offsets (from barRight, going left)
    OFF_DEATHS = 10,
    OFF_ASSISTS = 120,
    OFF_KILLS = 225,
    OFF_SCORE = 335,
}

local MAT_GRADIENT_L = Material("vgui/gradient-l")
local MAT_ICON_DEAD  = Material("icons/hud_status_dead.png", "mips smooth")

local function MW2_InitScoreboardFonts()
    surface.CreateFont("MW2_Scoreboard_Text", {
        font = "Conduit ITC Light",
        size = S(34),
        weight = 400,
        antialias = true,
        shadow    = true,
    })
    surface.CreateFont("MW2_Scoreboard_Timer", {
        font = "BankGothic Md BT",
        size = S(34),
        weight = 400,
        antialias = true,
    })
end

MW2_InitScoreboardFonts()

hook.Add("OnScreenSizeChanged", "MW2_ReinitScoreboardFonts", function()
    MW2_InitScoreboardFonts()
end)

local function DrawSqueezedText(text, font, x, y, color, squeeze, squeezeOne, align, squeezeOneBefore)
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

    local runX = (align == 1) and (x - totalW / 2) or (align == 2 and x - totalW or x)

    for i = 1, #str do
        local char     = str:sub(i, i)
        local nextChar = str:sub(i + 1, i + 1)
        local o        = S(CFG.TIMER_OUTLINE_W)
        local outlineCol = Color(0, 0, 0, color.a)

        -- draw.SimpleText(char, font, runX - o, y,     outlineCol, 0, 0)
        -- draw.SimpleText(char, font, runX + o, y,     outlineCol, 0, 0)
        -- draw.SimpleText(char, font, runX,     y - o, outlineCol, 0, 0)
        -- draw.SimpleText(char, font, runX,     y + o, outlineCol, 0, 0)
        -- draw.SimpleText(char, font, runX,     y,     color,      0, 0)

		draw.SimpleTextOutlined( char, font, runX, y, color, 0, 0, o, outlineCol )

        local w = surface.GetTextSize(char)
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            runX = runX + w + gap
        end
    end
end

local function SortLogic(a, b)
    local scoreA = math.max(0, a:Frags() * 100)
    local scoreB = math.max(0, b:Frags() * 100)

    if scoreA == scoreB then
        if a == LocalPlayer() then return true end
        if b == LocalPlayer() then return false end
        return a:Nick() < b:Nick()
    end

    return scoreA > scoreB
end

local function DrawPlayerRow(ply, lp, x, y, w, h, barRight, bgCol)
    -- Background
    surface.SetDrawColor(bgCol.r, bgCol.g, bgCol.b, CFG.BAR_ALPHA)
    surface.DrawRect(x, y, w, h)
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()

    -- Status Icon (dead indicator) - Moved next to name
    if ply:IsValid() and not ply:Alive() then
        surface.SetMaterial(MAT_ICON_DEAD)
        surface.SetDrawColor(255, 255, 255, 255)
        local iconSz = h * 0.8
        -- Adjusted X to be right before the name (name starts at 110)
        surface.DrawTexturedRect(x + S(75), y + (h / 2) - (iconSz / 2), iconSz, iconSz)
    end

    -- Colors & Stats
    local isMe = (ply == lp)
    local tCol = isMe and Color(255, 200, 50, 255) or Color(255, 255, 255, 255)
    local pScore = math.max(0, ply:Frags() * 100)

    -- Text
    draw.SimpleTextOutlined(ply:Nick(), "MW2_Scoreboard_Text", x + S(110), y + (h / 2), tCol, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
    draw.SimpleTextOutlined(ply:Deaths(), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_DEATHS),  y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
    draw.SimpleTextOutlined(ply:GetNWInt("Assists", 0), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_ASSISTS), y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
    draw.SimpleTextOutlined(ply:Frags(), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_KILLS),   y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
    draw.SimpleTextOutlined(pScore, "MW2_Scoreboard_Text", barRight - S(CFG.OFF_SCORE),   y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))

    -- Ping Indicator
    local boxSize = S(CFG.PING_BOX_SIZE)
    local pingX = barRight + S(CFG.PING_X_OFF)
    local pingY = y + (h / 2) - (boxSize / 2)

    surface.SetDrawColor(0, 0, 0, CFG.PING_BOX_ALPHA)
    surface.DrawRect(pingX, pingY, boxSize, boxSize)

    surface.SetDrawColor(0, 255, 0, 255)
    local rodW = S(CFG.PING_BAR_W)
    local rodSpacing = S(CFG.PING_BAR_SPACING)
    local totalRodsWidth = (rodW * 4) + (rodSpacing * 3)
    local startX = pingX + (boxSize / 2) - (totalRodsWidth / 2)

    for i = 1, 4 do
        local bh = (boxSize - S(6)) * (i / 4)
        surface.DrawRect(startX + ((i - 1) * (rodW + rodSpacing)), pingY + (boxSize - bh - S(3)), rodW, bh)
    end
end

local showScoreboard = false

hook.Add("DrawOverlay", "MW2_Scoreboard_Main", function()
    if not showScoreboard then return end
	if (not GetConVar("mw2_enable_scoreboard"):GetBool()) or GetConVar("mw2_quickdisable_hud"):GetBool() then return end
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()

    local scrW, scrH = ScrW(), ScrH()
    local lp = LocalPlayer()

    -- 1. IDENTIFY FACTIONS & PLAYERS
	local factions = {}

	for _, p in ipairs(player.GetAll()) do
		local fac = p:GetNW2String("MW2_Faction", "rangers")
		if fac == "" then fac = "rangers" end

		factions[fac] = factions[fac] or {}
		table.insert(factions[fac], p)
	end

    -- 2. SORT PLAYERS
	local factionList = {}

	for fac, players in pairs(factions) do
		table.sort(players, SortLogic)

		table.insert(factionList, {
			key = fac,
			players = players,
			score = 0
		})
	end

	for _, f in ipairs(factionList) do
		local score = 0
		for _, p in ipairs(f.players) do
			score = score + math.max(0, p:Frags() * 100)
		end
		f.score = score
	end

	table.sort(factionList, function(a, b)
		return a.score > b.score
	end)

    -- 3. LAYOUT POSITIONS
    local barW = S(CFG.BAR_W)
    local barH = S(CFG.BAR_H)
    local barX = (scrW / 2) - (barW / 2) + S(CFG.BAR_X_OFF)
    local barRight = barX + barW

	local startY = S(CFG.BAR_Y_OFF)

	for fi, facData in ipairs(factionList) do
		local players = facData.players
		local facKey = facData.key
		local fData = MW2Factions and MW2Factions[facKey] or {
			name = facKey,
			short = facKey,
			color = Color(120,120,120)
		}

		local sectionY = startY

		-- ICON
		local iconPath = "factions/faction_128_" .. facKey .. ".png"
		local mat = Material(iconPath, "smooth")

		surface.SetMaterial(mat)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(barX + S(CFG.ICON_X_OFF), sectionY + S(CFG.ICON_Y_OFF), S(CFG.ICON_SIZE), S(CFG.ICON_SIZE))

		draw.SimpleTextOutlined(
			language.GetPhrase(fData.short) .. " (" .. #players .. ")",
			"MW2_Scoreboard_Text",
			barX + S(CFG.FAC_NAME_X),
			sectionY + S(CFG.FAC_NAME_Y),
			Color(255,255,255),
			0,0,
			outlined and 1 or 0,
			Color(0,0,0)
		)

		-- rows
		for i, ply in ipairs(players) do
			local rowY = sectionY + (i - 1) * (barH + S(CFG.ROW_GAP))
			DrawPlayerRow(ply, lp, barX, rowY, barW, barH, barRight, fData.color)
		end

		-- push next faction down
		local sectionHeight = S(0) + (#players * (barH + S(CFG.ROW_GAP)))
		startY = startY + sectionHeight + S(CFG.TEAM_GAP)
	end

    surface.SetDrawColor(110, 110, 110, CFG.HEADER_ALPHA)
    surface.SetMaterial(MAT_GRADIENT_L)
    surface.DrawTexturedRect(0, S(CFG.HEADER_Y_POS), scrW, S(CFG.HEADER_H))

    -- Map name
    local mapName = string.upper(game.GetMap())
	draw.SimpleTextOutlined( mapName, "MW2_Scoreboard_Timer", scrW/2, S(CFG.MAP_Y_OFF), Color(255, 255, 255), 1, 0, outlined and 1.5 or 0, Color(0,0,0) )

    -- Timer
    local totalSecs = math.floor(CurTime())
    local mins, secs = math.floor(totalSecs / 60), totalSecs % 60
    local timeStr = string.format("%d:%02d", mins, secs)
    DrawSqueezedText(timeStr, "MW2_Scoreboard_Timer", scrW - S(CFG.TIMER_X_POS), S(CFG.TIMER_Y_OFF), Color(255, 255, 255, 255), CFG.SQUEEZE, CFG.SQUEEZE_ONE, 0, CFG.SQUEEZE_ONE_BEFORE)

    -- Stats column headers
    local headerY = S(CFG.BAR_Y_OFF) - S(35)
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_DEATHS"), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_DEATHS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_ASSISTS"), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_ASSISTS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_KILLS"), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_KILLS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_SCORE"), "MW2_Scoreboard_Text", barRight - S(CFG.OFF_SCORE), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	
	
	local lp = LocalPlayer()
	local myFaction = lp:GetNW2String("MW2_Faction", "rangers")
	if myFaction == "" then myFaction = "rangers" end
	
	table.sort(factionList, function(a, b)
		if a.key == myFaction then return true end
		if b.key == myFaction then return false end
		return a.score > b.score
	end)

	local stripX = S(20)
	local stripY = S(CFG.HEADER_Y_POS) + (S(CFG.HEADER_H) / 2) - (S(CFG.HEADER_ICON_SIZE) / 2)
	local stripGap = S(18)
	local iconSize = S(CFG.HEADER_ICON_SIZE)
	local textOffset = S(8)
	
	local x = stripX

	surface.SetFont("MW2_Scoreboard_Text")

	for _, fac in ipairs(factionList) do
		local key = fac.key
		local players = fac.players
		local score = fac.score or 0

		local fData = MW2Factions and MW2Factions[key] or {
			short = key,
			color = Color(150,150,150)
		}

		local iconPath = "factions/faction_128_" .. key .. ".png"
		local mat = Material(iconPath, "smooth")

		if mat:IsError() then
			mat = Material("vgui/hud/icon_error")
		end

		-- format label (NOW uses SCORE instead of player count)
		local label = score

		local textW, textH = surface.GetTextSize(label)

		-- icon (aligned left)
		surface.SetMaterial(mat)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(x, stripY, iconSize, iconSize)

		-- text (VERTICALLY CENTERED like old system)
		draw.SimpleTextOutlined( label, "MW2_Scoreboard_Text", x + iconSize + textOffset, stripY + iconSize / 2, Color(255,255,255), 0, 1, outlined and 1 or 0, Color(0,0,0) )

		-- spacing correction (tightened + consistent)
		x = x + iconSize + textW + S(25)
	end

    -- Manually call the custom chat hook so it draws while the rest of the HUD is suppressed
    local hudHooks = hook.GetTable()["HUDPaint"]
    if hudHooks and hudHooks["MW2_DrawChat"] then
        hudHooks["MW2_DrawChat"]()
    end
end)

hook.Add("ScoreboardShow", "MW2_Scoreboard_Open",  function() 
	if (not GetConVar("mw2_enable_scoreboard"):GetBool()) or GetConVar("mw2_quickdisable_hud"):GetBool() then return end
	showScoreboard = true 
	return true
end)

hook.Add("ScoreboardHide", "MW2_Scoreboard_Close", function() 
	if (not GetConVar("mw2_enable_scoreboard"):GetBool()) or GetConVar("mw2_quickdisable_hud"):GetBool() then return end
	showScoreboard = false
end)

hook.Add("HUDShouldDraw", "MW2_Scoreboard_HideHUD", function(name)
    -- Suppress the entire HUD when scoreboard is open (except crosshair)
	if (not GetConVar("mw2_enable_scoreboard"):GetBool()) or GetConVar("mw2_quickdisable_hud"):GetBool() then return end
    if showScoreboard then
        if name == "CHudCrosshair" then return true end
        return false
    end
end)