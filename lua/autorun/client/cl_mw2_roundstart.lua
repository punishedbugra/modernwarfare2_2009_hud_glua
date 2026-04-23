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
    HEADER_X         = 960,
    HEADER_Y         = 150,
    HEADER_FONT_SIZE = 64,
    HEADER_WRITE     = 2.1,
    HEADER_ERASE     = 0.7,

    ICON_X    = 896,
    ICON_Y    = 180,
    ICON_SIZE = 134,
    ICON_FADE = 1.0,

    TIMER_X          = 960,
    TIMER_Y          = 540,
    TIMER_FONT_SIZE  = 80,
    STATIC_FONT_SIZE = 32,
    STATIC_Y_OFFSET  = -85,

    OBJ_X         = 960,
    OBJ_Y         = 205,
    OBJ_FONT_SIZE = 46,
    OBJ_WRITE     = 2.1,
    OBJ_HANG      = 3.0,
    OBJ_ERASE     = 0.7,
}

CreateClientConVar("mw2_selected_gamemode", "war", true, false)

local function MW2_RS_InitFonts()
    surface.CreateFont("MW2_RS_H_Pri", { font = "Carbon Regular", size = S(CFG.HEADER_FONT_SIZE), weight = 800,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_RS_H_Sec", { font = "Carbon Regular", size = S(CFG.HEADER_FONT_SIZE), weight = 800,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_RS_H_Shd", { font = "Carbon Regular", size = S(CFG.HEADER_FONT_SIZE), weight = 800, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont("MW2_RS_O_Pri", { font = "Carbon Regular", size = S(CFG.OBJ_FONT_SIZE), weight = 10,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_RS_O_Sec", { font = "Carbon Regular", size = S(CFG.OBJ_FONT_SIZE), weight = 10,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_RS_O_Shd", { font = "Carbon Regular", size = S(CFG.OBJ_FONT_SIZE), weight = 400, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont("MW2_RS_S_Pri", { font = "Carbon Regular", size = S(CFG.STATIC_FONT_SIZE), weight = 400, antialias = true, shadow = true })

    surface.CreateFont("MW2_RS_Timer", { font = "BankGothic Md BT", size = S(CFG.TIMER_FONT_SIZE), weight = 400, antialias = true, shadow = true })
end

MW2_RS_InitFonts()

hook.Add("OnScreenSizeChanged", "MW2_RS_ReinitFonts", function()
    MW2_RS_InitFonts()
end)

local MW2_RS_GM_NAMES = {
    "war", -- Team Deathmatch
    "dm", -- Free-for-All
    "dom", -- Domination
    "sd", -- Search & Destroy
    "sab", -- Sabotage
    "ctf", -- Capture the Flag
    "hq", -- Headquarters
    "oneflag", -- One Flag CTF
    "arena", -- Arena
    "dd", -- Demolition
    "gtnw", -- Global Thermonuclear War
}

local MW2_RS_OBJECTIVES = {
    ["war"] = "MW2_MP_OBJ_WAR_HINT", -- TDM
    ["dm"] = "MW2_MP_OBJ_DM_HINT", -- FFA
    ["dom"] = "MW2_OBJECTIVES_DOM_HINT", -- Domination
    ["sd"] = "MW2_OBJECTIVES_SD_ATTACKER_HINT", -- Search & Destroy
    ["sab"] = "MW2_OBJECTIVES_SAB_HINT", -- Sabotage
    ["ctf"] = "MW2_OBJECTIVES_CTF_HINT", -- Capture the Flag
    ["hq"] = "MW2_OBJECTIVES_KOTH_HINT", -- Headquarters
    ["oneflag"] = "MW2_OBJECTIVES_ONE_FLAG_ATTACKER_HINT", -- One Flag CTF
    ["arena"] = "MW2_OBJECTIVES_ARENA_HINT", -- Arena
    ["dd"] = "MW2_OBJECTIVES_SD_ATTACKER_HINT", -- Demolition
    ["gtnw"] = "MW2_OBJECTIVES_GTNW_HINT", -- Global Thermonuclear War
}

local MW2_RS_ANNOUNCER_TAG = {
    ["war"] = "team_deathmtch",
    ["dm"] = "freeforall",
    ["dom"] = "domination",
    ["sd"] = "searchdestroy",
    ["sab"] = "sabotage",
    ["ctf"] = "captureflag",
    ["hq"] = "headquarters",
    ["oneflag"] = "one_flag",
    ["arena"] = "arena",
    ["dd"] = "demolition",
    ["gtnw"] = "gtw",
}

local MW2_RS_ANNOUNCER_BOOST = {
    ["war"] = "boost",
    ["dm"] = "boost",
    ["dom"] = "capture_obj",
    ["sd"] = "objs_destroy",
    ["sab"] = "obj_destroy",
    ["ctf"] = "capture_obj",
    ["hq"] = "capture_obj",
    ["oneflag"] = "capture_obj",
    ["arena"] = "boost",
    ["dd"] = "objs_destroy",
    ["gtnw"] = "capture_obj",
}

local MW2_RS_SPAWN_MUSIC = {
    US = "music/US/hz_mp_usspawn_1.mp3",
    UK = "music/UK/hz_mp_ukspawn_1.mp3",
    NS = "music/NS/hz_mp_nsspawn_1.mp3",
    RU = "music/RU/hz_mp_ruspawn_1.mp3",
    AB = "music/AB/hz_mp_abspawn_1.mp3",
    PG = "music/PG/hz_mp_pgspawn_1.mp3",
}

local OBJ_GLOW           = Color(0, 220, 80)
local COUNTDOWN_DURATION = 5

local rs_active      = false
local rs_movement_locked = false
local rs_phase       = "idle"
local rs_seq_start   = 0
local rs_phase_start = 0

local rs_short      = ""
local rs_glow       = Color(255, 255, 255)
local rs_icon_mat   = nil
local rs_icon_alpha = 0

local rs_remaining = COUNTDOWN_DURATION
local rs_last_dig  = -1
local rs_dig_scale = 1.0

local rs_bw         = 0
local rs_boost_done = false
local rs_locked_ang = nil
local rs_gamemode	= "war"

local rs_header = nil
local rs_objective = nil

local sb_open = false

hook.Add("ScoreboardShow", "MW2_RS_SBShow", function() sb_open = true  end)
hook.Add("ScoreboardHide", "MW2_RS_SBHide", function() sb_open = false end)

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

local function BlankStep(blanks, text, n)
    local avail = {}
    for i = 1, utf8.len(text) do
        local found = false
        for _, b in ipairs(blanks) do
            if b == i then found = true; break end
        end
        if not found then avail[#avail + 1] = i end
    end
    for i = 1, math.min(n, #avail) do
        local idx = math.random(1, #avail)
        blanks[#blanks + 1] = avail[idx]
        table.remove(avail, idx)
    end
end

local function ApplyBlanks(text, blanks)
    local chars = {}
    for i = 1, utf8.len(text) do chars[i] = utf8.sub(text, i, i) end
    for _, b in ipairs(blanks) do
        if chars[b] then chars[b] = " " end
    end
    return table.concat(chars)
end

local function DrawCODText(text, fullText, pri, sec, shd, x, y, glow)
    surface.SetFont(pri)
    local fullW = surface.GetTextSize(fullText)

    local startX = x - fullW / 2

    draw.SimpleText(text, sec, startX + 2, y + 1, glow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, shd, startX + 2, y + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, pri, startX,     y,     Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

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
            -- draw.SimpleText(char, font, runX - o, y,     outlineCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            -- draw.SimpleText(char, font, runX + o, y,     outlineCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            -- draw.SimpleText(char, font, runX,     y - o, outlineCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            -- draw.SimpleText(char, font, runX,     y + o, outlineCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- end

        -- draw.SimpleText(char, font, runX, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		draw.SimpleTextOutlined( char, font, runX, y, color, 0, 1, o, outlineCol )

        local w = surface.GetTextSize(char)
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            runX = runX + w + gap
        end
    end
end

local function MW2_RS_Start(gamemode)
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    local fkey = lp:GetNW2String("MW2_Faction", "rangers")
    if not MW2Factions[fkey] then fkey = "rangers" end
    local fdata = MW2Factions[fkey]

    rs_active      = true
    rs_movement_locked = true
    rs_phase       = "faction"
    rs_seq_start   = CurTime()
    rs_phase_start = CurTime()
    rs_boost_done  = false
	rs_gamemode    = gamemode

    -- Lock and explicitly reset angle pitch/roll upon respawn
    rs_locked_ang = lp:EyeAngles()
    rs_locked_ang.p = 0
    rs_locked_ang.r = 0

    rs_short      = fdata.voice
    rs_glow       = fdata.glow
    rs_icon_mat   = Material(fdata.spawnIcon, "smooth")
    rs_icon_alpha = 0

    rs_remaining = COUNTDOWN_DURATION
    rs_last_dig  = -1
    rs_dig_scale = 1.0

    rs_bw = 1

	MW2_HeaderQueue.Push({
		text = language.GetPhrase(fdata.name),
		x = SX(CFG.HEADER_X),
		y = SY(CFG.HEADER_Y),
		color = rs_glow,
		
		-- iconX = SX(CFG.ICON_X),
		iconY = SY(CFG.ICON_Y),
		iconSize = S(CFG.ICON_SIZE),

		fonts = {
			pri = "MW2_RS_H_Pri",
			sec = "MW2_RS_H_Sec",
			shd = "MW2_RS_H_Shd"
		},

		icon = rs_icon_mat
	})

	timer.Simple( 0.1, function() -- Tiny delay for round restart
		if GetConVar("mw2_enable_music"):GetBool() and MW2_RS_SPAWN_MUSIC[rs_short] then
			surface.PlaySound(MW2_RS_SPAWN_MUSIC[rs_short])
		end
		
		local sound = MW2HUD_GetAnnouncerSound(basePath, { MW2_RS_ANNOUNCER_TAG[gamemode] or "team_deathmtch" })
		if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
	end)
end

local function MW2_RS_End()
    rs_active     = false
    rs_movement_locked = false
    rs_phase      = "idle"
    rs_locked_ang = nil
end

hook.Add("Think", "MW2_RS_Think", function()
    if not rs_active then return end

    local now = CurTime()

	if rs_header then
		rs_header:Update()
	end

	if rs_objective then
		rs_objective:Update()
	end

    if rs_phase == "faction" then
        local elapsed = now - rs_seq_start
        rs_remaining  = math.max(0, COUNTDOWN_DURATION - math.floor(elapsed))
        
        local exact_time_left = COUNTDOWN_DURATION - elapsed

        if exact_time_left > 3 then
            rs_bw = 1
        elseif exact_time_left > 0 then
            rs_bw = exact_time_left / 3
        else
            rs_bw = 0
        end

        if elapsed >= COUNTDOWN_DURATION then
            rs_phase       = "erase_faction"
            rs_phase_start = now
            rs_movement_locked = false
        end

    elseif rs_phase == "erase_faction" then
        local erase_t = math.max(0.01, CFG.HEADER_ERASE)
        local elapsed = now - rs_phase_start

        if not rs_boost_done then
            rs_boost_done = true
			local sound = MW2HUD_GetAnnouncerSound(basePath, { MW2_RS_ANNOUNCER_BOOST[rs_gamemode] or MW2_RS_ANNOUNCER_BOOST["war"] })
			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
        end

        if elapsed >= erase_t then
            rs_phase       = "objective"
            rs_phase_start = now
            MW2_HeaderQueue.Push({
				text = language.GetPhrase(MW2_RS_OBJECTIVES[rs_gamemode] or MW2_RS_OBJECTIVES["war"]),
				x = SX(CFG.OBJ_X),
				y = SY(CFG.OBJ_Y),
				color = OBJ_GLOW,

				writeSpeed = 12,
				holdTime   = CFG.OBJ_HANG,
				eraseTime  = CFG.OBJ_ERASE,

				fonts = {
					pri = "MW2_RS_O_Pri",
					sec = "MW2_RS_O_Sec",
					shd = "MW2_RS_O_Shd"
				}
			})
        end

	elseif rs_phase == "objective" then
		if rs_objective and rs_objective:IsDone() then
			MW2_RS_End()
		end
	end
end)

hook.Add("HUDPaint", "MW2_RS_Draw", function()
    if not rs_active then return end
    if sb_open then return end
    if not IsValid(LocalPlayer()) then return end
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()

    local tx  = SX(CFG.TIMER_X)
    local ty  = SY(CFG.TIMER_Y)
    local syo = SY(CFG.STATIC_Y_OFFSET)

    if rs_phase == "faction" then
        local disp = math.max(0, rs_remaining)

        if disp ~= rs_last_dig then
            rs_last_dig  = disp
            rs_dig_scale = 1.8
        end
        rs_dig_scale = math.Approach(rs_dig_scale, 1, FrameTime() * 6)

        if disp > 0 then
            local tMat = Matrix()
            tMat:Translate(Vector(tx, ty, 0))
            tMat:Scale(Vector(rs_dig_scale, rs_dig_scale, 1))
            tMat:Translate(Vector(-tx, -ty, 0))

            cam.PushModelMatrix(tMat)
                DrawSqueezedText(disp, "MW2_RS_Timer", tx, ty, Color(255,255,100), -2, -6, 1, -4, outlined and 1 or 0)
            cam.PopModelMatrix()

			draw.SimpleTextOutlined( "#MW2_MP_MATCH_STARTING_IN", "MW2_RS_S_Pri", tx, ty + syo, Color(255,255,255), 1, 1, outlined and 1 or 0, Color(0,0,0) )
        end
    end
end)

hook.Add("RenderScreenspaceEffects", "MW2_RS_BW", function()
    if not rs_active then return end
    if sb_open then return end
    if rs_bw <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"]       = 0,
        ["$pp_colour_addg"]       = 0,
        ["$pp_colour_addb"]       = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"]   = 1,
        ["$pp_colour_colour"]     = 1 - rs_bw,
        ["$pp_colour_mulr"]       = 0,
        ["$pp_colour_mulg"]       = 0,
        ["$pp_colour_mulb"]       = 0,
    })
end)

hook.Add("CreateMove", "MW2_RS_BlockInput", function(cmd)
    if not rs_movement_locked then return end
    cmd:ClearMovement()
	
    cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	cmd:RemoveKey(IN_RELOAD)
	cmd:RemoveKey(IN_USE)
	cmd:RemoveKey(IN_JUMP)
	cmd:RemoveKey(IN_DUCK)
	cmd:RemoveKey(IN_SPEED)
	cmd:RemoveKey(IN_WALK)
	
    if rs_locked_ang then
        cmd:SetViewAngles(rs_locked_ang)
    end
end)

net.Receive("MW2_RoundStart", function()
    local gamemode = net.ReadString()
    timer.Simple(0, function()
        MW2_RS_Start(gamemode)
    end)
end)