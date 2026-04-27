CoDHUD.RegisterHUD( "mw3", "#CoDHUD.Type.MW3", true )

local hudtype = "mw3"

CoDHUD = CoDHUD or {}
CoDHUD[hudtype] = CoDHUD[hudtype] or {}
CoDHUD.Factions = CoDHUD.Factions or {}
CoDHUD.Gamemodes = CoDHUD.Gamemodes or {}

-- [[ SPECIAL KILLFEED ICONS ]]
killicon.Add("CoDHUD_MW3_Suicide", hudtype .. "/killfeed/death_suicide.png", Color(255, 255, 255, 0))
killicon.Add("CoDHUD_MW3_Headshot", hudtype .. "/killfeed/death_headshot.png", Color(255, 255, 255, 0))

-- [[ SUSPENSE ]]
CoDHUD[hudtype].SuspenseTracks = {
    "music/mw3/bt_mp_suspense_01.mp3",
    "music/mw3/bt_mp_suspense_04.mp3",
    "music/mw3/bt_mp_suspense_05.mp3",
    "music/mw3/bt_mp_suspense_06.mp3",
    "music/mw3/bt_mp_suspense_07.mp3",
    "music/mw3/bt_mp_suspense_08.mp3",
}

-- [[ FACTIONS ]]
CoDHUD.Factions[hudtype] = {
	["delta"] = {
		name = "MW3_MP_DELTA_NAME",
		short = "MW3_MP_DELTA_SHORT_NAME",
		voicepath = "us/mp/us_1mc_",
		spawntheme = "bt_mp_spawn_05.mp3",
		victorytheme = "bt_mp_winning_02.mp3",
		defeattheme = "bt_mp_defeat_04.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_delta.png",
		scoreIcon = hudtype .. "/factions/faction_128_delta_fade.png",
		color = Color(255*0.345, 255*0.447, 255*0.631),
		killfeedcol = Color(255*0.345, 255*0.447, 255*0.631),
		glow = Color(255*0.345, 255*0.447, 255*0.631),
		order = 1
	},
	["sas"] = {
		name = "MW3_MP_SAS",
		short = "MW3_MP_SAS_SHORT_NAME",
		voicepath = "uk/mp/uk_1mc_",
		spawntheme = "bt_mp_spawn_04.mp3",
		victorytheme = "bt_mp_winning_07.mp3",
		defeattheme = "bt_mp_defeat_03.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_sas.png",
		scoreIcon = hudtype .. "/factions/faction_128_sas_fade.png",
		color = Color(255*0.2, 255*0.2, 255*0.2),
		killfeedcol = Color(255*0.2, 255*0.2, 255*0.2),
		glow = Color(255*0.2, 255*0.2, 255*0.2),
		order = 2
	},
	["gign"] = {
		name = "MW3_MP_GIGN",
		short = "MW3_MP_GIGN_SHORT_NAME",
		voicepath = "fr/mp/fr_1mc_",
		spawntheme = "bt_mp_spawn_01.mp3",
		victorytheme = "bt_mp_winning_06.mp3",
		defeattheme = "bt_mp_defeat_05 .mp3",
		spawnIcon = hudtype .. "/factions/faction_128_gign_black.png",
		scoreIcon = hudtype .. "/factions/faction_128_gign_fade.png",
		color = Color(255*0.2, 255*0.2, 255*0.2),
		killfeedcol = Color(255*0.2, 255*0.2, 255*0.2),
		glow = Color(255*0.2, 255*0.2, 255*0.2),
		order = 3
	},
	["innercircle"] = {
		name = "MW3_MP_INNERCIRCLE_NAME",
		short = "MW3_MP_INNERCIRCLE_SHORT_NAME",
		voicepath = "ic/mp/ic_1mc_",
		spawntheme = "bt_mp_spawn_03.mp3",
		victorytheme = "bt_mp_winning_01.mp3",
		defeattheme = "bt_mp_defeat_01.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_ic_black.png",
		scoreIcon = hudtype .. "/factions/faction_128_ic_fade.png",
		color = Color(255*0.6, 255*0.263, 255*0.243),
		killfeedcol = Color(255*0.6, 255*0.263, 255*0.243),
		glow = Color(255*0.6, 255*0.263, 255*0.243),
		order = 4
	},
	["militia"] = {
		name = "MW3_MP_AFRICA_MILITIA_NAME",
		short = "MW3_MP_AFRICA_MILITIA_SHORT_NAME",
		voicepath = "af/mp/af_1mc_",
		spawntheme = "bt_mp_spawn_08.mp3",
		victorytheme = "bt_mp_winning_05.mp3",
		defeattheme = "bt_mp_defeat_09b.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_africa.png",
		scoreIcon = hudtype .. "/factions/faction_128_africa_fade.png",
		color = Color(255*0.6, 255*0.263, 255*0.243),
		killfeedcol = Color(255*0.6, 255*0.263, 255*0.243),
		glow = Color(255*0.6, 255*0.263, 255*0.243),
		order = 5
	},
	["ussr"] = {
		name = "MW3_MP_SPETSNAZ_NAME",
		short = "MW3_MPUI_SPETSNAZ_SHORT",
		voicepath = "ru/mp/ru_1mc_",
		spawntheme = "bt_mp_spawn_07.mp3",
		victorytheme = "bt_mp_winning_04.mp3",
		defeattheme = "bt_mp_defeat_10.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_ussr.png",
		scoreIcon = hudtype .. "/factions/faction_128_ussr_fade.png",
		color = Color(255*0.6, 255*0.263, 255*0.243),
		killfeedcol = Color(255*0.6, 255*0.263, 255*0.243),
		glow = Color(255*0.6, 255*0.263, 255*0.243),
		order = 6
	},
	["pmc"] = {
		name = "MW3_MP_PMC_NAME",
		short = "MW3_MP_PMC_SHORT_NAME",
		voicepath = "pc/mp/pc_1mc_",
		spawntheme = "bt_mp_spawn_02.mp3",
		victorytheme = "bt_mp_winning_03.mp3",
		defeattheme = "bt_mp_defeat_07.mp3",
		spawnIcon = hudtype .. "/factions/faction_128_pmc.png",
		scoreIcon = hudtype .. "/factions/faction_128_pmc_fade.png",
		color = Color(255*0.345, 255*0.447, 255*0.631),
		killfeedcol = Color(255*0.345, 255*0.447, 255*0.631),
		glow = Color(255*0.345, 255*0.447, 255*0.631),
		order = 7
	},
}

-- [[ TEXT STRINGS & VOICE CALLOUTS ]]
CoDHUD[hudtype].TextStrings = {
	connected = "MW2_MP_CONNECTED",
	disconnected = "MW2_MP_DISCONNECTED",
	leftgame = "MW2_EXE_LEFTGAME",
	
	re = {
		draw = "MW2_MP_DRAW",
		win = "MW2_MP_VICTORY",
		lose = "MW2_MP_DEFEAT",
		result = {
			score = "MW2_MP_SCORE_LIMIT_REACHED",
			time = "???"
		}
	},
	scorebar = {
		tied = "MW2_MPUI_TIED_CAPS",
		winning = "MW2_MPUI_WINNING_CAPS",
		losing = "MW2_MPUI_LOSING_CAPS"
	},
}

CoDHUD[hudtype].VoiceCallouts = {
	winningmusic = "music/hz_mp_opfor_victory.mp3",
	losingmusic = "music/hz_mp_time_out_losing.mp3",
	
	winningfight = { "winning" },
	losingfight = { "losing" },
	
	leadtaken = "lead_taken",
	leadlost = "lead_lost",
	leadtied = "tied",
	
	missionwin = "mission_success",
	missionlose = "mission_fail",
}

local function GetFactionColor(ent)
    if not IsValid(ent) then return Color(255,255,255) end
    local faction = ent:GetNW2String("CoDHUD_Faction", "none")

    if CoDHUD.Factions[hudtype][faction] and CoDHUD.Factions[hudtype][faction].killfeedcol then 
		return CoDHUD.Factions[hudtype][faction].killfeedcol
	end

    return Color(255,255,255)
end

-- [[ GAMEMODES ]]
CoDHUD.Gamemodes[hudtype] = {
	{ "#MW2_MPUI_WAR", "war" },
	{ "#MW2_MPUI_DEATHMATCH", "dm" },
	{ "#MW2_MPUI_DOMINATION", "dom" },
	{ "#MW2_MPUI_SEARCH_AND_DESTROY", "sd" },
	{ "#MW2_MPUI_SABOTAGE", "sab" },
	{ "#MW2_MPUI_CAPTURE_THE_FLAG", "ctf" },
	{ "#MW2_MPUI_HEADQUARTERS", "hq" },
	{ "#MW2_MPUI_DD", "dd" },
}

CoDHUD.Gamemodes[hudtype].Hints = {
    ["war"] = "MW2_MP_OBJ_WAR_HINT", -- TDM
    ["dm"] = "MW2_MP_OBJ_DM_HINT", -- FFA
    ["dom"] = "MW2_OBJECTIVES_DOM_HINT", -- Domination
    ["sd"] = "MW2_OBJECTIVES_SD_ATTACKER_HINT", -- Search & Destroy
    ["sab"] = "MW2_OBJECTIVES_SAB_HINT", -- Sabotage
    ["ctf"] = "MW2_OBJECTIVES_CTF_HINT", -- Capture the Flag
    ["hq"] = "MW2_OBJECTIVES_KOTH_HINT", -- Headquarters
    ["dd"] = "MW2_OBJECTIVES_SD_ATTACKER_HINT", -- Demolition
}

CoDHUD.Gamemodes[hudtype].Callouts = {
    ["war"] = "team_deathmtch",
    ["dm"] = "freeforall",
    ["dom"] = "domination",
    ["sd"] = "searchdestroy",
    ["sab"] = "sabotage",
    ["ctf"] = "captureflag",
    ["hq"] = "headquarters",
    ["dd"] = "demolition",
}

