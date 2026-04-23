-- [[ cl_mw2_roundend.lua ]]

-- ============================================================
--  Scale helpers
-- ============================================================
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x)  return math.Round(x * GetUIScale()) end
local function SX(x) return math.Round(x * GetUIScale()) end
local function SY(y) return math.Round(y * GetUIScale()) end

-- ============================================================
--  Config
-- ============================================================
local CFG = {
    DURATION         = 15.0,
    BW_FADE_TIME     = 1.0,

    MUSIC_DELAY      = 0.0,
    VOICE_DELAY      = 3.0,
	POINTS_DELAY     = 4.0,
	SCOREBOARD_DELAY = 6.0,

    ICON_SIZE        = 184,
    ICON_X           = 960,
    ICON_Y           = 400,
    ICON_GAP         = 80,

    SCORE_X          = 960,
    SCORE_Y          = 620,
    SCORE_FONT_SIZE  = 54,

    RESULT_X         = 960,
    RESULT_Y         = 240,
    RESULT_FONT_SIZE = 72,

    LIMIT_X          = 960,
    LIMIT_Y          = 330,
    LIMIT_FONT_SIZE  = 48,

    BONUS_X          = 960,
    BONUS_Y          = 720,
    BONUS_FONT_SIZE  = 48,

    ICON_FADE_TIME   = 1.0,
}

-- ============================================================
--  Music / voices
-- ============================================================
local VICTORY_MUSIC = {
    US = "music/US/hz_mp_usvictory_1.mp3", UK = "music/UK/hz_mp_ukvictory_1.mp3",
    NS = "music/NS/hz_mp_nsvictory_1.mp3", RU = "music/RU/hz_mp_ruvictory_1.mp3",
    AB = "music/AB/hz_mp_abvictory_1.mp3", PG = "music/PG/hz_mp_pgvictory_1.mp3",
}
local DEFEAT_MUSIC = {
    US = "music/US/hz_mp_usdefeat_1.mp3",  UK = "music/UK/hz_mp_ukdefeat_1.mp3",
    NS = "music/NS/hz_mp_nsdefeat_1.mp3",  RU = "music/RU/hz_mp_rudefeat_1.mp3",
    AB = "music/AB/hz_mp_abdefeat_1.mp3",  PG = "music/PG/hz_mp_pgdefeat_1.mp3",
}

local function CalcMatchBonus(kills)
    kills = math.Clamp(kills, 0, 75)
    if kills == 0 then return math.random(100, 130) end
    local base = math.floor(100 + (kills / 75) ^ 2 * 2400)
    return math.Clamp(base + math.random(-50, 100), 100, 2500)
end

