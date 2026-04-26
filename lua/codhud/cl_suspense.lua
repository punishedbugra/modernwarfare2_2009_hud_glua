---- [ AMBIANCE / SUSPENSE MUSIC ] ----

local SUSPENSE_VOLUME = 0.5 -- Adjusted for CreateSound (0.1 to 1.0)
local MIN_DELAY = 15        -- seconds
local MAX_DELAY = 20       -- seconds

-- Create the ConVar for the settings menu checkbox
local cvar_enabled = CreateClientConVar("codhud_enable_suspense", "1", true, false, "Enable or disable MW2 suspense music")

local currentSoundObj = nil

local function PlaySuspenseSting()
    -- Safety: Stop any existing sound before starting a new one
	
	if not CoDHUD[CoDHUD_GetHUDType()].SuspenseTracks then return end
	
    if currentSoundObj then
        currentSoundObj:Stop()
        currentSoundObj = nil
    end

    -- Do not play if the ConVar is disabled
    if not cvar_enabled:GetBool() then return end

    local track = table.Random(CoDHUD[CoDHUD_GetHUDType()].SuspenseTracks)
    
    -- CreateSound is more reliable for volume than PlayFile
    currentSoundObj = CreateSound(LocalPlayer(), track)
    
    if currentSoundObj then
        currentSoundObj:SetSoundLevel(0) -- 0 makes it "play in ears" (UI/Music style)
        currentSoundObj:PlayEx(SUSPENSE_VOLUME, 100)
        
        -- We calculate the track length (approximate) or just wait 
        -- until it finishes to schedule the next one to prevent overlaps.
        -- Most of these tracks are 30-60 seconds.
        timer.Simple(60, function()
            ScheduleNextSuspense()
        end)
    end
end

function ScheduleNextSuspense()
    -- Ensure we don't have multiple timers running
    timer.Remove("CoDHUD_SuspenseTimer")
    
    -- Stop logic: if disabled, stop any current music and don't schedule next
    if not cvar_enabled:GetBool() then 
        if currentSoundObj then
            currentSoundObj:Stop()
            currentSoundObj = nil
        end
        return 
    end

    local nextDelay = math.random(MIN_DELAY, MAX_DELAY)
    timer.Create("CoDHUD_SuspenseTimer", nextDelay, 1, function()
        PlaySuspenseSting()
    end)
end

-- Monitor ConVar changes to stop/start logic immediately
cvars.AddChangeCallback("codhud_enable_suspense", function(name, old, new)
    if tobool(new) then
        ScheduleNextSuspense()
    else
        if currentSoundObj then
            currentSoundObj:Stop()
            currentSoundObj = nil
        end
        timer.Remove("CoDHUD_SuspenseTimer")
    end
end)

-- Initialize
hook.Add("InitPostEntity", "CoDHUD_StartSuspenseDirector", function()
    -- First sting after 30 seconds of joining
    timer.Simple(30, function()
        ScheduleNextSuspense()
    end)
end)

-- Kill music on death for immersion
hook.Add("PlayerDeath", "CoDHUD_StopSuspenseOnDeath", function(ply)
    if ply == LocalPlayer() and currentSoundObj then
        currentSoundObj:FadeOut(1)
        timer.Simple(1, function() if currentSoundObj then currentSoundObj:Stop() end end)
    end
end)

-- Stop music if the player leaves the server/shuts down
hook.Add("ShutDown", "CoDHUD_CleanUpSuspense", function()
    if currentSoundObj then currentSoundObj:Stop() end
end)