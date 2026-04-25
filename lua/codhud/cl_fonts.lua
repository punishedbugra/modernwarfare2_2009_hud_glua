---- [ FONTS ] ----

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

-- [[ FONT INIT ]]
local function InitiateCoDFonts()
	-- [ MW2 ]
	-- Challenges
    surface.CreateFont( "MW2_ChalHeader_Pri",		{ font = "Carbon Regular", size = S(46), weight = 10,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_ChalHeader_Sec",		{ font = "Carbon Regular", size = S(46), weight = 10,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_ChalHeader_Shd",		{ font = "Carbon Regular", size = S(46), weight = 400, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont( "MW2_ChalHeader",			{ font = "Conduit ITC", size = S(50), weight = 800,  antialias = true })
    surface.CreateFont( "MW2_ChalHeader_Glow",		{ font = "Conduit ITC", size = S(52), weight = 1000, blursize = S(12), antialias = true })
    surface.CreateFont( "MW2_ChalSub",				{ font = "Conduit ITC", size = S(28), weight = 400,  antialias = true })
	
	-- Chat
	surface.CreateFont( "MW2_ChatFont",				{ font = "Conduit ITC",  size = S(22),  weight = 400,  antialias = true, shadow = true })
	
	-- Hitmarker / XP
	surface.CreateFont( "MW2_Score_Main",			{ font = "BankGothic Md BT", size = S(36), weight = 400, antialias = true, shadow = true })
	surface.CreateFont( "MW2_Score_Plus",			{ font = "BankGothic Md BT", size = S(32), weight = 800, antialias = true, shadow = true })
	
	-- Killfeed
    surface.CreateFont( "MW2_KillfeedFont",			{ font = "Conduit ITC", size = S(34), weight = 400, antialias = true, shadow = true, outline = false, })
	
	-- Medals
	surface.CreateFont( "MW2_MedalPrimary",			{ font = "Conduit ITC", size = S(42), weight = 800,  antialias = true })
	surface.CreateFont( "MW2_MedalGlow",			{ font = "Conduit ITC", size = S(44), weight = 1000, antialias = true, blursize = S(12) })
	surface.CreateFont( "MW2_MedalOutline",			{ font = "Conduit ITC", size = S(42), weight = 900,  antialias = true, outline = false })
	surface.CreateFont( "MW2_MedalPoints",			{ font = "Conduit ITC", size = S(30), weight = 400,  antialias = true })
	surface.CreateFont( "MW2_MedalDesc",			{ font = "Conduit ITC", size = S(26), weight = 500,  antialias = true })
	
	-- Round End
	surface.CreateFont( "MW2_RE_Sc_Pri",			{ font = "BankGothic Md BT", size = S(54),  weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Sc_Sec",			{ font = "BankGothic Md BT", size = S(54),  weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Sc_Shd",			{ font = "BankGothic Md BT", size = S(54),  weight = 400, blursize = 2, antialias = false, outline = true  })
    
    surface.CreateFont( "MW2_RE_Re_Pri",			{ font = "BankGothic Md BT", size = S(72), weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Re_Sec",			{ font = "BankGothic Md BT", size = S(72), weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Re_Shd",			{ font = "BankGothic Md BT", size = S(72), weight = 400, blursize = 2, antialias = false, outline = true  })
    
    surface.CreateFont( "MW2_RE_Li_Pri",			{ font = "BankGothic Md BT", size = S(48),  weight = 400, blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Li_Sec",			{ font = "BankGothic Md BT", size = S(48),  weight = 400, blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RE_Li_Shd",			{ font = "BankGothic Md BT", size = S(48),  weight = 400, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont( "MW2_RE_Bonus",				{ font = "BankGothic Md BT", size = S(48),  weight = 400, blursize = 0, antialias = true,  outline = false })
		
	-- Round Start	
	surface.CreateFont( "MW2_RS_H_Pri",				{ font = "Carbon Regular", size = S(64), weight = 800,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RS_H_Sec",				{ font = "Carbon Regular", size = S(64), weight = 800,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RS_H_Shd",				{ font = "Carbon Regular", size = S(64), weight = 800, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont( "MW2_RS_O_Pri",				{ font = "Carbon Regular", size = S(46), weight = 10,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RS_O_Sec",				{ font = "Carbon Regular", size = S(46), weight = 10,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont( "MW2_RS_O_Shd",				{ font = "Carbon Regular", size = S(46), weight = 400, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont( "MW2_RS_S_Pri",				{ font = "Carbon Regular", size = S(32), weight = 400, antialias = true, shadow = true })

    surface.CreateFont( "MW2_RS_Timer",				{ font = "BankGothic Md BT", size = S(80), weight = 400, antialias = true, shadow = true })

	-- Score Bar	
	surface.CreateFont( "MW2_Timer", 				{ font = "BankGothic Md BT", size = S(34), weight = 400, antialias = true, shadow = false, })
    surface.CreateFont( "MW2_Status",				{ font = "BankGothic Md BT", size = S(34), weight = 400, antialias = true, shadow = true, })
    surface.CreateFont( "MW2_Font",					{ font = "BankGothic Md BT", size = S(36), weight = 400, antialias = true, })
		
	-- Scoreboard
    surface.CreateFont( "MW2_Scoreboard_Text",		{ font = "Conduit ITC Light", size = S(34), weight = 400, antialias = true, shadow = true, })
    surface.CreateFont( "MW2_Scoreboard_Timer",		{ font = "BankGothic Md BT", size = S(34), weight = 400, antialias = true, })
	
	-- IFF
    surface.CreateFont("MW2_TargetName_Primary",	{ font = "Conduit ITC Bold",  size = S(32), weight = 400, antialias = true, shadow = true })

	-- Voice Chat
	surface.CreateFont("MW2_VoiceFont",				{ font = "Conduit ITC",  size = S(30),  weight = 600,  antialias = true, shadow = true })
	
	-- Weapon HUD
    surface.CreateFont("MW2_Res",					{ font = "BankGothic Md BT", size = S(64), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Res_3D",				{ font = "BankGothic Md BT", size = S(48), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Res_4D",				{ font = "BankGothic Md BT", size = S(38), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Wep_Name",				{ font = "BankGothic Md BT", size = S(38), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Stat_Font",				{ font = "BankGothic Md BT", size = S(28), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Ammo_Alt",				{ font = "BankGothic Md BT", size = S(36), weight = 400, antialias = true, shadow = true, extended = true })
end

InitiateCoDFonts()

hook.Add("OnScreenSizeChanged", "CoDHUD_ReinitChallengeFonts", function()
    InitiateCoDFonts()
end)