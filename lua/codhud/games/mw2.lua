CoDHUD.RegisterHUD( "mw2", "#CoDHUD.Type.MW2", true )

local hudtype = "mw2"

CoDHUD = CoDHUD or {}
CoDHUD[hudtype] = CoDHUD[hudtype] or {}
CoDHUD.Factions = CoDHUD.Factions or {}
CoDHUD.Gamemodes = CoDHUD.Gamemodes or {}

-- [[ SPECIAL KILLFEED ICONS ]]
killicon.Add("CoDHUD_MW2_Suicide", "killfeed/death_suicide.png", Color(255, 255, 255, 0))
killicon.Add("CoDHUD_MW2_Headshot", "killfeed/death_headshot.png", Color(255, 255, 255, 0))

-- [[ FACTIONS ]]
CoDHUD.Factions[hudtype] = {
	["rangers"] = {
		name = "MW2_MP_US_ARMY_NAME",
		short = "MW2_MP_US_ARMY_SHORT_NAME",
		voice = "US",
		voicepath = "us/mp/us_1mc_",
		spawntheme = "music/US/hz_mp_usspawn_1.mp3",
		spawnIcon = "factions/faction_128_rangers.png",
		scoreIcon = "factions/faction_128_rangers_fade.png",
		color = Color(100, 105, 80),
		glow = Color(240, 230, 190)
	},
	["taskforce141"] = {
		name = "MW2_MP_TASKFORCE_NAME",
		short = "MW2_MP_TASKFORCE_SHORT_NAME",
		voice = "UK",
		voicepath = "uk/mp/uk_1mc_",
		spawntheme = "music/uk/hz_mp_ukspawn_1.mp3",
		spawnIcon = "factions/faction_128_taskforce141.png",
		scoreIcon = "factions/faction_128_taskforce141_fade.png",
		color = Color(70, 80, 80),
		glow = Color(225, 225, 255)
	},
	["seals"] = {
		name = "MW2_MP_SEALS_UDT_NAME",
		short = "MW2_MP_SEALS_UDT_SHORT_NAME",
		voice = "NS",
		voicepath = "ns/mp/ns_1mc_",
		spawntheme = "music/ns/hz_mp_nsspawn_1.mp3",
		spawnIcon = "factions/faction_128_seals.png",
		scoreIcon = "factions/faction_128_seals_fade.png",
		color = Color(65, 90, 130),
		glow = Color(170, 170, 185)
	},
	["ussr"] = {
		name = "MW2_MP_SPETSNAZ_NAME",
		short = "MW2_MPUI_SPETSNAZ_SHORT",
		voice = "RU",
		voicepath = "ru/mp/ru_1mc_",
		spawntheme = "music/ru/hz_mp_ruspawn_1.mp3",
		spawnIcon = "factions/faction_128_ussr.png",
		scoreIcon = "factions/faction_128_ussr_fade.png",
		color = Color(105, 40, 45),
		glow = Color(185, 140, 120)
	},
	["arab"] = {
		name = "MW2_MP_OPFOR_NAME",
		short = "MW2_MPUI_OPFOR_SHORT",
		voice = "AB",
		voicepath = "ab/mp/ab_1mc_",
		spawntheme = "music/ab/hz_mp_abspawn_1.mp3",
		spawnIcon = "factions/faction_128_arab.png",
		scoreIcon = "factions/faction_128_arab_fade.png",
		color = Color(105, 60, 45),
		glow = Color(220, 180, 150)
	},
	["militia"] = {
		name = "MW2_MP_MILITIA_NAME",
		short = "MW2_MP_MILITIA_SHORT_NAME",
		voice = "PG",
		voicepath = "pg/mp/pg_1mc_",
		spawntheme = "music/pg/hz_mp_pgspawn_1.mp3",
		spawnIcon = "factions/faction_128_militia.png",
		scoreIcon = "factions/faction_128_militia_fade.png",
		color = Color(100, 10, 15),
		glow = Color(150, 85, 85)
	},
}

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
    ["oneflag"] = "MW2_OBJECTIVES_ONE_FLAG_ATTACKER_HINT", -- One Flag CTF
    ["arena"] = "MW2_OBJECTIVES_ARENA_HINT", -- Arena
    ["dd"] = "MW2_OBJECTIVES_SD_ATTACKER_HINT", -- Demolition
    ["gtnw"] = "MW2_OBJECTIVES_GTNW_HINT", -- Global Thermonuclear War
}

CoDHUD.Gamemodes[hudtype].Callouts = {
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

CoDHUD.Gamemodes[hudtype].Boosts = {
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

-- [[ HUD ELEMENTS ]]
local function challengecomplete( ... )
    local header = select(1, ...)
    local level = select(2, ...)
    local sub = select(3, ...)

    CoDHUD_HeaderQueue.Push({
        text = CoDHUD_ChallengeTitle(header, level),
        subtext = sub,
        x = 960,
        y = 205,
        color = Color(0,220,80),
        fonts = {
            pri = "MW2_ChalHeader_Pri",
            sec = "MW2_ChalHeader_Sec",
            shd = "MW2_ChalHeader_Shd",
            sub = "MW2_ChalSub"
        }
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