CoDHUD.Gamemodes[hudtype].Boosts = {
    ["war"] = "boost",
    ["dm"] = "boost",
    ["dom"] = "capture_obj",
    ["sd"] = "objs_destroy",
    ["sab"] = "obj_destroy",
    ["ctf"] = "capture_obj",
    ["hq"] = "capture_obj",
    ["dd"] = "objs_destroy",
}

-- [[ HELPERS ]]
local function DrawSqueezedScore(val, x, y, alpha)
	local textCol   = Color(255, 255, 50, alpha)
	local shadowCol = Color(0, 0, 0, alpha * 0.8)
	local s_val     = tostring(val)
	local partPlus  = "+"

	surface.SetFont("MW2_Score_Plus")
	local wP  = surface.GetTextSize(partPlus)
	local gapPlus = CoDHUD_SX(-6)

	surface.SetFont("MW2_Score_Main")

	local totalW = wP + gapPlus
	for i = 1, #s_val do
		local char = s_val:sub(i, i)
		local w    = surface.GetTextSize(char)
		totalW = totalW + w
		if i < #s_val then
			local gap = (char == "1") and CoDHUD_SX(-11) or CoDHUD_SX(-5)
			totalW = totalW + gap
		end
	end

	local curX = x - (totalW / 2)

	local function DrawComponent(txt, font, px, py)
		draw.SimpleTextOutlined(txt, font, px, py, textCol, 0, 1, 0, shadowCol)
		surface.SetFont(font)
		local w = surface.GetTextSize(txt)
		return w
	end

	local runX = curX
	runX = runX + DrawComponent(partPlus, "MW2_Score_Plus", runX, y) + gapPlus

	for i = 1, #s_val do
		local char = s_val:sub(i, i)
		local w    = DrawComponent(char, "MW2_Score_Main", runX, y)
		if i < #s_val then
			local gap = (char == "1") and CoDHUD_SX(-11) or CoDHUD_SX(-5)
			runX = runX + w + gap
		end
	end
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

		draw.SimpleTextOutlined( char, font, runX, y, color, 0, 0, o, outlineCol )

        local w = surface.GetTextSize(char)
        if i < #str then
            local gap = (char == "1") and squeezeOne or (nextChar == "1" and squeezeOneBefore or squeeze)
            runX = runX + w + gap
        end
    end
end

-- [[ HUD ELEMENTS ]]
local function challengecomplete( ... )
    local header = select(1, ...)
    local level = select(2, ...)
    local sub = select(3, ...)
	local subval = select(4, ...)
    local align = select(5, ...)
	
	local function ResolvePrefix(prefix, text)
		if not prefix or prefix == "" then return text end
		
		if string.find(text, " ") then
			return language.GetPhrase(text)
		end
		
		if subval then
			return string.format( language.GetPhrase(prefix .. text), subval )
		else
			return language.GetPhrase(prefix .. text)
		end
	end
	
    CoDHUD_HeaderQueue.Push({
        text = CoDHUD_ChallengeTitle(header, level),
        subtext = (sub and sub ~= "") and ResolvePrefix("MW2_CHALLENGE_", sub) or nil,
        x = 1890,
        y = 120,
        color = Color(0,220,80),
        fonts = {
            pri = "MW2_ChalHeader_Pri",
            sec = "MW2_ChalHeader_Sec",
            shd = "MW2_ChalHeader_Shd",
            sub = "MW2_ChalSub"
        },
		align = "right"
    })

    surface.PlaySound("hud/mp_challengecomplete_metal_2.mp3")
end
CoDHUD[hudtype].ChallengeComplete = challengecomplete

local function rs_obj( ... )
	local text = select(1, ...)

	CoDHUD_HeaderQueue.Push({
		text = language.GetPhrase(text),
		x = CoDHUD_SX(960),
		y = CoDHUD_SY(205),
		color = Color(0, 220, 80),
		fonts = {
			pri = "MW2_RS_O_Pri",
			sec = "MW2_RS_O_Sec",
			shd = "MW2_RS_O_Shd"
		}
	})
end
CoDHUD[hudtype].RoundStartObjective = rs_obj

local function rs_title( ... )
	local text = select(1, ...)
	local glow = select(2, ...)
	local logo = select(3, ...)

	CoDHUD_HeaderQueue.Push({
		text = language.GetPhrase(text),
		x = CoDHUD_SX(960),
		y = CoDHUD_SY(150),
		color = glow,

		iconY = CoDHUD_SY(180),
		iconSize = CoDHUD_S(134),

		fonts = {
			pri = "MW2_RS_H_Pri",
			sec = "MW2_RS_H_Sec",
			shd = "MW2_RS_H_Shd"
		},

		icon = logo
	})
end
CoDHUD[hudtype].RoundStart = rs_title

local function rs_timer( ... )
	local disp = select(1, ...)
	
	local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

    local tx  = CoDHUD_SX(960)
    local ty  = CoDHUD_SY(540)
    local syo = CoDHUD_SY(-85)

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
			draw.SimpleTextOutlined( disp, "MW2_RS_Timer", tx, ty, Color(255,255,100), 1, 1, outlined and 1 or 0, Color(0,0,0) )
		cam.PopModelMatrix()

		draw.SimpleTextOutlined( "#MW2_MP_MATCH_STARTING_IN", "MW2_RS_S_Pri", tx, ty + syo, Color(255,255,255), 1, 1, outlined and 1 or 0, Color(0,0,0) )
	end
end
CoDHUD[hudtype].RoundStartTimer = rs_timer

