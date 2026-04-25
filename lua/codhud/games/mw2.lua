CoDHUD.RegisterHUD( "mw2", "CoDHUD.Type.MW2", true )

-- [[ SPECIAL KILLFEED ICONS ]]
killicon.Add("CoDHUD_MW2_Suicide", "killfeed/death_suicide.png", Color(255, 255, 255, 0))
killicon.Add("CoDHUD_MW2_Headshot", "killfeed/death_headshot.png", Color(255, 255, 255, 0))

-- [[ FACTIONS ]]
CoDHUD.Factions = CoDHUD.Factions or {}

CoDHUD.Factions["mw2"] = {
	["rangers"] = {
		name = "MW2_MP_US_ARMY_NAME",
		short = "MW2_MP_US_ARMY_SHORT_NAME",
		voice = "US",
		voicepath = "mw2/us/mp/us_1mc_",
		spawnIcon = "factions/faction_128_rangers.png",
		scoreIcon = "factions/faction_128_rangers_fade.png",
		color = Color(100, 105, 80),
		glow = Color(240, 230, 190)
	},
	["taskforce141"] = {
		name = "MW2_MP_TASKFORCE_NAME",
		short = "MW2_MP_TASKFORCE_SHORT_NAME",
		voice = "UK",
		voicepath = "mw2/uk/mp/uk_1mc_",
		spawnIcon = "factions/faction_128_taskforce141.png",
		scoreIcon = "factions/faction_128_taskforce141_fade.png",
		color = Color(70, 80, 80),
		glow = Color(225, 225, 255)
	},
	["seals"] = {
		name = "MW2_MP_SEALS_UDT_NAME",
		short = "MW2_MP_SEALS_UDT_SHORT_NAME",
		voice = "NS",
		voicepath = "mw2/ns/mp/ns_1mc_",
		spawnIcon = "factions/faction_128_seals.png",
		scoreIcon = "factions/faction_128_seals_fade.png",
		color = Color(65, 90, 130),
		glow = Color(170, 170, 185)
	},
	["ussr"] = {
		name = "MW2_MP_SPETSNAZ_NAME",
		short = "MW2_MPUI_SPETSNAZ_SHORT",
		voice = "RU",
		voicepath = "mw2/ru/mp/ru_1mc_",
		spawnIcon = "factions/faction_128_ussr.png",
		scoreIcon = "factions/faction_128_ussr_fade.png",
		color = Color(105, 40, 45),
		glow = Color(185, 140, 120)
	},
	["arab"] = {
		name = "MW2_MP_OPFOR_NAME",
		short = "MW2_MPUI_OPFOR_SHORT",
		voice = "AB",
		voicepath = "mw2/ab/mp/ab_1mc_",
		spawnIcon = "factions/faction_128_arab.png",
		scoreIcon = "factions/faction_128_arab_fade.png",
		color = Color(105, 60, 45),
		glow = Color(220, 180, 150)
	},
	["militia"] = {
		name = "MW2_MP_MILITIA_NAME",
		short = "MW2_MP_MILITIA_SHORT_NAME",
		voice = "PG",
		voicepath = "mw2/pg/mp/pg_1mc_",
		spawnIcon = "factions/faction_128_militia.png",
		scoreIcon = "factions/faction_128_militia_fade.png",
		color = Color(100, 10, 15),
		glow = Color(150, 85, 85)
	},
}

-- [[ GAMEMODES ]]
CoDHUD.Gamemodes = CoDHUD.Gamemodes or {}

CoDHUD.Gamemodes["mw2"] = {
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