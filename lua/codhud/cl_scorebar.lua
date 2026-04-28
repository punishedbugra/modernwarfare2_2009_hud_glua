---- [ SCOREBAR ] ----

local function SyncFactionPersistence()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    local saved = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    if not CoDHUD.Factions[CoDHUD_GetHUDType()][saved] then saved = "rangers" end
    lp:SetNW2String("CoDHUD_Faction", saved)
    RunConsoleCommand("codhud_setfaction", saved)
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

concommand.Add("set_faction", function(ply, cmd, args)
    local faction = args[1] and string.lower(args[1]) or ""
    if CoDHUD.Factions[CoDHUD_GetHUDType()][faction] then
        LocalPlayer():SetNW2String("CoDHUD_Faction", faction)
        cookie.Set("CoDHUD_SelectedFaction", faction)
        RunConsoleCommand("codhud_setfaction", faction)
        print("[CoD HUD] You joined team " .. language.GetPhrase(CoDHUD.Factions[CoDHUD_GetHUDType()][faction].name))
    else
        print("[CoD HUD] Tried to join an invalid faction.")
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

        -- if o > 0 then
            -- draw.SimpleText(char, font, runX - o, y,     outlineCol, 0, 0)
            -- draw.SimpleText(char, font, runX + o, y,     outlineCol, 0, 0)
            -- draw.SimpleText(char, font, runX,     y - o, outlineCol, 0, 0)
            -- draw.SimpleText(char, font, runX,     y + o, outlineCol, 0, 0)
			
        -- end

        -- draw.SimpleText(char, font, runX, y, color, 0, 0)
		
		draw.SimpleTextOutlined( char, font, runX, y, color, 0, 0, o, outlineCol )

        local w = surface.GetTextSize(char)
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            runX = runX + w + gap
        end
    end
end

local function GetScorebarData()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local str = CoDHUD[CoDHUD_GetHUDType()].TextStrings
    local data = {}

    -- RAW TIME (use this for logic)
    local remaining = math.max(0, CoDHUD_RoundEndTime - CurTime())
    data.timeRaw = remaining -- precise float for comparisons
    data.timeAlive = remaining > 0 -- simple boolean check

    -- DISPLAY TIME
	local mins = math.floor(remaining / 60)
	local secs = math.floor(remaining % 60)

	-- base string (always mm:ss)
	local baseTime = string.format("%d:%02d", mins, secs)

	-- add tenths when under 30 seconds
	if remaining < 30 and remaining > 0 then
		local tenths = math.floor((remaining % 1) * 10)
		data.timeStr = string.format("%s.%d", baseTime, tenths)
	else
		data.timeStr = baseTime
	end

	data.mins = mins

    -- SCORES (unchanged logic)
    local clientScore = math.max(0, ply:Frags())
    local topEnemyScore = 0

    for _, p in ipairs(player.GetAll()) do
        if p == ply then continue end
        local score = math.max(0, p:Frags())
        if score > topEnemyScore then
            topEnemyScore = score
        end
    end

    data.clientScore = clientScore
    data.enemyScore  = topEnemyScore

    -- STATUS COLORS
    local COL_WINNING = Color(110, 220, 120, 255)
    local COL_LOSING  = Color(215, 110, 120, 255)
    local COL_TIE     = Color(230, 230, 110, 255)

    data.statusText = str.scorebar.tied or "MW2_MPUI_TIED_CAPS"
    data.statusCol  = COL_TIE

    if clientScore > topEnemyScore then
        data.statusText = str.scorebar.winning or "MW2_MPUI_WINNING_CAPS"
        data.statusCol  = COL_WINNING
    elseif clientScore < topEnemyScore then
        data.statusText = str.scorebar.losing or "MW2_MPUI_LOSING_CAPS"
        data.statusCol  = COL_LOSING
    end

    return data
end

hook.Add("HUDPaint", "CoDHUD_Scorebar", function()
    if (not GetConVar("codhud_enable_scorebar"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
    if not GetConVar("cl_drawhud"):GetBool() then return end

    local ply = LocalPlayer()
    -- if not IsValid(ply) or not ply:Alive() then return end
    if not IsValid(ply) then return end

    if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Scorebar then
        local data = GetScorebarData()
        if data then
            CoDHUD[CoDHUD_GetHUDType()].Scorebar(data)
        end
    end
end)