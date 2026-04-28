---- [ ANNOUNCER CALLOUTS ] ----

local LastScoreState = "tied"
local NearEndTriggered = false
local MusicTriggered = false
CoDHUD_HadAbove60 = CoDHUD_HadAbove60 or false
CoDHUD_HadAbove30 = CoDHUD_HadAbove30 or false
CoDHUD_LowTimeTriggered = CoDHUD_LowTimeTriggered or false
CoDHUD_TimerLastPlay = CoDHUD_TimerLastPlay or 0
CoDHUD_ActiveTimerTier = CoDHUD_ActiveTimerTier or nil

hook.Add("Think", "CoDHUD_Announcer_Score_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
	local voicefile = CoDHUD[CoDHUD_GetHUDType()].VoiceCallouts
	if not voicefile then return end

    -- 1. Retrieve current faction and voice tag
    local currentFaction = ply:GetNW2String("CoDHUD_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    end

    if not CoDHUD.Factions[CoDHUD_GetHUDType()] or not CoDHUD.Factions[CoDHUD_GetHUDType()][currentFaction] then return end

    -- 2. Calculate Scores
    local lpScore = math.max(0, ply:Frags())
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
    if not limit or limit <= 0 then limit = 75 end

    -- 5. Music Trigger (Passing 'true' to indicate this is music)
    if not MusicTriggered then
        if (limit - lpScore) <= 3 and lpScore > topEnemyScore and lpScore > 0 then
            MusicTriggered = true
            CoDHUD_PlayAnnouncerSound(voicefile.winningmusic, true)
        elseif (limit - topEnemyScore) <= 3 and topEnemyScore > lpScore and topEnemyScore > 0 then
            MusicTriggered = true
            CoDHUD_PlayAnnouncerSound(voicefile.losingmusic, true)
        end
    end

    -- 6. Near End Announcer
    if not NearEndTriggered then
        if (limit - lpScore) <= 3 and lpScore > topEnemyScore and lpScore > 0 then
            NearEndTriggered = true
			local sound = CoDHUD_GetAnnouncerSound(voicefile.winningfight)

			if sound then CoDHUD_PlayAnnouncerSound(sound, false) end

        elseif (limit - topEnemyScore) <= 3 and topEnemyScore > lpScore and topEnemyScore > 0 then
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
            if lpScore == 1 and topEnemyScore == 0 then
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

hook.Add("Think", "CoDHUD_Announcer_Time_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
	local voicefile = CoDHUD[CoDHUD_GetHUDType()].VoiceCallouts
	if not voicefile then return end

    -- 1. Retrieve current faction and voice tag
    local currentFaction = ply:GetNW2String("CoDHUD_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    end

	local timeLeft = (CoDHUD_RoundEndTime or 0) - CurTime()
	local matchTime = CoDHUD_MatchMaxTime or 0
	local timeAnnouncersEnabled = (matchTime > 0)
	local has60Callout = (matchTime > 60)
	
	if not timeAnnouncersEnabled then return end
	
	-- Track crossing of 60 seconds threshold
	if has60Callout and timeLeft >= 60 then
		CoDHUD_HadAbove60 = true
	end

	if has60Callout and CoDHUD_HadAbove60 and timeLeft < 60 then
		CoDHUD_HadAbove60 = false

		local lpScore = math.max(0, LocalPlayer():Frags())
		local topEnemyScore = 0

		for _, p in ipairs(player.GetAll()) do
			if p == LocalPlayer() then continue end
			local score = math.max(0, p:Frags())
			if score > topEnemyScore then
				topEnemyScore = score
			end
		end

		local sound = nil

		if not MusicTriggered then
			if lpScore > topEnemyScore then
				-- winning
				sound = CoDHUD_GetAnnouncerSound(voicefile.winningfight)
				if voicefile.winningmusic then
					MusicTriggered = true
					CoDHUD_PlayAnnouncerSound(voicefile.winningmusic, true)
				end
			else
				-- losing (includes tie fallback)
				sound = CoDHUD_GetAnnouncerSound(voicefile.losingfight)
				if voicefile.losingmusic then
					MusicTriggered = true
					CoDHUD_PlayAnnouncerSound(voicefile.losingmusic, true)
				end
			end
		end

		if sound then
			CoDHUD_PlayAnnouncerSound(sound, false)
		end
	end
	
	-- Track crossing of 30 seconds threshold
	if timeLeft >= 30 then
		CoDHUD_HadAbove30 = true
		CoDHUD_LowTimeTriggered = false
	end

	if CoDHUD_HadAbove30 and timeLeft < 30 and not CoDHUD_LowTimeTriggered then
		CoDHUD_LowTimeTriggered = true
		CoDHUD_HadAbove30 = false

		local sound = CoDHUD_GetAnnouncerSound(voicefile.lowtime)

		if sound then
			CoDHUD_PlayAnnouncerSound(sound, false)
		end
	end
end)

hook.Add("Think", "CoDHUD_Timer_Tick", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local hudtype = CoDHUD_GetHUDType()
    local timerData = CoDHUD[hudtype] and CoDHUD[hudtype].Timer
    if not timerData or not timerData.sound then return end

    local timeLeft = (CoDHUD_RoundEndTime or 0) - CurTime()
    if timeLeft <= 0 then return end

    local now = CurTime()

    -- 1. Find best active tier (lowest threshold that is still active)
    local activeThreshold = nil
    local activeInterval = nil

    for threshold, interval in pairs(timerData.timings or {}) do
        if timeLeft <= threshold then
            if not activeThreshold or threshold < activeThreshold then
                activeThreshold = threshold
                activeInterval = interval
            end
        end
    end

    if not activeThreshold then return end

    -- 2. Switch tier if needed (reset timing when entering new phase)
    if CoDHUD_ActiveTimerTier ~= activeThreshold then
        CoDHUD_ActiveTimerTier = activeThreshold
        CoDHUD_TimerLastPlay = 0
    end

    -- 3. Interval trigger
    if (now - CoDHUD_TimerLastPlay) >= activeInterval then
        CoDHUD_TimerLastPlay = now

        surface.PlaySound(timerData.sound)
    end
end)