-- ============================================================
--  Fonts
-- ============================================================
local function RE_InitFonts()
    surface.CreateFont("MW2_RE_Sc_Pri", { font = "BankGothic Md BT", size = S(CFG.SCORE_FONT_SIZE),  weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Sc_Sec", { font = "BankGothic Md BT", size = S(CFG.SCORE_FONT_SIZE),  weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Sc_Shd", { font = "BankGothic Md BT", size = S(CFG.SCORE_FONT_SIZE),  weight = 400, blursize = 2, antialias = false, outline = true  })
    
    surface.CreateFont("MW2_RE_Re_Pri", { font = "BankGothic Md BT", size = S(CFG.RESULT_FONT_SIZE), weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Re_Sec", { font = "BankGothic Md BT", size = S(CFG.RESULT_FONT_SIZE), weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Re_Shd", { font = "BankGothic Md BT", size = S(CFG.RESULT_FONT_SIZE), weight = 400, blursize = 2, antialias = false, outline = true  })
    
    surface.CreateFont("MW2_RE_Li_Pri", { font = "BankGothic Md BT", size = S(CFG.LIMIT_FONT_SIZE),  weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Li_Sec", { font = "BankGothic Md BT", size = S(CFG.LIMIT_FONT_SIZE),  weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_RE_Li_Shd", { font = "BankGothic Md BT", size = S(CFG.LIMIT_FONT_SIZE),  weight = 400, blursize = 2, antialias = false, outline = true  })
    
    surface.CreateFont("MW2_RE_Bonus",  { font = "BankGothic Md BT", size = S(CFG.BONUS_FONT_SIZE),  weight = 400, blursize = 0, antialias = true,  outline = false })
end

RE_InitFonts()
hook.Add("OnScreenSizeChanged", "MW2_RE_ReinitFonts", RE_InitFonts)

-- ============================================================
--  State
-- ============================================================
local re_active       = false
local re_lock_time    = 0
local re_bw           = 0

local re_match_bonus  = 0

-- Write-in states
local ws_result = ""
local ws_limit = ""

local re_result_glow  = Color(255, 255, 255)

local re_mvlock = false
local re_locked_ang = nil

-- ============================================================
--  Cleanup
-- ============================================================
local function RE_End()
    re_active    = false
    re_mvlock    = false
    re_locked_ang = nil
    re_bw        = 0
    RunConsoleCommand("-showscores")
    RunConsoleCommand("stopsound")
    timer.Remove("MW2_RE_Music")
    timer.Remove("MW2_RE_Voice")
    timer.Remove("MW2_RE_Board")
    timer.Remove("MW2_RE_Done")
end

-- ============================================================
--  Net receive (Timer removed as requested)
-- ============================================================
net.Receive("MW2_RoundEnd", function()
    local winnerFac = net.ReadString()
    local loserFac  = net.ReadString()
    local winnerSc  = net.ReadInt(32)
    local loserSc   = net.ReadInt(32)

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local localFac  = ply:GetNW2String("MW2_Faction", "rangers")
    if localFac == "" then localFac = cookie.GetString("MW2_SelectedFaction", "rangers") end

    local kills     = math.max(0, ply:Frags())
    local fdata     = MW2Factions and MW2Factions[localFac]
    local voiceTag  = fdata and fdata.voice or nil
    local isVictory = (localFac == winnerFac)
    local hasTwo    = (loserFac ~= "" and MW2Factions and MW2Factions[loserFac] ~= nil)

    local leftFac   = localFac
    local rightFac  = isVictory and loserFac or winnerFac
    local leftSc    = isVictory and winnerSc or loserSc
    local rightSc   = isVictory and loserSc  or winnerSc

    local now = CurTime()

    -- Core state
    re_active      = true
    re_lock_time   = now
    re_bw          = 0
    re_winner      = winnerFac
    re_loser       = loserFac
    re_has_two     = hasTwo
    re_left_fac    = leftFac
    re_right_fac   = rightFac
    re_match_bonus = CalcMatchBonus(kills)
    re_mvlock      = true
    re_locked_ang  = nil

    -- Result text + glow color
    if winnerFac == "" then
        ws_result = "MW2_MP_DRAW"
        re_result_glow = Color(255, 255, 255)
    elseif isVictory then
        ws_result = "MW2_MP_VICTORY"
        re_result_glow = Color(0, 220, 80)
    else
        ws_result = "MW2_MP_DEFEAT"
        re_result_glow = Color(220, 60, 60)
    end

    -- Write-in state reset
    ws_result = language.GetPhrase(ws_result)
    ws_limit = language.GetPhrase("MW2_MP_SCORE_LIMIT_REACHED")

    -- Music
    if voiceTag then
        timer.Create("MW2_RE_Music", CFG.MUSIC_DELAY, 1, function()
            if not re_active then return end
            local tbl   = isVictory and VICTORY_MUSIC or DEFEAT_MUSIC
            local music = tbl[voiceTag]
            if music then MW2HUD_PlayAnnouncerSound(music, true) end
        end)
    end

    -- Voiceline
    if voiceTag then
        timer.Create("MW2_RE_Voice", CFG.VOICE_DELAY, 1, function()
			local victoryvoice = isVictory and "mission_success" or "mission_fail"

			local sound = MW2HUD_GetAnnouncerSound(basePath, { victoryvoice })
			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
        end)
    end

	-- Team Scores
	local teamsMap = {}

	for _, p in ipairs(player.GetAll()) do
		local fac = p:GetNW2String("MW2_Faction", "rangers")
		if fac ~= "" then
			teamsMap[fac] = teamsMap[fac] or {
				fac = fac,
				score = 0
			}

			teamsMap[fac].score = teamsMap[fac].score + math.max(0, p:Frags() * 100)
		end
	end

	local teams = {}

	for _, t in pairs(teamsMap) do
		table.insert(teams, t)
	end

	-- Ensure local faction is first (optional but consistent with HUD)
	local lp = LocalPlayer()
	local localFac = lp:GetNW2String("MW2_Faction", "rangers")

	table.sort(teams, function(a, b)
		return (a.score or 0) > (b.score or 0)
	end)

	MW2_HeaderQueue.Push({
		teams = teams,
		x = SX(CFG.ICON_X),
		y = SY(CFG.ICON_Y),
		multiple = true,
		persist = true,
		endTime = CFG.SCOREBOARD_DELAY,

		iconSize = S(CFG.ICON_SIZE),
		iconGap  = S(CFG.ICON_GAP),

		scoreY = SY(CFG.SCORE_Y),

		fonts = {
			score_pri = "MW2_RE_Sc_Pri",
			score_sec = "MW2_RE_Sc_Sec",
			score_shd = "MW2_RE_Sc_Shd",
		}
	})

	-- Text
	MW2_HeaderQueue.Push({
		text = ws_result,
		x = SX(CFG.RESULT_X),
		y = SY(CFG.RESULT_Y),
		color = re_result_glow,
		multiple = true,
		skipErase = true,
		persist = true,
		endTime = CFG.SCOREBOARD_DELAY,
		fonts = {
			pri = "MW2_RE_Re_Pri",
			sec = "MW2_RE_Re_Sec",
			shd = "MW2_RE_Re_Shd",
			sub = "MW2_ChalSub"
		}
	})

	MW2_HeaderQueue.Push({
		text = ws_limit,
		x = SX(CFG.LIMIT_X),
		y = SY(CFG.LIMIT_Y),
		color = Color(135, 135, 180),
		multiple = true,
		skipErase = true,
		persist = true,
		endTime = CFG.SCOREBOARD_DELAY,
		fonts = {
			pri = "MW2_RE_Li_Pri",
			sec = "MW2_RE_Li_Sec",
			shd = "MW2_RE_Li_Shd",
		}
	})

    -- Scoreboard opens at 6s, overlay drawing stops at 6s
    timer.Create("MW2_RE_Board", CFG.SCOREBOARD_DELAY, 1, function()
        if re_active then RunConsoleCommand("+showscores") end
    end)

    -- Auto-end
    timer.Create("MW2_RE_Done", CFG.DURATION, 1, RE_End)
	
	timer.Simple( CFG.POINTS_DELAY, function() -- Redundant, as it's not visible anyway. But included just in case.
		if _G.MW2_AddScore then _G.MW2_AddScore(re_match_bonus) end
	end)
end)

-- ============================================================
--  Think
-- ============================================================
hook.Add("Think", "MW2_RE_Think", function()
    if not re_active then return end

    local now = CurTime()
    re_bw = math.Clamp((now - re_lock_time) / CFG.BW_FADE_TIME, 0, 1)
end)

-- ============================================================
--  CreateMove
-- ============================================================
hook.Add("CreateMove", "MW2_RE_Input", function(cmd)
    if not re_mvlock then return end
    cmd:ClearMovement()

    cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	cmd:RemoveKey(IN_RELOAD)
	cmd:RemoveKey(IN_USE)
	cmd:RemoveKey(IN_JUMP)
	cmd:RemoveKey(IN_DUCK)
	cmd:RemoveKey(IN_SPEED)
	cmd:RemoveKey(IN_WALK)
	
    if CurTime() >= re_lock_time + 1.3 then
        if not re_locked_ang then re_locked_ang = cmd:GetViewAngles() end
        cmd:SetViewAngles(re_locked_ang)
    end
end)

-- ============================================================
--  HUDShouldDraw
-- ============================================================
hook.Add("HUDShouldDraw", "MW2_RE_HUD", function(name)
    if not re_active then return end
    if name == "CHudChat" or name == "CHudVoiceSteam" then return end
    return false
end)

-- ============================================================
--  RenderScreenspaceEffects
-- ============================================================
hook.Add("RenderScreenspaceEffects", "MW2_RE_BW", function()
    if not re_active or re_bw <= 0 then return end
    DrawColorModify({
        ["$pp_colour_addr"]       = 0, ["$pp_colour_addg"]       = 0, ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0, ["$pp_colour_contrast"]   = 1,
        ["$pp_colour_colour"]     = 1 - re_bw,
        ["$pp_colour_mulr"]       = 0, ["$pp_colour_mulg"]       = 0, ["$pp_colour_mulb"] = 0,
    })
end)

-- ============================================================
--  DrawOverlay
-- ============================================================
hook.Add("DrawOverlay", "MW2_RE_Draw", function()
    if not re_active then return end
    if not IsValid(LocalPlayer()) then return end
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()

    local el = CurTime() - re_lock_time
    if el < 0 then return end
    if el >= 6.0 then return end

    local iconAlpha = math.floor(math.Clamp(el / CFG.ICON_FADE_TIME, 0, 1) * 255)

	draw.SimpleTextOutlined( string.format( language.GetPhrase("MW2_MP_MATCH_BONUS_IS"), tostring(re_match_bonus) ), "MW2_RE_Bonus", SX(CFG.BONUS_X), SY(CFG.BONUS_Y), Color(240, 250, 110, iconAlpha), 1, 1, outlined and 1 or 0, Color(0,0,0, iconAlpha) )
end)