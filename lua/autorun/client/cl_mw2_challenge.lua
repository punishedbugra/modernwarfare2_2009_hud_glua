-- [[ cl_mw2_challenge.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x) return math.Round(x * GetUIScale()) end

-- [[ TINKERING MENU ]]
local CHAL_CFG = {
    X_OFFSET = 0,
    Y_OFFSET = -250,
}

-- [[ TIMING ]]
local MEDAL_DURATION = 3.6
local FADE_IN_TIME   = 0.1
local EXIT_DURATION  = 0.4
local FADE_OUT_START = MEDAL_DURATION - EXIT_DURATION

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

-- [[ QUEUE SYSTEM ]]
local notificationQueue = {}
local activeNotif = nil

local function QueueNotification(id, header, sub)
    if id ~= "debug" and MW2_Stats.completed[id] then return end

    table.insert(notificationQueue, { header = header, sub = sub, start = 0 })

    if id ~= "debug" then
        MW2_Stats.completed[id] = true
        SaveMW2Stats()
    end
end

-- [[ NETWORK RECEIVERS ]]
net.Receive("MW2_Challenge_Generic", function()
    local id = net.ReadString()
    local header = net.ReadString()
    local sub = net.ReadString()
    QueueNotification(id, header, sub)
end)

net.Receive("MW2_Challenge_Flyswatter", function()
    QueueNotification("flyswatter", "Flyswatter", "Shoot down an enemy helicopter")
end)

-- [[ FONT INIT ]]
local function MW2_InitChallengeFonts()
    surface.CreateFont("MW2_ChalHeader",      { font = "Conduit ITC", size = S(50), weight = 800,  antialias = true })
    surface.CreateFont("MW2_ChalHeader_Glow", { font = "Conduit ITC", size = S(52), weight = 1000, blursize = S(12), antialias = true })
    surface.CreateFont("MW2_ChalSub",         { font = "Conduit ITC", size = S(28), weight = 400,  antialias = true })
end

MW2_InitChallengeFonts()

hook.Add("OnScreenSizeChanged", "MW2_ReinitChallengeFonts", function()
    MW2_InitChallengeFonts()
end)

-- [[ RENDERING ENGINE ]]
hook.Add("HUDPaint", "MW2_DrawChallenges", function()
    if _G.MW2_MedalsActive then return end
    if not activeNotif then
        if #notificationQueue > 0 then
             activeNotif = table.remove(notificationQueue, 1)
            activeNotif.start = CurTime()
            surface.PlaySound("hud/mp_challengecomplete_metal_2.mp3")
        else return end
    end

    local age = CurTime() - activeNotif.start
    if age > MEDAL_DURATION then activeNotif = nil return end

    local alpha, scale = 255, 1
    if age < FADE_IN_TIME then
        local progress = age / FADE_IN_TIME
        alpha = progress * 255
        scale = Lerp(progress, 3.5, 1.0)
    elseif age > FADE_OUT_START then
        local progress = (age - FADE_OUT_START) / EXIT_DURATION
        alpha = math.Clamp((1 - progress) * 255, 0, 255)
        scale = Lerp(progress, 1.0, 6.0)
    end

    local cx = (ScrW() / 2) + S(CHAL_CFG.X_OFFSET)
    local cy = (ScrH() / 2) + S(CHAL_CFG.Y_OFFSET)

    local colRed   = Color(200, 30, 30,  alpha)
    local colWhite = Color(255, 255, 255, alpha)

    local mat = Matrix()
    mat:Translate(Vector(cx, cy, 0))
    mat:Scale(Vector(scale, scale, 1))
    mat:Translate(Vector(-cx, -cy, 0))

    cam.PushModelMatrix(mat)
        draw.SimpleText(activeNotif.header, "MW2_ChalHeader_Glow", cx, cy,          colRed,   1, 1)
        draw.SimpleText(activeNotif.header, "MW2_ChalHeader",       cx, cy,          colWhite, 1, 1)
        draw.SimpleText(activeNotif.sub,    "MW2_ChalSub",          cx, cy + S(40),  colWhite, 1, 1)
    cam.PopModelMatrix()
end)

-- [[ DEBUG COMMANDS ]]
concommand.Add("challengeplay", function(ply, cmd, args)
    local key = args[1]
    local challenges = {
        ["ghillie1"]   = {"Ghillie in the Mist I", "Get 50 one-shot kills"},
        ["ghillie2"]   = {"Ghillie in the Mist II", "Get 100 one-shot kills"},
        ["ghillie3"]   = {"Ghillie in the Mist III", "Get 200 one-shot kills"},
        ["rpg1"]       = {"Multi-RPG I", "Kill 2 or more enemies with one RPG 5 times"},
        ["rpg2"]       = {"Multi-RPG II", "Kill 2 or more enemies with one RPG 25 times"},
        ["rpg3"]       = {"Multi-RPG III", "Kill 2 or more enemies with one RPG 50 times"},
        ["frag1"]      = {"Multi-Frag I", "Kill 2 or more enemies with one Frag 5 times"},
        ["frag2"]      = {"Multi-Frag II", "Kill 2 or more enemies with one Frag 25 times"},
        ["frag3"]      = {"Multi-Frag III", "Kill 2 or more enemies with one Frag 50 times"},
        ["collateral"] = {"Collateral Damage", "Kill 2 or more enemies with one sniper bullet"},
        ["fearless"]   = {"Fearless", "Kill 10 enemies in a single match without dying"},
        ["potato1"]    = {"Hot Potato I", "Kill 5 enemies with thrown back grenades"},
        ["potato2"]    = {"Hot Potato II", "Kill 10 enemies with thrown back grenades"},
        ["backstabber"]= {"Backstabber", "Stab an enemy in the back"},
        ["hardlanding"]= {"Hard Landing", "Kill an enemy that is in mid-air"},
        ["marksman1"] = {"Marksman I", "Get 100 kills"},
        ["marksman2"] = {"Marksman II", "Get 250 kills"},
        ["marksman3"] = {"Marksman III", "Get 500 kills"},
        ["marksman4"] = {"Marksman IV", "Get 750 kills"},
        ["marksman5"] = {"Marksman V", "Get 1000 kills"},
        ["marksman6"] = {"Marksman VI", "Get 3000 kills"},
        ["marksman7"] = {"Marksman VII", "Get 5000 kills"},
        ["marksman8"] = {"Marksman VIII", "Get 10000 kills"},
        ["expert1"]   = {"Expert I", "Get 50 headshot kills"},
        ["expert2"]   = {"Expert II", "Get 150 headshot kills"},
        ["expert3"]   = {"Expert III", "Get 300 headshot kills"},
        ["expert4"]   = {"Expert IV", "Get 750 headshot kills"},
        ["expert5"]   = {"Expert V", "Get 1500 headshot kills"},
        ["expert6"]   = {"Expert VI", "Get 2500 headshot kills"},
        ["expert7"]   = {"Expert VII", "Get 3500 headshot kills"},
        ["expert8"]   = {"Expert VIII", "Get 5000 headshot kills"},
        ["grenade1"]  = {"Grenade Kill I", "Kill 100 enemies with grenades"},
        ["grenade2"]  = {"Grenade Kill II", "Kill 250 enemies with grenades"},
        ["grenade3"]  = {"Grenade Kill III", "Kill 500 enemies with grenades"},
        ["crouch1"]   = {"Crouch Shot I", "Kill 50 enemies while crouching"},
        ["crouch2"]   = {"Crouch Shot II", "Kill 150 enemies while crouching"},
        ["crouch3"]   = {"Crouch Shot III", "Kill 300 enemies while crouching"},
        ["flyswatter"]= {"Flyswatter", "Shoot down an enemy helicopter"},
        ["goodbye"]   = {"Goodbye", "Fall 30 feet or more to your death"},
        ["basejump"]  = {"Base Jump", "Fall 15 feet or more and survive"},
        ["renaissance"]={"Renaissance Man", "Kill 3 enemies with 3 different weapons"},
        ["survivalist"]={"Survivalist", "Survive for 5 minutes straight"},
        ["thebrink"]  = {"The Brink", "Get 3 kills while near death"},
        ["thinkfast"] = {"Think Fast", "Kill an enemy with a grenade impact"},
        ["rival"]     = {"Rival", "Kill the same enemy 5 times"},
        ["nbk"]       = {"NBK", "Get 3 longshot kills in one life"},
        ["allpro"]    = {"All Pro", "2 headshots with 1 bullet"},
        ["airborne"]  = {"Airborne", "2 kill streak while in mid-air"}
    }
    if challenges[key] then QueueNotification("debug", challenges[key][1], challenges[key][2]) end
end)

concommand.Add("challenge_reset_progress", function()
    MW2_Stats.completed = {}
    SaveMW2Stats()
    print("MW2: Client progression cleared.")
end)