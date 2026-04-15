-- cl_mw2_announcer_score.lua

local LastScoreState = "tied"
local NearEndTriggered = false
local MusicTriggered = false
local MW2_ANNOUNCER_DEBUG = false

-- Helper to play sounds with toggle checks
local function PlayAnnouncerSound(path, isMusic)
    if isMusic then
        if not GetConVar("mw2_enable_music"):GetBool() then return end
    else
        if not GetConVar("mw2_enable_announcer"):GetBool() then return end
    end

    if MW2_ANNOUNCER_DEBUG then
        print("[ANNOUNCER] PLAY:", path)
    end

    surface.PlaySound(path)
end

-- Resolve announcer sound with language + suffix fallback
local function GetAnnouncerSound(basePath, keys)
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end

    local faction = ply:GetNW2String("MW2_Faction", "")
    if faction == "" then
        faction = cookie.GetString("MW2_SelectedFaction", "rangers")
    end

    if not FACTIONS or not FACTIONS[faction] then
        if MW2_ANNOUNCER_DEBUG then
            print("[ANNOUNCER] Invalid faction:", faction)
        end
        return nil
    end

    local voice = FACTIONS[faction].voice
    local lang = GetConVar("gmod_language"):GetString() or "en"

    local function tryLang(l)
        if MW2_ANNOUNCER_DEBUG then
            print("[ANNOUNCER] Trying language:", l)
        end

        for _, key in ipairs(keys) do

            -- suffix search
            for i = 1, 99 do
                local suffix = (i < 10 and "0" .. i or tostring(i))
                local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. "_" .. suffix .. ".wav"

				print("[ANNOUNCER] CHECKING:", path)

                if file.Exists("sound/" .. path, "GAME") then
                    if MW2_ANNOUNCER_DEBUG then
                        print("[ANNOUNCER] FOUND (suffix):", path)
                    end
                    return path
                end
            end

            -- fallback no suffix
            local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. ".wav"

			print("[ANNOUNCER] CHECKING:", path)

            if file.Exists("sound/" .. path, "GAME") then
                if MW2_ANNOUNCER_DEBUG then
                    print("[ANNOUNCER] FOUND (base):", path)
                end
                return path
            end

            if MW2_ANNOUNCER_DEBUG then
                print("[ANNOUNCER] NOT FOUND:", key, "in", l, "voice:", voice)
            end
        end

        return nil
    end

    local result = tryLang(lang) or tryLang("en")

    if MW2_ANNOUNCER_DEBUG then
        print("[ANNOUNCER] FINAL RESULT:", result or "NONE")
    end

    return result
end

hook.Add("Think", "MW2_Announcer_Score_Think", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- 1. Retrieve current faction and voice tag
    local currentFaction = ply:GetNW2String("MW2_Faction", "")
    if currentFaction == "" then
        currentFaction = cookie.GetString("MW2_SelectedFaction", "rangers")
    end

    if not FACTIONS or not FACTIONS[currentFaction] then return end
    
    local factionVoice = FACTIONS[currentFaction].voice
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
			local sound = GetAnnouncerSound(basePath, { "winning_fight", "winning" })

			if sound then PlayAnnouncerSound(sound, false) end

        elseif (limit - topEnemyScore) <= 300 and topEnemyScore > lpScore and topEnemyScore > 0 then
            NearEndTriggered = true
			local sound = GetAnnouncerSound(basePath, { "losing_fight", "losing" })
			if sound then PlayAnnouncerSound(sound, false) end
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
				local sound = GetAnnouncerSound(basePath, { "ahead", "lead_taken" })
				if sound then PlayAnnouncerSound(sound, false) end
            else
				local sound = GetAnnouncerSound(basePath, { "lead_taken" })
				if sound then PlayAnnouncerSound(sound, false) end
            end
        elseif currentState == "losing" then
			local sound = GetAnnouncerSound(basePath, { "lead_lost" })
			if sound then PlayAnnouncerSound(sound, false) end
        elseif currentState == "tied" and (lpScore > 0 or topEnemyScore > 0) then
			local sound = GetAnnouncerSound(basePath, { "tied" })
			if sound then PlayAnnouncerSound(sound, false) end
        end
        
        LastScoreState = currentState
    end
end)