-- [[ cl_mw2_challenge.lua ]]

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

local CFG = {
    TITLE_X         = 960,
    TITLE_Y         = 205,
    TITLE_FONT_SIZE = 46,
    TITLE_WRITE     = 2.1,
    TITLE_HANG      = 3.0,
    TITLE_ERASE     = 0.7,
}

-- [[ TINKERING MENU ]]
local CHAL_CFG = {
    X_OFFSET = 0,
    Y_OFFSET = -250,
}

-- [[ TRACKING DATA & PERSISTENCE ]]
local STATS_FILE = "mw2_client_progression.json"
local defaultStats = {
    completed = {} 
}

if file.Exists(STATS_FILE, "DATA") then
    local readData = file.Read(STATS_FILE, "DATA")
    MW2_Stats = util.JSONToTable(readData) or table.Copy(defaultStats)
    if not MW2_Stats.completed then MW2_Stats.completed = {} end
else
    MW2_Stats = table.Copy(defaultStats)
end

local function SaveMW2Stats()
    file.Write(STATS_FILE, util.TableToJSON(MW2_Stats, true))
end

-- [[ HELPERS ]]
local function BuildChallengeTitle(header, level)
    local name = header

    local mode = nil

    -- Detect prefixes
    if string.find(header, "%[KILLS%]") then
        mode = "MARKSMAN"
        name = string.Trim(string.Replace(header, "[KILLS] ", ""))
    elseif string.find(header, "%[HS%]") then
        mode = "EXPERT"
        name = string.Trim(string.Replace(header, "[HS] ", ""))
	else
		mode = "LEVEL"
		name = language.GetPhrase("MW2_CHALLENGE_" .. header)
    end

    -- Build rank name
    local rank = ""
    if level and level > 0 then
        rank = language.GetPhrase("MW2_CHALLENGE_" .. mode .. "_" .. level)
    end

    if rank == "LEVEL" then
        rank = mode
    end

    -- Format: "AK-47: Marksman II"
    return name .. rank
end

-- [[ QUEUE SYSTEM ]]
local notificationQueue = {}
local activeNotif = nil
local queuedChallenge = false

local function QueueNotification(id, header, level, sub, subval, pts)
    if id ~= "debug" and MW2_Stats.completed[id] then return end

    if _G.MW2_AddScore and pts and pts > 0 then
        timer.Simple(0.25, function()
            _G.MW2_AddScore(pts)
        end)
    end

    if id ~= "debug" then
        MW2_Stats.completed[id] = true
        SaveMW2Stats()
    end

    if (not GetConVar("mw2_enable_challenges"):GetBool()) or GetConVar("mw2_quickdisable_hud"):GetBool() then return end

    table.insert(notificationQueue, {
        id = id,
        header = header,
        level = level,
        sub = sub,
        subval = subval
    })
end

local function ProcessQueue()

    if MW2_HeaderQueue.IsBusy() then return end
	if _G.MW2_MedalsActive then return end
    if #notificationQueue == 0 then return end

    local n = table.remove(notificationQueue, 1)

    local subKey = language.GetPhrase("MW2_CHALLENGE_" .. (n.sub or ""))
    local subVal = n.subval or 0

    local sub
    if subVal > 0 and string.find(subKey, "%%s") then
        sub = string.format(subKey, subVal)
    else
        sub = subKey
    end

    MW2_HeaderQueue.Push({
        text = BuildChallengeTitle(n.header, n.level),
        subtext = sub,
        x = CFG.TITLE_X,
        y = CFG.TITLE_Y,
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

-- [[ NETWORK RECEIVERS ]]
net.Receive("MW2_Challenge_Generic", function()
    local id     = net.ReadString()
    local header = net.ReadString()
    local level  = net.ReadInt(5)
    local sub    = net.ReadString()
    local subval = net.ReadInt(32)
	local pts    = net.ReadInt(32)

    QueueNotification(id, header, level, sub, subval, pts)
end)

net.Receive("MW2_Challenge_Flyswatter", function()
    QueueNotification("flyswatter", "FLYSWATTER", nil, "SHOOT_DOWN_AN_ENEMY_HELICOPTER", nil)
end)

-- [[ FONT INIT ]]
local function MW2_InitChallengeFonts()
    surface.CreateFont("MW2_ChalHeader_Pri", { font = "Carbon Regular", size = S(CFG.TITLE_FONT_SIZE), weight = 10,  blursize = 0, antialias = true,  outline = false })
    surface.CreateFont("MW2_ChalHeader_Sec", { font = "Carbon Regular", size = S(CFG.TITLE_FONT_SIZE), weight = 10,  blursize = 5, antialias = true,  outline = false })
    surface.CreateFont("MW2_ChalHeader_Shd", { font = "Carbon Regular", size = S(CFG.TITLE_FONT_SIZE), weight = 400, blursize = 2, antialias = false, outline = true  })

    surface.CreateFont("MW2_ChalHeader",      { font = "Conduit ITC", size = S(50), weight = 800,  antialias = true })
    surface.CreateFont("MW2_ChalHeader_Glow", { font = "Conduit ITC", size = S(52), weight = 1000, blursize = S(12), antialias = true })
    surface.CreateFont("MW2_ChalSub",         { font = "Conduit ITC", size = S(28), weight = 400,  antialias = true })
end

MW2_InitChallengeFonts()

hook.Add("OnScreenSizeChanged", "MW2_ReinitChallengeFonts", function()
    MW2_InitChallengeFonts()
end)

-- [[ RENDERING ENGINE ]]
hook.Add("Think", "MW2_Challenge_TextThink", function()
    ProcessQueue()
end)

-- hook.Add("HUDPaint", "MW2_DrawChallenges", function()
    -- if not GetConVar("cl_drawhud"):GetBool() then return end
    -- if _G.MW2_MedalsActive then return end
-- end)

-- [[ DEBUG COMMANDS ]]
concommand.Add("challengeplay", function(ply, cmd, args)
    local key = args[1]
	local randomchal = ""
    local challenges = {
		["ghillie1"] = { "GHILLIE", 1, "DESC_GHILLIE", 50, 1000},
		["ghillie2"] = { "GHILLIE", 2, "DESC_GHILLIE", 100, 2500},
		["ghillie3"] = { "GHILLIE", 3, "DESC_GHILLIE", 200, 5000},
		["flyswatter"] = { "FLYSWATTER", nil, "SHOOT_DOWN_AN_ENEMY_HELICOPTER", nil, 5000},
    }
	
    if challenges[key] then QueueNotification("debug", challenges[key][1], challenges[key][2], challenges[key][3], challenges[key][4], challenges[key][5]) end
	
	if key == "random" then
		local keys = {}

		for k, _ in pairs(challenges) do
			table.insert(keys, k)
		end

		local randomKey = keys[math.random(#keys)]
		local randomchal = challenges[randomKey]

		QueueNotification("debug", randomchal[1], randomchal[2], randomchal[3], randomchal[4], randomchal[5])
	end
end)

concommand.Add("challenge_reset_progress", function()
    MW2_Stats.completed = {}
    SaveMW2Stats()
    print("MW2: Client progression cleared.")
end)