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
--  Glitch chars
-- ============================================================
local GLITCH = { "a", "¶", "Ð", "ق", "§", "ð", "œ", "ش", "Ф" }

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
--  Color Helper (Prevents nil color errors from halting the render hook)
-- ============================================================
local function GetSafeColor(col)
    if not col then return Color(255, 255, 255, 255) end
    return Color(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
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
--  DrawCODText
-- ============================================================
local function DrawCODText(text, fullText, pri, sec, shd, x, y, glow)
    surface.SetFont(pri)
    local fullW  = surface.GetTextSize(fullText)
    local startX = x - fullW / 2

    draw.SimpleText(text, sec, startX + 2, y + 1, glow,              TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, shd, startX + 2, y + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, pri, startX,     y,     Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- ============================================================
--  Spawn icon material cache
-- ============================================================
local RE_MATS = {}
local function GetSpawnMat(id)
    if RE_MATS[id] then return RE_MATS[id] end
    if not MW2Factions or not MW2Factions[id] then return nil end
    RE_MATS[id] = Material(MW2Factions[id].spawnIcon, "smooth")
    return RE_MATS[id]
end

-- ============================================================
--  Write-in helpers
-- ============================================================
local function utf8_sub(str, startChar, endChar)
    startChar = startChar or 1
    endChar = endChar or -1

    local startByte = utf8.offset(str, startChar)
    local endByte = utf8.offset(str, endChar + 1)

    if startByte then
        if endByte then
            return string.sub(str, startByte, endByte - 1)
        else
            return string.sub(str, startByte)
        end
    end

    return ""
end

local function AdvanceWrite(ws, interval, now, sound)
    if ws.done then return end
    local len = string.len(ws.str)
    if len == 0 then ws.done = true; return end
    if now >= ws.nxt and ws.written < len then
        ws.written = ws.written + 1
        ws.nxt     = now + interval
        if sound then surface.PlaySound("hud/cod_write.mp3") end
        if ws.written >= len then ws.done = true end
    end
end

local function WriteDisplay(ws)
    if ws.done then return ws.str end
    local disp = utf8_sub(ws.str, 0, ws.written)
    if string.len(ws.str) > 0 and ws.written < utf8.len(ws.str) then
        disp = disp .. GLITCH[math.random(1, #GLITCH)]
    end
    return disp
end

-- ============================================================
--  State
-- ============================================================
local re_active       = false
local re_lock_time    = 0
local re_bw           = 0

local re_winner       = " "
local re_loser        = " "
local re_has_two      = false
local re_left_fac     = " "
local re_right_fac    = " "
local re_match_bonus  = 0

-- Write-in states
local ws_result = { str = " ", written = 0, nxt = 0, done = false }
local ws_limit  = { str = " ", written = 0, nxt = 0, done = false }
local ws_left   = { str = " ", written = 0, nxt = 0, done = false }
local ws_right  = { str = " ", written = 0, nxt = 0, done = false }

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
        ws_result.str = "MW2_MP_DRAW"
        re_result_glow = Color(255, 255, 255)
    elseif isVictory then
        ws_result.str = "MW2_MP_VICTORY"
        re_result_glow = Color(0, 220, 80)
    else
        ws_result.str = "MW2_MP_DEFEAT"
        re_result_glow = Color(220, 60, 60)
    end

    -- Write-in state reset
    ws_result = { str = language.GetPhrase(ws_result.str), written = 0, nxt = now,       done = false }
    ws_limit  = { str = language.GetPhrase("MW2_MP_SCORE_LIMIT_REACHED"), written = 0, nxt = now, done = false }
    ws_left   = { str = tostring(leftSc or 0),  written = 0, nxt = now,       done = false }
    ws_right  = { str = tostring(rightSc or 0), written = 0, nxt = now,       done = false }

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

    -- Scoreboard opens at 6s, overlay drawing stops at 6s
    timer.Create("MW2_RE_Board", 6.0, 1, function()
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

    local el = now - re_lock_time

    AdvanceWrite(ws_result, 1.0 / math.max(1, string.len(ws_result.str)), now, true)

    AdvanceWrite(ws_left,  1.0 / math.max(1, string.len(ws_left.str)),  now, true)
    if re_has_two then
        AdvanceWrite(ws_right, 1.0 / math.max(1, string.len(ws_right.str)), now, false)
    end

    -- if el >= 1.0 then
        AdvanceWrite(ws_limit, 1.0 / math.max(1, string.len(ws_limit.str)), now, true)
    -- end
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

    local cx    = SX(CFG.ICON_X)
    local isz   = S(CFG.ICON_SIZE)
    local iconY = SY(CFG.ICON_Y)
    local gap   = S(CFG.ICON_GAP)
    local scx   = SX(CFG.SCORE_X)
    local scy   = SY(CFG.SCORE_Y)

    if re_has_two then
        local lx = cx - gap / 2 - isz / 2
        local rx = cx + gap / 2 + isz / 2

        local mL = GetSpawnMat(re_left_fac)
        if mL then
            surface.SetMaterial(mL); surface.SetDrawColor(255, 255, 255, iconAlpha)
            surface.DrawTexturedRect(lx - isz / 2, iconY, isz, isz)
        end
        local mR = GetSpawnMat(re_right_fac)
        if mR then
            surface.SetMaterial(mR); surface.SetDrawColor(255, 255, 255, iconAlpha)
            surface.DrawTexturedRect(rx - isz / 2, iconY, isz, isz)
        end

        local fdL = MW2Factions and MW2Factions[re_left_fac]
        local fdR = MW2Factions and MW2Factions[re_right_fac]
        local lScoreCX = scx - gap / 2 - isz / 2
        local rScoreCX = scx + gap / 2 + isz / 2

        if fdL then
            DrawCODText(WriteDisplay(ws_left), ws_left.str,
                "MW2_RE_Sc_Pri", "MW2_RE_Sc_Sec", "MW2_RE_Sc_Shd",
                lScoreCX, scy, GetSafeColor(fdL.glow))
        end
        if fdR then
            DrawCODText(WriteDisplay(ws_right), ws_right.str,
                "MW2_RE_Sc_Pri", "MW2_RE_Sc_Sec", "MW2_RE_Sc_Shd",
                rScoreCX, scy, GetSafeColor(fdR.glow))
        end
    else
        local mat = GetSpawnMat(re_winner)
        if mat then
            surface.SetMaterial(mat); surface.SetDrawColor(255, 255, 255, iconAlpha)
            surface.DrawTexturedRect(cx - isz / 2, iconY, isz, isz)
        end
        local fd = MW2Factions and MW2Factions[re_winner]
        if fd then
            DrawCODText(WriteDisplay(ws_left), ws_left.str,
                "MW2_RE_Sc_Pri", "MW2_RE_Sc_Sec", "MW2_RE_Sc_Shd",
                scx, scy, GetSafeColor(fd.glow))
        end
    end

    DrawCODText(WriteDisplay(ws_result), ws_result.str,
        "MW2_RE_Re_Pri", "MW2_RE_Re_Sec", "MW2_RE_Re_Shd",
        SX(CFG.RESULT_X), SY(CFG.RESULT_Y), re_result_glow)

    -- if el >= 1.0 then
        DrawCODText(WriteDisplay(ws_limit), ws_limit.str,
            "MW2_RE_Li_Pri", "MW2_RE_Li_Sec", "MW2_RE_Li_Shd",
            SX(CFG.LIMIT_X), SY(CFG.LIMIT_Y), Color(135, 135, 180))
    -- end

	draw.SimpleTextOutlined( string.format( language.GetPhrase("MW2_MP_MATCH_BONUS_IS"), tostring(re_match_bonus) ), "MW2_RE_Bonus", SX(CFG.BONUS_X), SY(CFG.BONUS_Y), Color(240, 250, 110, iconAlpha), 1, 1, outlined and 1 or 0, Color(0,0,0, iconAlpha) )
end)