local function re_teams( ... )
    local teams = select(1, ...)
    local ws_result = select(2, ...)
    local ws_limit = select(3, ...)
    local re_result_glow = select(4, ...)
    local CFG = select(5, ...)

    local multiplier = 100

    -- Apply visual scaling only
    local scaledTeams = {}
    for k, v in ipairs(teams) do
        scaledTeams[k] = {
            fac = v.fac,
            score = (v.score or 0) * multiplier
        }
    end

    -- Teams
    CoDHUD_HeaderQueue.Push({
        teams = scaledTeams, -- use scaled version
        x = CoDHUD_SX(960),
        y = CoDHUD_SY(400),
        multiple = true,
        persist = true,
        endTime = CFG.SCOREBOARD_DELAY,

        iconSize = CoDHUD_S(184),
        iconGap  = CoDHUD_S(80),
        scoreY = CoDHUD_SY(620),

        fonts = {
            score_pri = "MW2_RE_Sc_Pri",
            score_sec = "MW2_RE_Sc_Sec",
            score_shd = "MW2_RE_Sc_Shd",
        }
    })

	-- Text
	CoDHUD_HeaderQueue.Push({
		text = ws_result,
		x = CoDHUD_SX(960),
		y = CoDHUD_SY(240),
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

	CoDHUD_HeaderQueue.Push({
		text = ws_limit,
		x = CoDHUD_SX(960),
		y = CoDHUD_SY(330),
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

end
CoDHUD[hudtype].RoundEnd = re_teams

local function re_bonus( ... )
	local re_lock_time = select(1, ...)
	local re_match_bonus = select(2, ...)

	local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

    local el = CurTime() - re_lock_time
    if el < 0 then return end
    if el >= 6.0 then return end

    local iconAlpha = math.floor(math.Clamp(el / 1.0, 0, 1) * 255)

	draw.SimpleTextOutlined( string.format( language.GetPhrase("MW2_MP_MATCH_BONUS_IS"), tostring(re_match_bonus) ), "MW2_RE_Bonus", CoDHUD_SX(960), CoDHUD_SY(720), Color(240, 250, 110, iconAlpha), 1, 1, outlined and 1 or 0, Color(0,0,0, iconAlpha) )
end
CoDHUD[hudtype].RoundEndBonus = re_bonus

local function hitmarker( ... )
	local hitTime = select(1, ...)
	local ct = CurTime()
	local cx, cy = ScrW() / 2, ScrH() / 2

	local matHit = Material(hudtype .. "/icons/hitmarker.png", "mips smooth")

	local fade = math.Clamp((hitTime - ct) / 0.9, 0, 1) * 255
	surface.SetMaterial(matHit)
	surface.SetDrawColor(255, 255, 255, fade)
	local size = 36
	surface.DrawTexturedRect(cx - (size / 2), cy - (size / 2), size, size)
end
CoDHUD[hudtype].Hitmarker = hitmarker

local function xp( ... )
	local animtime = select(1, ...)
	local scoreTime = select(2, ...)
	local finalAlpha = select(3, ...)
	local scoreScale = select(4, ...)
	local currentPulseAlpha = select(5, ...)
	local scoreVal = select(6, ...)

	local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

	local cx, cy = ScrW() / 2, ScrH() / 2
	local drawAlpha = (currentPulseAlpha / 255) * finalAlpha
	local drawY     = cy - CoDHUD_SY(140)

	local mat = Matrix()
	mat:Translate(Vector(cx, drawY, 0))
	mat:Scale(Vector(scoreScale, scoreScale, 1))
	mat:Translate(Vector(-cx, -drawY, 0))

	cam.PushModelMatrix(mat)
		DrawSqueezedScore(scoreVal, cx, drawY, drawAlpha)
	cam.PopModelMatrix()
end
CoDHUD[hudtype].XP = xp

local function dmg_dir( ... )
	local attackers = select(1, ...)

    local cx, cy = ScrW() / 2, ScrH() / 2
	local matDamage = Material(hudtype .. "/icons/hit_direction.png", "mips smooth")

	for i = #attackers, 1, -1 do
		local v = attackers[i]

		-- Fade Logic
		if CurTime() > v.time - 1 then 
			v.alpha = math.Approach(v.alpha, 0, FrameTime() * 400)
			if v.alpha <= 0 then table.remove(attackers, i) continue end
		end

		-- Live Tracking: If they are still alive, grab their new position
		local targetWorldPos = v.trackPos
		if IsValid(v.ent) then
			-- Re-apply stability offset
			targetWorldPos = v.ent:GetPos() + (ply:GetPos() - v.ent:GetPos()) * -33000
		end

		-- === DIRECTION MATH (Grenade Pointer Logic) ===
		-- 1. Get relative position
		local localPos = ply:WorldToLocal(targetWorldPos)
		
		-- 2. Calculate Angle (Inverting Y for screen space)
		local dirVecX = localPos.x
		local dirVecY = -localPos.y 
		local screenAngleRad = math.atan2(dirVecX, dirVecY)

		-- 3. Position on Orbit
		local orbitRadius = 280
		local px = cx + math.cos(screenAngleRad) * orbitRadius
		local py = cy - math.sin(screenAngleRad) * orbitRadius

		-- 4. Rotate Texture (Angle + 270 degrees)
		local rotation = math.deg(screenAngleRad) + 270

		surface.SetMaterial(matDamage)
		surface.SetDrawColor(255, 255, 255, v.alpha)
		surface.DrawTexturedRectRotated(px, py, 180, 90, rotation)
	end
end
CoDHUD[hudtype].DamageDirection = dmg_dir

local function grenade_dir( ... )
	local showIcon = select(1, ...)
	local nearEnts = select(2, ...)

    local cx, cy = ScrW() / 2, ScrH() / 2

	local matIcon = Material(hudtype .. "/icons/grenadeicon_white.png", "mips smooth")
	local matPointer = Material(hudtype .. "/icons/grenadepointer_white.png", "mips smooth")
		
    for _, ent in ipairs(nearEnts) do
        if not CoDHUD_IsGrenade(ent) then continue end

        -- 1. LOCALIZED COORDINATES
        local localPos = ply:WorldToLocal(ent:GetPos())
        local dirVecX = localPos.x
        local dirVecY = -localPos.y 
        
        -- 2. CALC ANGLE
        local screenAngleRad = math.atan2(dirVecX, dirVecY)
        local screenAngleDeg = math.deg(screenAngleRad)

        -- 3. POSITIONING
        local ringRadius = 150
        local px = cx + math.cos(screenAngleRad) * ringRadius
        local py = cy - math.sin(screenAngleRad) * ringRadius

        -- 4. POINTER POSITION
        local pointerRadius = ringRadius + 40
        local ptrX = cx + math.cos(screenAngleRad) * pointerRadius
        local ptrY = cy - math.sin(screenAngleRad) * pointerRadius

        surface.SetDrawColor(255, 255, 255, 255)

        -- 5. DRAW THE POINTER
        if matPointer and not matPointer:IsError() then
            surface.SetMaterial(matPointer)
            surface.DrawTexturedRectRotated(ptrX, ptrY, 70, 35, screenAngleDeg + 270)
        end

        -- 6. DRAW THE ICON
        if showIcon then
            if matIcon and not matIcon:IsError() then
                surface.SetMaterial(matIcon)
                surface.DrawTexturedRectRotated(px, py, 50, 50, 0)
            end
        end
    end
end
CoDHUD[hudtype].GrenadeIndicator = grenade_dir

local function killfeed( ... )
	local KillFeed = select(1, ...)
	
    -- Animation Settings
    ANIM_TIME = 0.25
    ANIM_RISE = 15

    local cx, cy = ScrW() / 2, ScrH() / 2
	local ct = CurTime()

    local xPos = CoDHUD_S(10)
    local yPos = CoDHUD_S(210)
    local spacing = CoDHUD_S(26)
    local iconW = CoDHUD_S(32)
    local iconH = CoDHUD_S(32)
    local iconOffY = CoDHUD_S(0)
    local gap_name = CoDHUD_S(10)
    local gap_icon = CoDHUD_S(5)
    local gap_extra = CoDHUD_S(25)

    local baseY = ScrH() - yPos

    for i = #KillFeed, 1, -1 do
        local data = KillFeed[i]
        local age = ct - data.spawnTime
        local timeLeft = data.dieTime - ct

		local ICON_BOX_W = iconW
		local ICON_BOX_H = iconH

        if timeLeft <= 0 then
            table.remove(KillFeed, i)
            continue
        end

        -- Calculate Animation and Fading
        local animProgress = math.Clamp(age / ANIM_TIME, 0, 1)
        local fadeFactor = 1

        if age < ANIM_TIME then
            -- Fade in from below
            fadeFactor = animProgress
        elseif timeLeft < 1 then
            -- Fade out (standard)
            fadeFactor = math.Clamp(timeLeft, 0, 1)
        end

        -- Vertical Offset Logic: Start lower and rise up
        local yOffset = (1 - animProgress) * CoDHUD_S(ANIM_RISE)
		local currentY = baseY - ((#KillFeed - i) * spacing) + yOffset

        local x = xPos
        local finalTxtAlpha = 155 * fadeFactor

        surface.SetFont("MW2_KillfeedFont")

		local attackerEnt = data.attackerEnt
		local victimEnt = data.victimEnt

		local aColBase = GetFactionColor(attackerEnt)
		local vColBase = GetFactionColor(victimEnt)

		local aCol = Color(aColBase.r, aColBase.g, aColBase.b, finalTxtAlpha)
		local vCol = Color(vColBase.r, vColBase.g, vColBase.b, finalTxtAlpha)

        if data.type == "kill" then
			-- Check kill icon size
			local cls = data.isHeadshot and "CoDHUD_MW2_Headshot" or data.weaponClass
			local w, h = killicon.GetSize(cls)

            -- 1. Attacker
            if data.attackerName != "" then
                draw.SimpleText(data.attackerName, "MW2_KillfeedFont", x, currentY, aCol)
                -- draw.SimpleTextOutlined( data.attackerName, "MW2_KillfeedFont", x, currentY, aCol, 0, 0, 1, Color(0, 0, 0, math.Clamp(finalTxtAlpha, 0, 50)) )

                local tw, _ = surface.GetTextSize(data.attackerName)
                x = x + tw + gap_name
            end

            -- 2. Icon
			local iconBoxX = x + gap_extra
			local iconBoxY = currentY

			local alpha = math.min(165 * fadeFactor, 255)

			w = w or ICON_BOX_W
			h = h or ICON_BOX_H

			local drawX = iconBoxX + (ICON_BOX_W - w) * 0.5
			local drawY = iconBoxY + (ICON_BOX_H - h) * 0.5

			killicon.Draw(drawX, drawY, cls, alpha)

			x = iconBoxX + ICON_BOX_W + gap_icon + gap_extra

            -- 3. Victim
            draw.SimpleText(data.victimName, "MW2_KillfeedFont", x, currentY, vCol)
            -- draw.SimpleTextOutlined( data.victimName, "MW2_KillfeedFont", x, currentY, vCol, 0, 0, 1, Color(0, 0, 0, math.Clamp(finalTxtAlpha, 0, 50)) )
        else
            draw.SimpleText(data.msg, "MW2_KillfeedFont", x, currentY, Color(255, 255, 255, finalTxtAlpha))
        end
    end
end
CoDHUD[hudtype].Killfeed = killfeed

local function medals( ... )

	local speedMul = select(1, ...)
	local activeMedal = select(2, ...)
	local age = (CurTime() - activeMedal.start) / speedMul

	local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()
    local cx, cy = ScrW() / 2, ScrH() / 2
    local MEDAL_DURATION = 1.25
    local FADE_IN_TIME   = 0.125
    local EXIT_DURATION  = 0.125
    local FADE_OUT_START = MEDAL_DURATION - EXIT_DURATION

    local COL_POINTS = Color(255, 255, 50)

    local MEDAL_CFG = {
        X_OFFSET = 0,    -- Horizontal offset from center
        Y_OFFSET = -250, -- Vertical offset (Match this with cl_mw2_challenge.lua)
    }

	if age > MEDAL_DURATION then
		return true
	end

	-- VISUALS
	local alpha = 255
	local scale = 1

	if age < FADE_IN_TIME then
		local progress = age / FADE_IN_TIME
		alpha = progress * 255
		scale = Lerp(progress, 3.5, 1.0)

	elseif age > FADE_OUT_START then
		local progress = (age - FADE_OUT_START) / EXIT_DURATION
		alpha = math.Clamp((1 - progress) * 255, 0, 255)
		scale = Lerp(progress, 1.0, 3.0)
	end

	local cx = (ScrW() / 2) + CoDHUD_S(MEDAL_CFG.X_OFFSET)
	local cy = (ScrH() / 2) + CoDHUD_S(MEDAL_CFG.Y_OFFSET)

	local colWhite      = Color(255, 255, 255, alpha)
	local colBlack      = Color(0, 0, 0, alpha * 0.8)
	local colYellow     = Color(COL_POINTS.r, COL_POINTS.g, COL_POINTS.b, alpha)
	local colRedGlow    = Color(195, 110, 115, alpha * 0.5)
	local colRedOutline = Color(180, 0, 0, alpha * 0.8)

	local mat = Matrix()
	mat:Translate(Vector(cx, cy, 0))
	mat:Scale(Vector(scale, scale, 1))
	mat:Translate(Vector(-cx, -cy, 0))

	cam.PushModelMatrix(mat)
		-- ICON
		if activeMedal.hasIcon then
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.SetMaterial(Material(hudtype .. "/icons/crosshair_red.png", "smooth"))
			surface.DrawTexturedRect(cx - CoDHUD_S(60), cy - CoDHUD_S(120), CoDHUD_S(120), CoDHUD_S(120))
		end

		-- TEXT
		local localizedText = language.GetPhrase("MW2_" .. activeMedal.text)

		draw.SimpleTextOutlined( localizedText, "MW2_MedalGlow", cx, cy, Color(0,0,0,0), 1, 1, 0.75, colRedGlow )
		draw.SimpleTextOutlined( localizedText, "MW2_MedalPrimary", cx, cy, colWhite, 1, 1, 0, colRedOutline )

		-- DESC / POINTS
		if activeMedal.desc then
			local localizedDesc = language.GetPhrase("MW2_" .. activeMedal.desc)

			if activeMedal.isSpecial then
				draw.SimpleTextOutlined( localizedDesc, "MW2_MedalDesc", cx, cy + CoDHUD_S(35), colWhite, 1, 1, outlined and 1 or 0, colBlack )
			else
				local descText     = localizedDesc .. " ("
				local pointsText   = "+" .. activeMedal.points
				local bracketClose = ")"

				surface.SetFont("MW2_MedalDesc")
				local w1 = surface.GetTextSize(descText)
				local w2 = surface.GetTextSize(pointsText)
				local totalW = w1 + w2 + surface.GetTextSize(bracketClose)

				local startX = cx - (totalW / 2)

				draw.SimpleTextOutlined( descText, "MW2_MedalDesc", startX, cy + CoDHUD_S(35), colWhite, 0, 1, outlined and 1 or 0, colBlack )
				draw.SimpleTextOutlined( pointsText, "MW2_MedalDesc", startX + w1, cy + CoDHUD_S(35), colYellow, 0, 1, outlined and 1 or 0, colBlack )
				draw.SimpleTextOutlined( bracketClose, "MW2_MedalDesc", startX + w1 + w2, cy + CoDHUD_S(35), colWhite, 0, 1, outlined and 1 or 0, colBlack )
			end
		else
			draw.SimpleTextOutlined( "+" .. activeMedal.points, "MW2_MedalDesc", cx, cy + CoDHUD_S(35), colYellow, 1, 1, outlined and 1 or 0, colBlack )
		end
	cam.PopModelMatrix()

end
CoDHUD[hudtype].Medals = medals
CoDHUD[hudtype].MedalsSound = "hud/hud_medal.mp3"

local function minimap( ... )
	local KillFeed = select(1, ...)
	
	local MAP_CFG = {
		X = 12,
		Y = 16,
		W = 224,
		H = 224,

		ALPHA_BORDER    = 255,
		ALPHA_MAP_BG    = 120,
		ALPHA_PLAYER    = 255,
		ALPHA_STATIC_S  = 100,
		ALPHA_MOVING_S  = 255,

		SIZE_PLAYER     = 42,
		SIZE_FRIENDLY   = 42,
		SIZE_ENEMY      = 42,

		SCAN_SPEED      = 48,
		FADE_TIME       = 0.7,
		FADE_TIME_VIS   = 1.3,

		-- [ TINKERING ] 
		-- Adjust this to control how close icons get to the edge. 
		-- 0 means the center of the icon sits exactly on the border line. 
		EDGE_PADDING    = 0, 
	}

	local MAT_BORDER        = Material(hudtype .. "/minimap/minimap_background.png", "smooth")
	local MAT_MAP_BG        = Material(hudtype .. "/minimap/compass_map_default.png", "smooth")
	local MAT_PLAYER        = Material(hudtype .. "/minimap/compassping_player.png", "smooth")
	local MAT_STATIC_SCAN   = Material(hudtype .. "/minimap/minimap_scanlines.png", "smooth")
	local MAT_MOVING_SCAN   = Material(hudtype .. "/minimap/scanlines.png", "smooth")

	local MAT_FRIEND_HOLLOW  = Material(hudtype .. "/minimap/compassping_green_hollow_mp.png", "smooth")
	local MAT_ENEMY_FIRING   = Material(hudtype .. "/minimap/compassping_enemyfiring.png", "smooth")

    local x, y = CoDHUD_SX(MAP_CFG.X), CoDHUD_SY(MAP_CFG.Y)
    local w, h = CoDHUD_S(MAP_CFG.W), CoDHUD_S(MAP_CFG.H)
    local centerX, centerY = x + (w / 2), y + (h / 2)

    -- 1. LAYER: MINIMAP BORDER
    surface.SetMaterial(MAT_BORDER)
    surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_BORDER)
    surface.DrawTexturedRect(x, y, w, h)

    -- [[ STENCIL MASKING ]]
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)

    surface.SetMaterial(MAT_BORDER)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(x, y, w, h)

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

        -- 2. LAYER: COMPASS MAP BACKGROUND
        surface.SetMaterial(MAT_MAP_BG)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_MAP_BG)
        surface.DrawTexturedRect(x, y, w, h)
        
        -- 3. LAYER: STATIC SCANLINES
        surface.SetMaterial(MAT_STATIC_SCAN)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_STATIC_S)
        surface.DrawTexturedRect(x, y, w, h)

        -- 4. LAYER: REPETITIVE MOVING SCANLINES
        surface.SetMaterial(MAT_MOVING_SCAN)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_MOVING_S)
        local moveOffset = (CurTime() * MAP_CFG.SCAN_SPEED) % h
        surface.DrawTexturedRect(x, y - moveOffset, w, h)
        surface.DrawTexturedRect(x, y - moveOffset + h, w, h)

    render.SetStencilEnable(false)
    -- [[ STENCIL END ]]

    -- 5. LAYER: THE ICONS
    local pSize = CoDHUD_S(MAP_CFG.SIZE_PLAYER)
    local fSize = CoDHUD_S(MAP_CFG.SIZE_FRIENDLY)
    local eSize = CoDHUD_S(MAP_CFG.SIZE_ENEMY)
    
    local localFaction = ply:GetNW2String("CoDHUD_Faction", "")
    local targets = ents.FindByClass("npc_*")
    table.Add(targets, player.GetAll())

    for _, ent in ipairs(targets) do
        if not IsValid(ent) or ent == ply then continue end
        
        local isAlive = (ent:IsPlayer() and ent:Alive()) or (ent:IsNPC() and ent:Health() > 0)
        local targetFaction = ent:GetNW2String("CoDHUD_Faction", "")
        local isFriendly = (localFaction ~= "" and targetFaction == localFaction)
        local entIdx = ent:EntIndex()

        -- Visibility / Shared Vision Check (Enemies only)
        local isVisibleToTeam = false
        if not isFriendly then
            for _, observer in ipairs(player.GetAll()) do
                local obsFaction = observer:GetNW2String("CoDHUD_Faction", "")
                local isObserverFriendly = (localFaction ~= "" and obsFaction == localFaction)
                
                if observer == ply or (isObserverFriendly and observer:Alive()) then
                    local dirToEnt = (ent:WorldSpaceCenter() - observer:EyePos()):GetNormalized()
                    local dot = observer:GetAimVector():Dot(dirToEnt)
                    local fovRad = math.rad((observer:IsPlayer() and observer:GetFOV() or 90) / 2)
                    
                    if dot > math.cos(fovRad) then
                        local tr = util.TraceLine({
                            start = observer:EyePos(),
                            endpos = ent:WorldSpaceCenter(),
                            filter = {observer, ent},
                            mask = MASK_SHOT
                        })
                        if not tr.Hit then
                            isVisibleToTeam = true
                            break
                        end
                    end
                end
            end

            if isVisibleToTeam and isAlive then
                CoDHUD_VisCache[entIdx] = CurTime() + MAP_CFG.FADE_TIME_VIS
            end
        end

        local visAlpha = 0
        if CoDHUD_VisCache[entIdx] then
            local timeLeft = CoDHUD_VisCache[entIdx] - CurTime()
            if timeLeft > 0 then
                visAlpha = math.Clamp(timeLeft / MAP_CFG.FADE_TIME_VIS, 0, 1) * 255
            else
                CoDHUD_VisCache[entIdx] = nil
            end
        end

        -- Base alpha logic: Friendlies are always 255, enemies use visAlpha
        local alpha = 255
        if not isFriendly then
            alpha = visAlpha
        end

        if not isAlive then
            if isFriendly then 
                continue 
            else
                if not CoDHUD_DeathCache[entIdx] then
                    CoDHUD_DeathCache[entIdx] = CurTime()
                end
                
                local timeSinceDeath = CurTime() - CoDHUD_DeathCache[entIdx]
                if timeSinceDeath > MAP_CFG.FADE_TIME then continue end
                alpha = math.min(alpha, 255 * (1 - (timeSinceDeath / MAP_CFG.FADE_TIME)))
            end
        else
            CoDHUD_DeathCache[entIdx] = nil
        end

        if alpha <= 0 then continue end

        -- Relative Position Math
        local relPos = ent:GetPos() - ply:GetPos()
        local dist = relPos:Length() / 8 
        
        local posAngle = relPos:Angle()
        posAngle.y = posAngle.y - ply:EyeAngles().y + 90
        
        local rad = math.rad(posAngle.y)
        local offsetX = math.cos(rad) * dist
        local offsetY = -math.sin(rad) * dist

        -- Square clamp logic using the tinkering variable
        local boundsX = (w / 2) - MAP_CFG.EDGE_PADDING
        local boundsY = (h / 2) - MAP_CFG.EDGE_PADDING

        if math.abs(offsetX) > boundsX or math.abs(offsetY) > boundsY then
            local scaleX = boundsX / math.max(0.0001, math.abs(offsetX))
            local scaleY = boundsY / math.max(0.0001, math.abs(offsetY))
            local scale = math.min(scaleX, scaleY)
            offsetX = offsetX * scale
            offsetY = offsetY * scale
        end

        local targetX = centerX + offsetX
        local targetY = centerY + offsetY

        if isFriendly then
            local rotation = ent:EyeAngles().y - ply:EyeAngles().y
            surface.SetMaterial(MAT_FRIEND_HOLLOW)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRectRotated(targetX, targetY, fSize, fSize, rotation)
        else
            surface.SetMaterial(MAT_ENEMY_FIRING)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRect(targetX - (eSize / 2), targetY - (eSize / 2), eSize, eSize)
        end
    end

    -- Draw Local Player Icon (Static center)
    surface.SetMaterial(MAT_PLAYER)
    surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_PLAYER)
    surface.DrawTexturedRect(centerX - (pSize / 2), centerY - (pSize / 2), pSize, pSize)
