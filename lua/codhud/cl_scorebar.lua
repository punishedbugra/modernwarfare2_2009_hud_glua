---- [ SCOREBAR ] ----

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