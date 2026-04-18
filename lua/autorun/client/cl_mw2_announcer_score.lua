-- cl_mw2_announcer_score.lua

local LastScoreState = "tied"
local NearEndTriggered = false
local MusicTriggered = false

hook.Add("Think", "MW2_Announcer_Score_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- 1. Retrieve current faction and voice tag
    local currentFaction = ply:GetNW2String("MW2_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("MW2_SelectedFaction", "rangers")
    end

    if not MW2Factions or not MW2Factions[currentFaction] then return end
    
    local factionVoice = MW2Factions[currentFaction].voice
    local basePath = "announcer/" .. factionVoice .. "/" .. factionVoice .. "_"

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
            MW2HUD_PlayAnnouncerSound("music/hz_mp_opfor_victory.mp3", true)
        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > 0 then
            MusicTriggered = true
            MW2HUD_PlayAnnouncerSound("music/hz_mp_timeout_losing.mp3", true)
        end
    end

    -- 6. Near End Announcer
    if not NearEndTriggered then
        if (limit - lpScore) <= 300 and lpScore > topEnemyScore and lpScore > 0 then
            NearEndTriggered = true
			local sound = MW2HUD_GetAnnouncerSound(basePath, { "winning_fight", "winning" })

			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end

        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > lpScore and topEnemyScore > 0 then
            NearEndTriggered = true
			local sound = MW2HUD_GetAnnouncerSound(basePath, { "losing_fight", "losing" })
			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
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
				local sound = MW2HUD_GetAnnouncerSound(basePath, { "ahead", "lead_taken" })
				if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
            else
				local sound = MW2HUD_GetAnnouncerSound(basePath, { "lead_taken" })
				if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
            end
        elseif currentState == "losing" then
			local sound = MW2HUD_GetAnnouncerSound(basePath, { "lead_lost" })
			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
        elseif currentState == "tied" and (lpScore > 0 or topEnemyScore > 0) then
			local sound = MW2HUD_GetAnnouncerSound(basePath, { "tied" })
			if sound then MW2HUD_PlayAnnouncerSound(sound, false) end
        end
        
        LastScoreState = currentState
    end
end)