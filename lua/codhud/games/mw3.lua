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
	{ "#MW2_MPUI_ONE_FLAG", "oneflag" },
	{ "#MW2_MPUI_ARENA", "arena" },
	{ "#MW2_MPUI_DD", "dd" },
	{ "#MW2_MPUI_GTNW", "gtnw" },
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
        x = 960,
        y = 205,
        color = Color(0,220,80),
        fonts = {
            pri = "MW2_ChalHeader_Pri",
            sec = "MW2_ChalHeader_Sec",
            shd = "MW2_ChalHeader_Shd",
            sub = "MW2_ChalSub"
        },
		align = align or nil
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

	-- Teams
	CoDHUD_HeaderQueue.Push({
		teams = teams,
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
