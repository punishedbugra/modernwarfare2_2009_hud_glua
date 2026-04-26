---- [ MEDALS ] ----

-- [[ GLOBALS ]]
-- Global flag for the Challenge System to read
_G.CoDHUD_MedalsActive = _G.CoDHUD_MedalsActive or false
_G.CoDHUD_MedalSystem = _G.CoDHUD_MedalSystem or {}

if CLIENT then
    -- [[ TINKERING MENU ]]
    local medalQueue  = {}
    local activeMedal = nil

    -- [[ HELPERS ]]
	function _G.CoDHUD_MedalSystem.Clear()
		medalQueue = {}
		activeMedal = nil
		_G.CoDHUD_MedalsActive = false
	end

	function _G.CoDHUD_MedalSystem.SkipCurrent()
		activeMedal = nil
	end

	function _G.CoDHUD_MedalSystem.GetQueueSize()
		return #medalQueue + (activeMedal and 1 or 0)
	end

	function _G.CoDHUD_MedalSystem.IsBusy()
		return activeMedal ~= nil or #medalQueue > 0
	end

    -- TIMING
	local function GetMedalSpeedMultiplier()
		local count = #medalQueue
		local t = 1.25
		
		if not GetConVar("codhud_enable_medal_faster"):GetBool() then return t end

		if count >= 6 then return t * 0.2 end  -- ultra fast
		if count >= 4 then return t * 0.4 end   -- very fast
		if count >= 3 then return t * 0.6 end   -- faster
		if count >= 2 then return t * 0.8 end  -- slightly faster

		return t -- normal
	end

    -- [[ MEDAL QUEUE LOGIC ]]
    local function AddMedalToQueue(txt, hasIcon, pts, desc, isSpecial)
        if _G.CoDHUD_AddScore then _G.CoDHUD_AddScore(pts) end
        
        -- Check for the CVar before queuing
		if (not GetConVar("codhud_enable_medals"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

        table.insert(medalQueue, {
            text      = txt,
            hasIcon   = hasIcon,
            points    = pts,
            desc      = desc,
            isSpecial = isSpecial
        })
    end

    -- [[ NETWORK RECEIVERS (Communicating with Challenge System) ]]
    net.Receive("CoDHUD_Medal_Headshot",   function()
        AddMedalToQueue("SPLASHES_HEADSHOT", true, 50)
        if _G.CoDHUD_OnMedalReceived then _G.CoDHUD_OnMedalReceived("headshot") end
    end)

    net.Receive("CoDHUD_Medal_DoubleKill", function() AddMedalToQueue("SPLASHES_DOUBLEKILL", false, 50)  end)
    net.Receive("CoDHUD_Medal_TripleKill", function() AddMedalToQueue("SPLASHES_TRIPLEKILL", false, 100) end)
    net.Receive("CoDHUD_Medal_MultiKill",  function() AddMedalToQueue("SPLASHES_MULTIKILL",  false, 100) end)

    net.Receive("CoDHUD_Medal_Longshot",   function()
        AddMedalToQueue("SPLASHES_LONGSHOT", true, 50, "SPLASHES_LONGSHOT_DESC")
        if _G.CoDHUD_OnMedalReceived then _G.CoDHUD_OnMedalReceived("longshot") end
    end)

    net.Receive("CoDHUD_Medal_OneShot",    function()
        AddMedalToQueue("SPLASHES_ONE_SHOT_KILL", true, 0, "SPLASHES_ONE_SHOT_KILL_DESC", true)
        if _G.CoDHUD_OnMedalReceived then _G.CoDHUD_OnMedalReceived("oneshot") end
    end)

    net.Receive("CoDHUD_Medal_FirstBlood", function() AddMedalToQueue("SPLASHES_FIRSTBLOOD", true,  100, "SPLASHES_FIRSTBLOOD_DESC")              end)
    net.Receive("CoDHUD_Medal_Comeback",   function() AddMedalToQueue("SPLASHES_COMEBACK",    true,  100, "SPLASHES_COMEBACK_DESC") end)
    net.Receive("CoDHUD_Medal_Payback",    function()
        AddMedalToQueue("SPLASHES_REVENGE", true, 50, "SPLASHES_REVENGE_DESC")
        if _G.CoDHUD_OnMedalReceived then _G.CoDHUD_OnMedalReceived("payback") end
    end)

	-- MEDAL PROGRESS
	hook.Add("Think", "CoDHUD_Medal_Progress", function()
		if not activeMedal then return end

		local speedMul = GetMedalSpeedMultiplier()
		local ct = CurTime()

		-- ONLY track time, DO NOT terminate here anymore
		-- (prevents double-termination conflicts with HUDPaint)
		activeMedal._ct = ct
		activeMedal._speedMul = speedMul
	end)

	-- RENDERING
	hook.Add("HUDPaint", "MW2_DrawMedalsSystem", function()
		local ct = CurTime()
		
		local busy = (activeMedal ~= nil or #medalQueue > 0)
		_G.CoDHUD_MedalsActive = busy

		if not activeMedal and #medalQueue > 0 then
			activeMedal = table.remove(medalQueue, 1)
			activeMedal.start = ct
			
			local cv_fast_medals = GetConVar("codhud_enable_medal_faster")

			local faster = cv_fast_medals:GetBool()

			if (not faster) or (#medalQueue < 3) then
				if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].MedalsSound then
					surface.PlaySound(CoDHUD[CoDHUD_GetHUDType()].MedalsSound)
				end
			end
		end

		if not activeMedal then return end

		-- TIME HANDLING
		local speedMul = GetMedalSpeedMultiplier()

		if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Medals then
			local finished = CoDHUD[CoDHUD_GetHUDType()].Medals(speedMul, activeMedal)

			if finished then
				activeMedal = nil
			end
		end
	end)
end