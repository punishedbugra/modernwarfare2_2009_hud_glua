---- [ CHALLENGE NOTIFICATIONS & CLIENT TRACKING ] ----

-- [[ TRACKING DATA & PERSISTENCE ]]
local STATS_FILE = "codhud_challenges.json"
local defaultStats = {
    completed = {} 
}

if file.Exists(STATS_FILE, "DATA") then
    local readData = file.Read(STATS_FILE, "DATA")
    CoDHUD_Stats = util.JSONToTable(readData) or table.Copy(defaultStats)
    if not CoDHUD_Stats.completed then CoDHUD_Stats.completed = {} end
else
    CoDHUD_Stats = table.Copy(defaultStats)
end

local function SaveCoDHUDStats()
    file.Write(STATS_FILE, util.TableToJSON(CoDHUD_Stats, true))
end

-- [[ HELPERS ]]
function CoDHUD_ChallengeTitle(header, level, prefix)
    local name = header
	local prefix = prefix or "MW2_CHALLENGE_"

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
		name = language.GetPhrase(prefix .. header)
    end

    -- Build rank name
    local rank = ""
    if level and level > 0 then
        rank = language.GetPhrase(prefix .. mode .. "_" .. level)
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
    if id ~= "debug" and CoDHUD_Stats.completed[id] then return end

    if _G.CoDHUD_AddScore and pts and pts > 0 then
        timer.Simple(0.25, function()
            _G.CoDHUD_AddScore(pts)
        end)
    end

    if id ~= "debug" then
        CoDHUD_Stats.completed[id] = true
        SaveCoDHUDStats()
    end

    if (not GetConVar("codhud_enable_challenges"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

    table.insert(notificationQueue, {
        id = id,
        header = header,
        level = level,
        sub = sub,
        subval = subval
    })
end

local function ProcessQueue()

    if CoDHUD_HeaderQueue.IsBusy() then return end
	if _G.CoDHUD_MedalsActive then return end
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
	
	local hudtype = GetConVar("codhud_game"):GetString() or "mw2"

	if CoDHUD[hudtype] and CoDHUD[hudtype].ChallengeComplete then
		CoDHUD[hudtype].ChallengeComplete( n.header, n.level, sub )
	end
end

-- [[ NETWORK RECEIVERS ]]
net.Receive("CoDHUD_Challenge_Generic", function()
    local id     = net.ReadString()
    local header = net.ReadString()
    local level  = net.ReadInt(5)
    local sub    = net.ReadString()
    local subval = net.ReadInt(32)
	local pts    = net.ReadInt(32)

    QueueNotification(id, header, level, sub, subval, pts)
end)

net.Receive("CoDHUD_Challenge_MW2_Flyswatter", function()
    QueueNotification("flyswatter", "FLYSWATTER", nil, "SHOOT_DOWN_AN_ENEMY_HELICOPTER", nil)
end)

-- [[ RENDERING ENGINE ]]
hook.Add("Think", "CoDHUD_Challenge_TextThink", function()
    ProcessQueue()
end)

-- [[ DEBUG COMMANDS ]]
concommand.Add("codhud_challenge_debug", function(ply, cmd, args)
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

concommand.Add("codhud_challenge_clear", function()
    CoDHUD_Stats.completed = {}
    SaveCoDHUDStats()
    print("[CoDHUD] Cleared Client Challenges.")
end)