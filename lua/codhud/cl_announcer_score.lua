---- [ ANNOUNCER CALLOUTS ] ----

local LastScoreState = "tied"
local NearEndTriggered = false
local MusicTriggered = false
local voicefile = CoDHUD[CoDHUD_GetHUDType()].VoiceCallouts

hook.Add("Think", "CoDHUD_Announcer_Score_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- 1. Retrieve current faction and voice tag
    local currentFaction = ply:GetNW2String("CoDHUD_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    end

    if not CoDHUD.Factions[CoDHUD_GetHUDType()] or not CoDHUD.Factions[CoDHUD_GetHUDType()][currentFaction] then return end
    
    local factionVoice = CoDHUD.Factions[CoDHUD_GetHUDType()][currentFaction].voice
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
    local limit = GetConVar("codhud_score_limit"):GetInt()
    if not limit or limit <= 0 then limit = 7500 end

    -- 5. Music Trigger (Passing 'true' to indicate this is music)
    if not MusicTriggered then
        if (limit - lpScore) <= 300 and lpScore > topEnemyScore and lpScore > 0 then
            MusicTriggered = true
            CoDHUD_PlayAnnouncerSound(voicefile.winningmusic, true)
        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > lpScore and topEnemyScore > 0 then
            MusicTriggered = true
            CoDHUD_PlayAnnouncerSound(voicefile.losingmusic, true)
        end
    end

    -- 6. Near End Announcer
    if not NearEndTriggered then
        if (limit - lpScore) <= 300 and lpScore > topEnemyScore and lpScore > 0 then
            NearEndTriggered = true
			local sound = CoDHUD_GetAnnouncerSound(voicefile.winningfight)

			if sound then CoDHUD_PlayAnnouncerSound(sound, false) end

        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > lpScore and topEnemyScore > 0 then
            NearEndTriggered = true
			local sound = CoDHUD_GetAnnouncerSound(voicefile.losingfight)
			if sound then CoDHUD_PlayAnnouncerSound(sound, false) end
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
				local sound = CoDHUD_GetAnnouncerSound(voicefile.leadtaken)
				if sound then CoDHUD_PlayAnnouncerSound(sound, false) end
            else
				local sound = CoDHUD_GetAnnouncerSound(voicefile.leadtaken)
				if sound then CoDHUD_PlayAnnouncerSound(sound, false) end
            end
        elseif currentState == "losing" then
			local sound = CoDHUD_GetAnnouncerSound(voicefile.leadlost)
			if sound then CoDHUD_PlayAnnouncerSound(sound, false) end
        elseif currentState == "tied" and (lpScore > 0 or topEnemyScore > 0) then
			local sound = CoDHUD_GetAnnouncerSound(voicefile.leadtied)
			if sound then CoDHUD_PlayAnnouncerSound(sound, false) end
        end
        
        LastScoreState = currentState
    end
end)