end
CoDHUD[hudtype].Minimap = minimap

local MAT_GRADIENT = Material("vgui/gradient-r")

local function scorebar(data)
	local CFG = {
		-- Base Bar
		BAR_W     = 776,
		BAR_H     = 66,
		BAR_X_OFF = 0,
		BAR_Y_OFF = 44,

		-- Faction Icon
		ICON_SCALE = 1.28,
		ICON_X     = 12,
		ICON_Y     = 8,

		-- Timer
		TIMER_X          = 77.5,
		TIMER_Y          = -30,
		TIMER_SHIFT_2DIG = -10,
		TIMER_SHIFT_3DIG = -12,
		TIMER_OUTLINE_W  = 1.5,

		-- Winning / Losing / Tie Text Position
		STATUS_X = 5,
		STATUS_Y = 6,

		-- Squeeze Values
		SQUEEZE            = -2,
		SQUEEZE_ONE        = -6,
		SQUEEZE_ONE_BEFORE = -4,
	}

	local SCORES_CFG = {
		-- Text Config
		X = 28,
		Y = 974,
		GAP_OFFSET = 33,
		SQUEEZE = -4,
		SQUEEZE_ONE = -10,
		SQUEEZE_ONE_BEFORE = -10,
		OUTLINE_W = 1.5,

		-- Score Limit for Bar Scaling
		SCORE_LIMIT = 75,

		-- Active Bar Config (Green/Red)
		HUD_X = 47,
		HUD_Y = 1042.5,
		HUD_W_BASE = 15,
		HUD_W_MAX = 282,
		HUD_H = 10,
		SLANT_SIZE = 0,
		VERTICAL_GAP = 6,
		SHADOW_OFFSET = 2,

		-- Base Bar Config (Black Backgrounds)
		BASE_X = 31,
		BASE_Y = 1042,
		BASE_W = 298,
		BASE_H = 11,
		BASE_SLANT = 0,
		BASE_GAP = 4,

		-- End Cap Config
		CAP_W = 3,
		CAP_H_OFFSET = 2,
		CAP_SLANT = 0,
		CAP_COLOR = Color(0, 0, 0, 155),

		-- Active Slant Config
		SLANT_W = 3,
		SLANT_H_OFFSET = 0.40,
		SLANT_SEP_W = 1,
		SLANT_Y_OFFSET_TOP = 0,
		SLANT_COLOR = Color(255, 255, 255, 220),
	}

	local ARROW_CFG = {
		x = 8,
		y = 1005,
		w = 27,
		h = 31,
		outline = 4,
		color = Color(140, 220, 140, 255),
		outlineColor = Color(0, 0, 0, 255),
		material = Material(hudtype .. "/hud/ui_arrow_right.png", "smooth noclamp"),
	}

    local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- FACTION (unchanged)
    local currentFaction = ply:GetNW2String("CoDHUD_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
        if not CoDHUD.Factions[hudtype][currentFaction] then currentFaction = "rangers" end
        ply:SetNW2String("CoDHUD_Faction", currentFaction)
    end

    local scrW, scrH = ScrW(), ScrH()

    -- =========================
    -- TOP BAR
    -- =========================

    local barW, barH = CoDHUD_SX(CFG.BAR_W), CoDHUD_SY(CFG.BAR_H)
    local barX = CoDHUD_SX(CFG.BAR_X_OFF)
    local barY = scrH - CoDHUD_SY(CFG.BAR_Y_OFF) - barH

	local factionData = CoDHUD.Factions[hudtype] and CoDHUD.Factions[hudtype][currentFaction]
	local factionMat = factionData and factionData.scoreIcon

	local factionData = CoDHUD.Factions[hudtype] and CoDHUD.Factions[hudtype][currentFaction]
	if not factionData then
		currentFaction = "rangers"
		factionData = CoDHUD.Factions[hudtype][currentFaction]
	end

    -- TIMER (NOW FROM DATA)
    local timeStr = data.timeStr
    local mins = data.mins

    local xShift =
        (#tostring(mins) >= 3 and CoDHUD_SX(CFG.TIMER_SHIFT_3DIG)) or
        (#tostring(mins) >= 2 and CoDHUD_SX(CFG.TIMER_SHIFT_2DIG)) or 0

    DrawSqueezedText( timeStr, "MW2_Timer", barX + CoDHUD_SX(CFG.TIMER_X) + xShift, barY + CoDHUD_SY(CFG.TIMER_Y), Color(255, 255, 255, 255), CFG.SQUEEZE, CFG.SQUEEZE_ONE, 1, CFG.SQUEEZE_ONE_BEFORE, CoDHUD_SX(CFG.TIMER_OUTLINE_W) )

	
	-- Status Colors
	data.tiedCol = Color(110, 220, 120, 255)
	data.winningCol = Color(215, 110, 120, 255)
	data.losingCol = Color(230, 230, 110, 255)

    draw.SimpleTextOutlined( language.GetPhrase(data.statusText), "MW2_Status", barX + CoDHUD_SX(CFG.STATUS_X), barY + CoDHUD_SY(CFG.STATUS_Y), data.statusCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlined and 1 or 0, Color(0,0,0) )

    -- SCORE BARS (UNCHANGED)
    local clientKills   = data.clientScore
    local topEnemyKills = data.enemyScore

    local S_CFG = SCORES_CFG

    local baseX     = CoDHUD_S(S_CFG.BASE_X)
    local baseY_raw = scrH - CoDHUD_S(1080 - S_CFG.BASE_Y)
    local baseW     = CoDHUD_S(S_CFG.BASE_W)
    local baseH     = CoDHUD_S(S_CFG.BASE_H)
    local baseSlant = CoDHUD_S(S_CFG.BASE_SLANT)
    local baseGap   = CoDHUD_S(S_CFG.BASE_GAP)

    local capW      = CoDHUD_S(S_CFG.CAP_W)
    local capSlant  = CoDHUD_S(S_CFG.CAP_SLANT)
    local capHOff   = CoDHUD_S(S_CFG.CAP_H_OFFSET)

    local hudX      = CoDHUD_S(S_CFG.HUD_X)
    local hudY_raw  = scrH - CoDHUD_S(1080 - S_CFG.HUD_Y)
    local hudWBase  = CoDHUD_S(S_CFG.HUD_W_BASE)
    local hudWMax   = CoDHUD_S(S_CFG.HUD_W_MAX)
    local hudH      = CoDHUD_S(S_CFG.HUD_H)
    local slantSize = CoDHUD_S(S_CFG.SLANT_SIZE)
    local vertGap   = CoDHUD_S(S_CFG.VERTICAL_GAP)
    local shadowOff = CoDHUD_S(S_CFG.SHADOW_OFFSET)

    local slantW    = CoDHUD_S(S_CFG.SLANT_W)
    local slantHOff = CoDHUD_S(S_CFG.SLANT_H_OFFSET)
    local slantSepW = CoDHUD_S(S_CFG.SLANT_SEP_W)

    local BASE_X = baseX
    local BASE_Y = baseY_raw
    local BASE_W = baseW
    local BASE_H = baseH
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

    local liveScoreLimit = S_CFG.SCORE_LIMIT
    local cv_limit = GetConVar("codhud_score_limit")
    if cv_limit then
        local val = cv_limit:GetInt()
        if val > 0 then liveScoreLimit = val end
    end
	
	liveScoreLimit = liveScoreLimit * 100

    local maxAddedWidth = hudWMax - hudWBase
    local client_w = math.Round(hudWBase + math.Clamp(((clientKills * 100) / liveScoreLimit) * maxAddedWidth, 0, maxAddedWidth))
    local enemy_w  = math.Round(hudWBase + math.Clamp(((topEnemyKills * 100) / liveScoreLimit) * maxAddedWidth, 0, maxAddedWidth))

    local HUD_X = hudX
    local HUD_Y = hudY_raw
    local top_y = HUD_Y - vertGap - hudH
    local white = Color(255,255,255,255)

	-- Shadows
	surface.SetMaterial(MAT_GRADIENT)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawTexturedRect(HUD_X + shadowOff, top_y + shadowOff, client_w, hudH)
	surface.DrawTexturedRect(HUD_X + shadowOff, HUD_Y + shadowOff, enemy_w, hudH)

	draw.NoTexture()
	surface.SetDrawColor(Color(0, 0, 0, 100))
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
	surface.SetDrawColor(Color(110, 180, 90))
	surface.DrawTexturedRect(HUD_X, top_y, client_w, hudH)

	draw.NoTexture()
	surface.SetDrawColor(Color(110, 180, 90))
	surface.DrawPoly({
		{ x = HUD_X + client_w,             y = top_y },
		{ x = HUD_X + client_w + slantSize, y = top_y + hudH },
		{ x = HUD_X + client_w,             y = top_y + hudH },
	})

	-- Enemy bar (red)
	surface.SetMaterial(MAT_GRADIENT)
	surface.SetDrawColor(Color(180, 55, 55))
	surface.DrawTexturedRect(HUD_X, HUD_Y, enemy_w, hudH)

	draw.NoTexture()
	surface.SetDrawColor(Color(180, 55, 55))
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

    DrawSqueezedText(clientKills * 100,   "MW2_Font", CoDHUD_S(S_CFG.X), HUD_Y - CoDHUD_S(41),          white, S_CFG.SQUEEZE, S_CFG.SQUEEZE_ONE, 2, S_CFG.SQUEEZE_ONE_BEFORE, S_CFG.OUTLINE_W)
    DrawSqueezedText(topEnemyKills * 100, "MW2_Font", CoDHUD_S(S_CFG.X), HUD_Y - CoDHUD_S(41) + CoDHUD_S(S_CFG.GAP_OFFSET), white, S_CFG.SQUEEZE, S_CFG.SQUEEZE_ONE, 2, S_CFG.SQUEEZE_ONE_BEFORE, S_CFG.OUTLINE_W)

    local ax = CoDHUD_S(ARROW_CFG.x)
    local ay = scrH - CoDHUD_S(1080 - ARROW_CFG.y)
    local aw = CoDHUD_S(ARROW_CFG.w)
    local ah = CoDHUD_S(ARROW_CFG.h)
    local ao = CoDHUD_S(ARROW_CFG.outline)

    surface.SetMaterial(ARROW_CFG.material)

    surface.SetDrawColor(ARROW_CFG.outlineColor)
    surface.DrawTexturedRectUV(ax - ao, ay - ao, aw + (ao * 2), ah + (ao * 2), 0, 0, 1, 1)

    surface.SetDrawColor(ARROW_CFG.color)
    surface.DrawTexturedRectUV(ax, ay, aw, ah, 0, 0, 1, 1)
end
CoDHUD[hudtype].Scorebar = scorebar

local function scoreboard( ... )
	-- local KillFeed = select(1, ...)
	local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

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
	local MAT_ICON_DEAD  = Material(hudtype .. "/icons/hud_status_dead.png", "mips smooth")

	local function SortLogic(a, b)
		local scoreA = math.max(0, a:Frags())
		local scoreB = math.max(0, b:Frags())

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

		-- Status Icon (dead indicator) - Moved next to name
		if ply:IsValid() and not ply:Alive() then
			surface.SetMaterial(MAT_ICON_DEAD)
			surface.SetDrawColor(255, 255, 255, 255)
			local iconSz = h * 0.8
			-- Adjusted X to be right before the name (name starts at 110)
			surface.DrawTexturedRect(x + CoDHUD_S(75), y + (h / 2) - (iconSz / 2), iconSz, iconSz)
		end

		-- Colors & Stats
		local isMe = (ply == lp)
		local tCol = isMe and Color(255, 200, 50, 255) or Color(255, 255, 255, 255)
		local pScore = math.max(0, ply:Frags() * 100)

		-- Text
		draw.SimpleTextOutlined(ply:Nick(), "MW2_Scoreboard_Text", x + CoDHUD_S(110), y + (h / 2), tCol, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
		draw.SimpleTextOutlined(ply:Deaths(), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_DEATHS),  y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
		draw.SimpleTextOutlined(ply:GetNWInt("Assists", 0), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_ASSISTS), y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
		draw.SimpleTextOutlined(ply:Frags(), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_KILLS),   y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))
		draw.SimpleTextOutlined(pScore, "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_SCORE),   y + (h / 2), tCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlined and 1 or 0, Color(0, 0, 0))

		-- Ping Indicator
		local boxSize = CoDHUD_S(CFG.PING_BOX_SIZE)
		local pingX = barRight + CoDHUD_S(CFG.PING_X_OFF)
		local pingY = y + (h / 2) - (boxSize / 2)

		surface.SetDrawColor(0, 0, 0, CFG.PING_BOX_ALPHA)
		surface.DrawRect(pingX, pingY, boxSize, boxSize)

		surface.SetDrawColor(0, 255, 0, 255)
		local rodW = CoDHUD_S(CFG.PING_BAR_W)
		local rodSpacing = CoDHUD_S(CFG.PING_BAR_SPACING)
		local totalRodsWidth = (rodW * 4) + (rodSpacing * 3)
		local startX = pingX + (boxSize / 2) - (totalRodsWidth / 2)

		for i = 1, 4 do
			local bh = (boxSize - CoDHUD_S(6)) * (i / 4)
			surface.DrawRect(startX + ((i - 1) * (rodW + rodSpacing)), pingY + (boxSize - bh - CoDHUD_S(3)), rodW, bh)
		end
	end

    local scrW, scrH = ScrW(), ScrH()
    local lp = LocalPlayer()

    -- 1. IDENTIFY FACTIONS & PLAYERS
	local factions = {}

	for _, p in ipairs(player.GetAll()) do
		local fac = p:GetNW2String("CoDHUD_Faction", "rangers")
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
    local barW = CoDHUD_S(CFG.BAR_W)
    local barH = CoDHUD_S(CFG.BAR_H)
    local barX = (scrW / 2) - (barW / 2) + CoDHUD_S(CFG.BAR_X_OFF)
    local barRight = barX + barW

	local startY = CoDHUD_S(CFG.BAR_Y_OFF)

	for fi, facData in ipairs(factionList) do
		local players = facData.players
		local facKey = facData.key
		local fData = CoDHUD.Factions[hudtype] and CoDHUD.Factions[hudtype][facKey] or {
			name = facKey,
			short = facKey,
			color = Color(120,120,120)
		}

		local sectionY = startY

		-- ICON
		local iconPath = CoDHUD.Factions[hudtype][facKey].spawnIcon
		local mat = Material(iconPath, "smooth")

		surface.SetMaterial(mat)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(barX + CoDHUD_S(CFG.ICON_X_OFF), sectionY + CoDHUD_S(CFG.ICON_Y_OFF), CoDHUD_S(CFG.ICON_SIZE), CoDHUD_S(CFG.ICON_SIZE))

		draw.SimpleTextOutlined( language.GetPhrase(fData.short) .. " (" .. #players .. ")", "MW2_Scoreboard_Text", barX + CoDHUD_S(CFG.FAC_NAME_X), sectionY + CoDHUD_S(CFG.FAC_NAME_Y), Color(255,255,255), 0,0, outlined and 1 or 0, Color(0,0,0) )

		-- rows
		for i, ply in ipairs(players) do
			local rowY = sectionY + (i - 1) * (barH + CoDHUD_S(CFG.ROW_GAP))
			DrawPlayerRow(ply, lp, barX, rowY, barW, barH, barRight, fData.color)
		end

		-- push next faction down
		local sectionHeight = CoDHUD_S(0) + (#players * (barH + CoDHUD_S(CFG.ROW_GAP)))
		startY = startY + sectionHeight + CoDHUD_S(CFG.TEAM_GAP)
	end

    surface.SetDrawColor(110, 110, 110, CFG.HEADER_ALPHA)
    surface.SetMaterial(MAT_GRADIENT_L)
    surface.DrawTexturedRect(0, CoDHUD_S(CFG.HEADER_Y_POS), scrW, CoDHUD_S(CFG.HEADER_H))

    -- Map name
    local mapName = string.upper(game.GetMap())
	draw.SimpleTextOutlined( mapName, "MW2_Scoreboard_Timer", scrW/2, CoDHUD_S(CFG.MAP_Y_OFF), Color(255, 255, 255), 1, 0, outlined and 1.5 or 0, Color(0,0,0) )

    -- Timer
    local totalSecs = math.floor(CurTime())
    local mins, secs = math.floor(totalSecs / 60), totalSecs % 60
    local timeStr = string.format("%d:%02d", mins, secs)
    DrawSqueezedText(timeStr, "MW2_Scoreboard_Timer", scrW - CoDHUD_S(CFG.TIMER_X_POS), CoDHUD_S(CFG.TIMER_Y_OFF), Color(255, 255, 255, 255), CFG.SQUEEZE, CFG.SQUEEZE_ONE, 0, CFG.SQUEEZE_ONE_BEFORE, outlined and 1.5 or 0)

    -- Stats column headers
    local headerY = CoDHUD_S(CFG.BAR_Y_OFF) - CoDHUD_S(35)
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_DEATHS"), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_DEATHS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_ASSISTS"), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_ASSISTS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_KILLS"), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_KILLS), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	draw.SimpleTextOutlined( language.GetPhrase("MW2_CGAME_SB_SCORE"), "MW2_Scoreboard_Text", barRight - CoDHUD_S(CFG.OFF_SCORE), headerY, Color(255,255,255), TEXT_ALIGN_RIGHT, 0, outlined and 1 or 0, Color(0,0,0) )
	
	local lp = LocalPlayer()
	local myFaction = lp:GetNW2String("CoDHUD_Faction", "rangers")
	if myFaction == "" then myFaction = "rangers" end
	
	table.sort(factionList, function(a, b)
		if a.key == myFaction then return true end
		if b.key == myFaction then return false end
		return a.score > b.score
	end)

	local stripX = CoDHUD_S(20)
	local stripY = CoDHUD_S(CFG.HEADER_Y_POS) + (CoDHUD_S(CFG.HEADER_H) / 2) - (CoDHUD_S(CFG.HEADER_ICON_SIZE) / 2)
	local stripGap = CoDHUD_S(18)
	local iconSize = CoDHUD_S(CFG.HEADER_ICON_SIZE)
	local textOffset = CoDHUD_S(8)
	
	local x = stripX

	surface.SetFont("MW2_Scoreboard_Text")

	for _, fac in ipairs(factionList) do
		local key = fac.key
		local players = fac.players
		local score = fac.score or 0

		local fData = CoDHUD.Factions[hudtype] and CoDHUD.Factions[hudtype][key] or {
			short = key,
			color = Color(150,150,150)
		}

		local iconPath = CoDHUD.Factions[hudtype][key].spawnIcon
		local mat = Material(iconPath, "smooth")

		if mat:IsError() then
			mat = Material(hudtype .. "/vgui/hud/icon_error")
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
		x = x + iconSize + textW + CoDHUD_S(25)
	end

end
CoDHUD[hudtype].Scoreboard = scoreboard

local function deathicon( ... )
	local m = select(1, ...)
	local elapsed = select(2, ...)

    local MAT_DEAD_ICON  = Material(hudtype .. "/icons/headicon_dead.png", "smooth")
	
	local screenData = m.pos:ToScreen()
	if screenData.visible then
		
		local currentAlpha = 185
		
		if elapsed > (3.7 - 1.0) then
			currentAlpha = Lerp((elapsed - (3.7 - 1.0)) / 1.0, 185, 0)
		end

		local dist = lp:GetPos():Distance(m.pos)
		local scale = math.Clamp(1 - (dist / 2500), 0.5, 1)
		local scaledSize = 76 * scale

		surface.SetMaterial(MAT_DEAD_ICON)
		surface.SetDrawColor(255, 255, 255, currentAlpha)
		surface.DrawTexturedRect(screenData.x - (scaledSize/2), screenData.y - (scaledSize/2), scaledSize, scaledSize)
	end
end
CoDHUD[hudtype].DeathIcon = deathicon

local function friendorfoe( ... )
	local displayName = select(1, ...)
	local finalScale = select(2, ...)
	local screenData = select(3, ...)
	local isFriendly = select(4, ...)
	local alpha = select(5, ...)
	
	local ENEMY_COLOR    = Color(210, 30, 50)  
    local FRIENDLY_COLOR = Color(60, 200, 60)
	
	local factionColor = isFriendly and FRIENDLY_COLOR or ENEMY_COLOR

	surface.SetFont("MW2_TargetName_Primary")
	local tw, th = surface.GetTextSize(displayName)
	tw, th = tw * finalScale, th * finalScale

	local drawX, drawY = screenData.x - (tw / 2), screenData.y - (th / 2)

	local matrix = Matrix()
	matrix:Translate(Vector(drawX, drawY, 0))
	matrix:Scale(Vector(finalScale, finalScale, 1))

	cam.PushModelMatrix(matrix)
		draw.SimpleText(displayName, "MW2_TargetName_Primary", 0, 0, Color(factionColor.r, factionColor.g, factionColor.b, alpha), 0, 0)
	cam.PopModelMatrix()
end
CoDHUD[hudtype].IFF = friendorfoe

local ICON_ON = Material(hudtype .. "/icons/voice_on.png", "noclamp smooth")
local ICON_DIM = Material(hudtype .. "/icons/voice_on_dim.png", "noclamp smooth")

local function voice(yOffset)
	-- Positioning Config
	local VOICE_X = 22
	local VOICE_Y_START = ScrH() * 0.30 
	local SPACING = 28 
	local ICON_SIZE = 36
	local TEXT_X_OFFSET = 2 

	local drawY = VOICE_Y_START + yOffset
	
	-- Volume check for icon swapping
	local isSpeaking = ply:VoiceVolume() > 0.05 
	local icon = isSpeaking and ICON_ON or ICON_DIM

	-- Draw Icon
	surface.SetMaterial(icon)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(VOICE_X, drawY, ICON_SIZE, ICON_SIZE)

	-- Draw Name
	draw.SimpleText(ply:Nick(), "MW2_VoiceFont", VOICE_X + ICON_SIZE + TEXT_X_OFFSET, drawY, Color(255, 255, 255), 0, 0)

	yOffset = yOffset + SPACING
end
CoDHUD[hudtype].VoiceChat = voice

-- local debugpic = true
local debugpicture = Material("debugref/mw3.png", "smooth")

local function weaponinfo(...)

	if debugpic then
		surface.SetMaterial(debugpicture)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end


	local MASK = select(1, ...)
	local CFG = {
		-- Base Bar
		BAR_W       = 355,
		BAR_H       = 200,
		BAR_X_OFF   = 170,
		BAR_Y_OFF   = 12,

		-- Grenades
		GRENADE_X_OFF     = -38,
		GRENADE_Y_OFF     = -35,
		GRENADE_ICON_W    = 40,
		GRENADE_ICON_H    = 40,
		GRENADE_STACK_GAP = 4,
		GRENADE_MAX       = 4,
		GRENADE_SHADES    = { 255, 200, 175, 120 },

		-- Reserve Ammo (1-2 digit: 0-99)
		RES_SIZE    = 64,
		RES_X       = -60,
		RES_Y       = 107.5,

		-- Reserve Ammo (3 digit: 100-999)
		RES3_SIZE   = 48,
		RES3_X      = -60,
		RES3_Y      = 107.5,

		-- Reserve Ammo (4 digit: 1000+)
		RES4_SIZE   = 38,
		RES4_X      = -45,
		RES4_Y      = 115,

		-- Text kerning
		SQUEEZE            = -6,
		SQUEEZE_ONE        = -14,
		SQUEEZE_ONE_BEFORE = -10,

		-- Weapon Name
		WEP_NAME_SIZE  = 38,
		WEP_NAME_X_OFF = -105,
		WEP_NAME_Y_OFF = 170,
		WEP_NAME_FADE  = 2,
		WEP_NAME_SQ    = -3,
		WEP_NAME_SQ1   = -8,

		-- Status Indicator
		STAT_FONT_SIZE = 28,
		STAT_LOW_PERC  = 0.40,
		STAT_FLASH_SPD = 8,
		STAT_Y_OFF     = 62,

		-- Bullet Icons
		BULLET_ALPHA      = 255,
		BULLET_RELOAD_R   = 180,
		BULLET_RELOAD_G   = 60,
		BULLET_RELOAD_B   = 60,
		BULLET_RELOAD_SPD = 6,

		-- Alt Ammo (Underbarrel / Secondary)
		ALT_ICON_SIZE  = 78,
		ALT_ICON_X     = 27.5,
		ALT_ICON_Y     = 110,
		ALT_TEXT_X     = 85,
		ALT_TEXT_Y     = 134,
		ALT_FONT_SIZE  = 36,
		ALT_TEXT_SQ    = -3,
		ALT_TEXT_SQ1   = -7,
	}

	local AMMO = {
		["default"] = { mat = "mw2/hud/ammo_counter_bullet_mp.png",      w = 4,  h = 30,	gap = 2, y_off = 117, x_start = -94, dim = 75 },
		["357"]     = { mat = "mw2/hud/ammo_counter_riflebullet_mp.png", w = 4,  h = 22.5,	gap = 2, y_off = 122, x_start = -94, dim = 75 },
		["rifle"]   = { mat = "mw2/hud/ammo_counter_riflebullet_mp.png", w = 4,  h = 22.5,	gap = 2, y_off = 122, x_start = -94, dim = 75 },
		["rocket"]  = { mat = "mw2/hud/ammo_counter_rocket_mp.png",      w = 12, h = 24,	gap = 1, y_off = 122, x_start = -104, dim = 75 },
		["sniper"]  = { mat = "mw2/hud/ammo_counter_rocket_mp.png",      w = 12, h = 24,	gap = 1, y_off = 122, x_start = -104, dim = 75 },
		["shotgun"] = { mat = "mw2/hud/ammo_counter_rocket_mp.png",      w = 12, h = 24,	gap = 1, y_off = 122, x_start = -104, dim = 75 },
		["pistol"]  = { mat = "mw2/hud/ammo_counter_bullet_mp.png",      w = 4, h = 28,	gap = 1, y_off = 117, x_start = -99, dim = 75 },
		["belt"]    = { row_size = 25, row_gap = 1, mat = "mw2/hud/ammo_counter_beltbullet_mp.png", w = 10, h = 5, gap = 0, y_off = 141, x_start = -115, dim = 75 },
	}

	local AMMO_MAP = {
		["ammo_357"]      = "357",
		["ammo_ar2"]      = "rifle",
		["ammo_crossbow"] = "sniper",
		["ammo_pistol"]   = "pistol",
		["ammo_smg1"]     = "default",
		["buckshot"]      = "shotgun",
		["rpg_round"]     = "rocket",
	}

	local MAT_BAR  = Material(hudtype .. "/hud/hud_weaponbar.png", "smooth")
	local MAT_ALT  = Material(hudtype .. "/hud/dpad_40mm_grenade.png", "smooth mips")
	local MAT_GRENADE = Material(hudtype .. "/hud/hud_us_grenade.png", "smooth")
	local MAT_AMMO = {}
	for key, data in pairs(AMMO) do
		MAT_AMMO[key] = Material(data.mat, "smooth")
	end
	local MAT_COMPASS_SHADOW  = Material(hudtype .. "/hud/compass_letters_shadow.png", "smooth")
	local MAT_COMPASS_LETTERS = Material(hudtype .. "/hud/compass_letters.png", "smooth")

	local function GetAmmoConfig(wep)
		if not IsValid(wep) then return AMMO["default"] end
		if wep:GetMaxClip1() >= 100 then return AMMO["belt"] end
		local ammoName = string.lower(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "")
		return AMMO[AMMO_MAP[ammoName]] or AMMO["default"]
	end

	local function GetAmmoKey(ammoCfg)
		for key, data in pairs(AMMO) do
			if data == ammoCfg then return key end
		end
		return "default"
	end

    -- ==========================================
    -- 1. COMPASS DRAWING
    -- ==========================================
    -- local cX   = ScrW() - CoDHUD_S(104)
    -- local cY   = ScrH() - CoDHUD_S(82)
    -- local size = CoDHUD_S(274)
    -- local yaw  = ply:EyeAngles().y
    -- local angle = -(yaw - 90)

    -- local halfFOV = MASK.FOV / 2.2
    -- local fadeDeg = MASK.FADE_DEG
    -- local radius  = size * math.sqrt(2) / 2 + 2
    -- local steps   = 5

    -- render.SetStencilEnable(true)
    -- render.ClearStencil()
    -- render.SetStencilWriteMask(255)
    -- render.SetStencilTestMask(255)
    -- render.SetStencilReferenceValue(1)
    -- render.SetStencilCompareFunction(STENCIL_ALWAYS)
    -- render.SetStencilPassOperation(STENCIL_REPLACE)
    -- render.SetStencilFailOperation(STENCIL_KEEP)
    -- render.SetStencilZFailOperation(STENCIL_KEEP)

    -- render.OverrideColorWriteEnable(true, false)
    -- draw.NoTexture()
    -- surface.SetDrawColor(255, 255, 255, 255)
    
    -- for i = 0, steps - 1 do
        -- local a0 = math.rad(-halfFOV + (i / steps)       * MASK.FOV)
        -- local a1 = math.rad(-halfFOV + ((i + 1) / steps) * MASK.FOV)
        -- surface.DrawPoly({
            -- { x = cX,                         y = cY },
            -- { x = cX + math.sin(a0) * radius, y = cY - math.cos(a0) * radius },
            -- { x = cX + math.sin(a1) * radius, y = cY - math.cos(a1) * radius },
        -- })
    -- end
    -- render.OverrideColorWriteEnable(false, false) -- Re-enable color drawing

    -- render.SetStencilCompareFunction(STENCIL_EQUAL)
    -- render.SetStencilPassOperation(STENCIL_KEEP)

    -- surface.SetMaterial(MAT_COMPASS_SHADOW)
    -- surface.SetDrawColor(0, 0, 0, 255)
    -- surface.DrawTexturedRectRotated(cX, cY, size, size, angle)

    -- surface.SetMaterial(MAT_COMPASS_LETTERS)
    -- surface.SetDrawColor(255, 255, 255, 165)
    -- surface.DrawTexturedRectRotated(cX, cY, size, size, angle)

    -- render.SetStencilEnable(false)

    -- 2. GRENADE DRAWING
    local grenadeCount = math.Clamp(ply:GetAmmoCount("Grenade") or 0, 0, CFG.GRENADE_MAX)
    if grenadeCount > 0 then
        local barW = CoDHUD_SX(CFG.BAR_W)
        local barH = CoDHUD_SY(CFG.BAR_H)
        local barX = ScrW() - CoDHUD_SX(CFG.BAR_X_OFF) - barW
        local barY = ScrH() - CoDHUD_SY(CFG.BAR_Y_OFF) - barH

        local iW = CoDHUD_S(CFG.GRENADE_ICON_W)
        local iH = CoDHUD_S(CFG.GRENADE_ICON_H)
        local stackGap = CoDHUD_S(CFG.GRENADE_STACK_GAP)

        local anchorX = (barX + barW) + CoDHUD_SX(CFG.GRENADE_X_OFF)
        local anchorY = (barY + barH) + CoDHUD_SY(CFG.GRENADE_Y_OFF)

        surface.SetMaterial(MAT_GRENADE)

        for i = (CFG.GRENADE_MAX - 1), 0, -1 do
            if i < grenadeCount then
                local colorIndex = i + 1
                local shade = CFG.GRENADE_SHADES[colorIndex] or CFG.GRENADE_SHADES[#CFG.GRENADE_SHADES]
                surface.SetDrawColor(shade, shade, shade, 255)

                local xPos = anchorX - (i * stackGap)
                local yPos = anchorY

                surface.DrawTexturedRect(xPos, yPos, iW, iH)
            end
        end
    end

    -- 3. WEAPON HUD DRAWING
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    if wep ~= lastWep then
        lastWep       = wep
        wepSwitchTime = CurTime()
    end

    local clip    = wep:Clip1()
    local maxClip = wep:GetMaxClip1()
    local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())

    local barW = CoDHUD_SX(CFG.BAR_W)
    local barH = CoDHUD_SY(CFG.BAR_H)
    local barX = ScrW() - CoDHUD_SX(CFG.BAR_X_OFF) - barW
    local barY = ScrH() - CoDHUD_SY(CFG.BAR_Y_OFF) - barH

    surface.SetMaterial(MAT_BAR)
    surface.SetDrawColor(255, 255, 255, 125)
    surface.DrawTexturedRect(barX, barY, barW, barH)

    if clip >= 0 then
        local resCol = (reserve == 0 or reserve < maxClip)
            and Color(255, 120, 120, 255)
            or  Color(255, 255, 255, 255)

        if reserve >= 1000 then
            DrawSqueezedText(reserve, "MW2_Res_4D", barX + barW + CoDHUD_SX(CFG.RES4_X), barY + CoDHUD_SY(CFG.RES4_Y), resCol, -6, -16, 1)
        elseif reserve >= 100 then
            DrawSqueezedText(reserve, "MW2_Res_3D", barX + barW + CoDHUD_SX(CFG.RES3_X), barY + CoDHUD_SY(CFG.RES3_Y), resCol, -6, -16, 1)
        else
            DrawSqueezedText(reserve, "MW2_Res_3D", barX + barW + CoDHUD_SX(CFG.RES_X), barY + CoDHUD_SY(CFG.RES_Y), resCol, -6, -16, 1)
        end
    end

    local timeSinceSwitch = CurTime() - wepSwitchTime
    if timeSinceSwitch < CFG.WEP_NAME_FADE then
        local alpha = math.Clamp(1 - (timeSinceSwitch / CFG.WEP_NAME_FADE), 0, 1)
        local name  = (wep:GetPrintName() or wep:GetClass()):upper()
        draw.SimpleTextOutlined(name, "MW2_Wep_Name", barX + barW + CoDHUD_SX(CFG.WEP_NAME_X_OFF), barY + CoDHUD_SY(CFG.WEP_NAME_Y_OFF), Color(255, 255, 255, 255 * alpha), 2, 0, outlined and 1.5 or 0, Color(0, 0, 0, 255 * alpha))
    end

    if clip >= 0 and maxClip > 0 then
        local perc      = clip / maxClip
        local isLowClip = (perc <= CFG.STAT_LOW_PERC)
        local reloadSine = isLowClip and ((math.sin(CurTime() * CFG.BULLET_RELOAD_SPD) + 1) / 2) or 0

        local ammoCfg = GetAmmoConfig(wep)
        local ammoKey = GetAmmoKey(ammoCfg)
        local iW      = CoDHUD_S(ammoCfg.w)
        local iH      = CoDHUD_S(ammoCfg.h)
        local iGap    = CoDHUD_S(ammoCfg.gap)
        local iYOff   = CoDHUD_SY(ammoCfg.y_off)
        local iXStart = CoDHUD_SX(ammoCfg.x_start)

        surface.SetMaterial(MAT_AMMO[ammoKey])

        local isBelt  = (ammoCfg.row_size ~= nil)
        local rowSize = isBelt and ammoCfg.row_size or maxClip
        local rowGap  = isBelt and CoDHUD_S(ammoCfg.row_gap) or 0

        for i = 0, maxClip - 1 do
            local isSpent = (i >= clip)
            local shade   = isSpent and ammoCfg.dim or 255

            local r, g, b
            if not isSpent and isLowClip then
                r = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_R))
                g = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_G))
                b = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_B))
            else
                r = shade
                g = shade
                b = shade
            end

            surface.SetDrawColor(r, g, b, CFG.BULLET_ALPHA)

            local col = i % rowSize
            local row = math.floor(i / rowSize)

            local xPos = barX + barW + iXStart - (col * (iW + iGap))
            local yPos = barY + iYOff - (row * (iH + rowGap))

            surface.DrawTexturedRect(xPos, yPos, iW, iH)
        end
    end

    local altType = wep:GetSecondaryAmmoType()
    if altType ~= -1 then
        local altCount = ply:GetAmmoCount(altType)

        surface.SetMaterial(MAT_ALT)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(barX + barW + CoDHUD_SX(CFG.ALT_ICON_X), barY + CoDHUD_SY(CFG.ALT_ICON_Y), CoDHUD_S(CFG.ALT_ICON_SIZE), CoDHUD_S(CFG.ALT_ICON_SIZE))

        local altCol = (altCount > 0) and Color(255, 255, 255, 255) or Color(255, 120, 120, 255)
        DrawSqueezedText(altCount, "MW2_Ammo_Alt", barX + barW + CoDHUD_SX(CFG.ALT_TEXT_X), barY + CoDHUD_SY(CFG.ALT_TEXT_Y), altCol, CFG.ALT_TEXT_SQ, CFG.ALT_TEXT_SQ1, 1)
    end

    if clip >= 0 and maxClip > 0 then
        local perc      = clip / maxClip
        local statText  = ""
        local statCol   = Color(255, 255, 255)
        local isNoAmmo  = false
        local isLowAmmo = false
        local isReloadText  = false

        if clip == 0 and reserve == 0 then
            statText = "#MW2_WEAPON_NO_AMMO"
            isNoAmmo = true
        elseif clip > 0 and reserve == 0 then
            statText = "#MW2_PLATFORM_LOW_AMMO_NO_RELOAD"
            statCol  = Color(255, 230, 0)
            isLowAmmo = true
        elseif perc <= CFG.STAT_LOW_PERC and reserve > 0 then
            statText = "#MW2_PLATFORM_RELOAD"
            isReloadText = true
        end

        if statText ~= "" then
            local cx   = ScrW() / 2
            local cy   = (ScrH() / 2) + CoDHUD_SY(CFG.STAT_Y_OFF)
            local sine = (math.sin(CurTime() * CFG.STAT_FLASH_SPD) + 1) / 2

            local finalCol = table.Copy(statCol)

            if isNoAmmo then
                local glow = 225 + (sine * 30)
                finalCol = Color(glow, 40, 40, glow)
            elseif isLowAmmo or isReloadText then
                finalCol.a = 100 + (sine * 155)
            end

            draw.SimpleTextOutlined(statText, "MW2_Stat_Font", cx + CoDHUD_SX(2), cy + CoDHUD_SY(2), finalCol, 1, 1, 1.5, Color(0, 0, 0, finalCol.a * 0.8))
        end
    end
end
CoDHUD[hudtype].WeaponInfo = weaponinfo
