-- cl_mw2_announcer_score.lua

local LastScoreState = "tied"
local NearEndTriggered = false
local MusicTriggered = false

-- Helper to play sounds with toggle checks
local function PlayAnnouncerSound(path, isMusic)
    if isMusic then
        if not GetConVar("mw2_enable_music"):GetBool() then return end
    else
        if not GetConVar("mw2_enable_announcer"):GetBool() then return end
    end
    
    surface.PlaySound(path)
end

hook.Add("Think", "MW2_Announcer_Score_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- 1. Retrieve current faction and short tag
    local currentFaction = ply:GetNW2String("MW2_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("MW2_SelectedFaction", "rangers")
    end

    if not FACTIONS or not FACTIONS[currentFaction] then return end
    
    local facShort = FACTIONS[currentFaction].short
    local basePath = "announcer/" .. facShort .. "/" .. facShort .. "_"

    -- 2. Calculate Scores
    local lpScore = math.max(0, ply:Frags()) * 100
    local topEnemyScore = 0

    for _, p in ipairs(player.GetAll()) do
        if p == ply then continue end
        local pScore = math.max(0, p:Frags()) * 100
        if pScore > topEnemyScore then 
            topEnemyScore = pScore 
        end
    end

    -- 3. Reset logic for new rounds
    if lpScore == 0 and topEnemyScore == 0 then
        LastScoreState = "tied"
        NearEndTriggered = false
        MusicTriggered = false
        return
    end

    -- 4. Get Replicated Score Limit
    local limit = GetConVar("mw2_score_limit"):GetInt()
    if not limit or limit <= 0 then limit = 7500 end

    -- 5. Music Trigger (Passing 'true' to indicate this is music)
    if not MusicTriggered then
        if (limit - lpScore) <= 300 and lpScore > 0 then
            MusicTriggered = true
            PlayAnnouncerSound("music/hz_mp_opfor_victory.mp3", true)
        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > 0 then
            MusicTriggered = true
            PlayAnnouncerSound("music/hz_mp_timeout_losing.mp3", true)
        end
    end

    -- 6. Near End Announcer
    if not NearEndTriggered then
        if (limit - lpScore) <= 300 and lpScore > topEnemyScore and lpScore > 0 then
            NearEndTriggered = true
            local winLines = {
                "1mc_winning_fight_01.mp3",
                "1mc_winning_01.mp3",
                "1mc_winning_02.mp3",
                "1mc_winning_03.mp3"
            }
            PlayAnnouncerSound(basePath .. winLines[math.random(#winLines)], false)

        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > lpScore and topEnemyScore > 0 then
            NearEndTriggered = true
            local loseLines = {
                "1mc_losing_fight_01.mp3",
                "1mc_losing_fight_02.mp3",
                "1mc_losing_01.mp3",
                "1mc_losing_02.mp3",
                "1mc_losing_03.mp3"
            }
            PlayAnnouncerSound(basePath .. loseLines[math.random(#loseLines)], false)
        end
    end

    -- 7. General Score State Triggers
    local currentState = "tied"
    if lpScore > topEnemyScore then 
        currentState = "winning"
    elseif lpScore < topEnemyScore then 
        currentState = "losing"
    end

    if currentState ~= LastScoreState then
        if currentState == "winning" then
            if lpScore == 100 and topEnemyScore == 0 then
                local aheadSounds = {"1mc_ahead_01.mp3", "1mc_lead_taken_01.mp3"}
                PlayAnnouncerSound(basePath .. aheadSounds[math.random(#aheadSounds)], false)
            else
                PlayAnnouncerSound(basePath .. "1mc_lead_taken_01.mp3", false)
            end
        elseif currentState == "losing" then
            PlayAnnouncerSound(basePath .. "1mc_lead_lost_01.mp3", false)
        elseif currentState == "tied" and (lpScore > 0 or topEnemyScore > 0) then
            local tiedLines = {"1mc_tied_01.mp3", "1mc_tied_02.mp3"}
            PlayAnnouncerSound(basePath .. tiedLines[math.random(#tiedLines)], false)
        end
        
        LastScoreState = currentState
    end
end)