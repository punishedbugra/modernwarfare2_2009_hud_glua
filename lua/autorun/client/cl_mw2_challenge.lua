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

-- [[ TIMING ]]
local MEDAL_DURATION = 4
local HANGTIME = 2
local FADE_IN_TIME   = 0.1
local EXIT_DURATION  = 0.4
local FADE_OUT_START = MEDAL_DURATION - EXIT_DURATION

local headertext_text    = ""
local headertext_written = 0
local headertext_nxt_w   = 0
local headertext_done    = false
local headertext_hang_st = 0
local headertext_erasing = false
local headertext_blanks  = {}
local headertext_nxt_e   = 0
local headertext_edone   = false
local headertext_erase_sound_played = false


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

-- [[ Copied from Round Start ]]

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
local MW2_RS_GLITCH = { "a", "¶", "Ð", "ق", "§", "ð", "œ", "ش", "Ф" }

hook.Add("Think", "MW2_Challenge_TextThink", function()
    if not activeNotif then return end

    local now = CurTime()

    if not headertext_done then
        local CHARS_PER_SEC = 12
        local interval = 1 / CHARS_PER_SEC

        if now >= headertext_nxt_w and headertext_written < utf8.len(activeNotif.header) then
            headertext_written = headertext_written + 1
            headertext_nxt_w = now + interval
        end

        if headertext_written >= utf8.len(activeNotif.header) then
            headertext_done = true
            headertext_hang_st = now
        end
    end
end)

hook.Add("HUDPaint", "MW2_DrawChallenges", function()
    if not GetConVar("cl_drawhud"):GetBool() then return end
    if _G.MW2_MedalsActive then return end

    if not activeNotif then
        if #notificationQueue > 0 then
            activeNotif = table.remove(notificationQueue, 1)
            activeNotif.start = CurTime()

            -- reset animation state
            headertext_text    = activeNotif.header
            headertext_written = 0
            headertext_nxt_w   = CurTime()
            headertext_done    = false
            headertext_hang_st = 0
            headertext_erasing = false
            headertext_blanks  = {}
            headertext_nxt_e   = 0
            headertext_edone   = false
			headertext_erase_sound_played = false

            surface.PlaySound("hud/mp_challengecomplete_metal_2.mp3")
        else
            return
        end
    end

    local now = CurTime()
    local age = now - activeNotif.start

    local ox = SX(CFG.TITLE_X)
    local oy = SY(CFG.TITLE_Y)

    -- =========================
    -- WRITE PHASE (type-in)
    -- =========================
    if not headertext_done then
        local CHARS_PER_SEC = 16
        local interval = 1 / CHARS_PER_SEC

        if now >= headertext_nxt_w and headertext_written < utf8.len(headertext_text) then
            headertext_written = headertext_written + 1
            headertext_nxt_w = now + interval

            surface.PlaySound("hud/cod_write.mp3")

            if headertext_written >= utf8.len(headertext_text) then
                headertext_done = true
                headertext_hang_st = now
            end
        end
    end

    -- =========================
    -- HOLD PHASE
    -- =========================
    if headertext_done and not headertext_erasing then
        if now >= headertext_hang_st + HANGTIME then
            headertext_erasing = true
            headertext_nxt_e = now
        end
    end

    -- =========================
    -- ERASE PHASE
    -- =========================
    if headertext_erasing and not headertext_edone then
        local erase_time = 0.7
        local step_iv = erase_time / math.max(1, math.ceil(utf8.len(headertext_text) / 5))

        if now >= headertext_nxt_e then
            headertext_nxt_e = now + step_iv
            BlankStep(headertext_blanks, headertext_text, 5)

			if not headertext_erase_sound_played then
				surface.PlaySound("hud/cod_dissapear.mp3")
				headertext_erase_sound_played = true
			end

            if #headertext_blanks >= utf8.len(headertext_text) then
                headertext_edone = true
            end
        end
    end

    -- =========================
    -- RENDER TEXT
    -- =========================
    local disp

    if not headertext_done then
        disp = utf8_sub(headertext_text, 0
		, headertext_written)

        -- glitch effect
        if headertext_written < utf8.len(headertext_text) then
            disp = disp .. MW2_RS_GLITCH[math.random(#MW2_RS_GLITCH)]
        end

    elseif headertext_erasing then
        disp = ApplyBlanks(headertext_text, headertext_blanks)

    else
        disp = headertext_text
    end

    if disp ~= "" then
        DrawCODText( disp, headertext_text, "MW2_ChalHeader_Pri", "MW2_ChalHeader_Sec", "MW2_ChalHeader_Shd", ox, oy, Color(0,220,80) )
    end

	-- Subtitle
	local sub = activeNotif.sub or ""

	local SUB_FADE_TIME = 0.15
	local subAlpha = 1

	if headertext_erasing then
		local t = CurTime() - headertext_nxt_e -- reuse erase start moment
		subAlpha = 1 - math.Clamp(t / SUB_FADE_TIME, 0, 1)
	end

	if sub ~= "" and subAlpha > 0 then
		draw.SimpleText( sub, "MW2_ChalSub", ox, oy + S(30), Color(255, 255, 255, math.floor(255 * subAlpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

    -- end notification
    if age > MEDAL_DURATION then
        activeNotif = nil
    end
end)

-- [[ DEBUG COMMANDS ]]
concommand.Add("challengeplay", function(ply, cmd, args)
    local key = args[1]
	local randomchal = ""
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
	
	if key == "random" then
		local keys = {}

		for k, _ in pairs(challenges) do
			table.insert(keys, k)
		end

		local randomKey = keys[math.random(#keys)]
		local randomchal = challenges[randomKey]

		QueueNotification("debug", randomchal[1], randomchal[2])
	end
end)

concommand.Add("challenge_reset_progress", function()
    MW2_Stats.completed = {}
    SaveMW2Stats()
    print("MW2: Client progression cleared.")
end)