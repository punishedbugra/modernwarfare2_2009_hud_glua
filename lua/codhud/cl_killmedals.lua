---- [ MEDALS ] ----

-- [[ GLOBALS ]]
-- Global flag for the Challenge System to read
_G.CoDHUD_MedalsActive = _G.CoDHUD_MedalsActive or false
_G.CoDHUD_MedalSystem = _G.CoDHUD_MedalSystem or {}

if CLIENT then
    -- [[ RESOLUTION SCALING ]]
    -- Uniform scale: takes the smaller axis ratio so nothing stretches on
    -- ultrawide (21:9) or narrow (4:3) screens. Matches cl_vgui's GetUIScale().
    local BASE_W, BASE_H = 1920, 1080

    local function GetUIScale()
        local scaleX = ScrW() / BASE_W
        local scaleY = ScrH() / BASE_H
        return math.max(math.min(scaleX, scaleY), 0.5)
    end

    local function S(x) return math.Round(x * GetUIScale()) end

    -- [[ TINKERING MENU ]]
    local MEDAL_CFG = {
        X_OFFSET = 0,    -- Horizontal offset from center
        Y_OFFSET = -250, -- Vertical offset (Match this with cl_mw2_challenge.lua)
    }

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
	
    local MEDAL_DURATION = 1.25
    local FADE_IN_TIME   = 0.125
    local EXIT_DURATION  = 0.125
    local FADE_OUT_START = MEDAL_DURATION - EXIT_DURATION

    local COL_POINTS = Color(255, 255, 50)

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
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("headshot") end
    end)

    net.Receive("CoDHUD_Medal_DoubleKill", function() AddMedalToQueue("SPLASHES_DOUBLEKILL", false, 50)  end)
    net.Receive("CoDHUD_Medal_TripleKill", function() AddMedalToQueue("SPLASHES_TRIPLEKILL", false, 100) end)
    net.Receive("CoDHUD_Medal_MultiKill",  function() AddMedalToQueue("SPLASHES_MULTIKILL",  false, 100) end)

    net.Receive("CoDHUD_Medal_Longshot",   function()
        AddMedalToQueue("SPLASHES_LONGSHOT", true, 50, "SPLASHES_LONGSHOT_DESC")
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("longshot") end
    end)

    net.Receive("CoDHUD_Medal_OneShot",    function()
        AddMedalToQueue("SPLASHES_ONE_SHOT_KILL", true, 0, "SPLASHES_ONE_SHOT_KILL_DESC", true)
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("oneshot") end
    end)

    net.Receive("CoDHUD_Medal_FirstBlood", function() AddMedalToQueue("SPLASHES_FIRSTBLOOD", true,  100, "SPLASHES_FIRSTBLOOD_DESC")              end)
    net.Receive("CoDHUD_Medal_Comeback",   function() AddMedalToQueue("SPLASHES_COMEBACK",    true,  100, "SPLASHES_COMEBACK_DESC") end)
    net.Receive("CoDHUD_Medal_Payback",    function()
        AddMedalToQueue("SPLASHES_REVENGE", true, 50, "SPLASHES_REVENGE_DESC")
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("payback") end
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
		local outlined = GetConVar("codhud_enable_outlinedtext"):GetBool()

		local busy = (activeMedal ~= nil or #medalQueue > 0)
		_G.CoDHUD_MedalsActive = busy

		if not activeMedal and #medalQueue > 0 then
			activeMedal = table.remove(medalQueue, 1)
			activeMedal.start = ct
			
			local cv_fast_medals = GetConVar("codhud_enable_medal_faster")

			local faster = cv_fast_medals:GetBool()

			if (not faster) or (#medalQueue < 3) then
				surface.PlaySound("hud/hud_medal.mp3")
			end
		end

		if not activeMedal then return end

		-- TIME HANDLING
		local speedMul = GetMedalSpeedMultiplier()
		local age = (ct - activeMedal.start) / speedMul

		if age > MEDAL_DURATION then
			activeMedal = nil
			return
		end

		-- VISUALS
		local alpha = 255
		local scale = 1

		if age < FADE_IN_TIME then
			local progress = age / FADE_IN_TIME
			alpha = progress * 255
			scale = Lerp(progress, 3.5, 1.0)

		elseif age > FADE_OUT_START then
			local progress = (age - FADE_OUT_START) / EXIT_DURATION
			alpha = math.Clamp((1 - progress) * 255, 0, 255)
			scale = Lerp(progress, 1.0, 3.0)
		end

		local cx = (ScrW() / 2) + S(MEDAL_CFG.X_OFFSET)
		local cy = (ScrH() / 2) + S(MEDAL_CFG.Y_OFFSET)

		local colWhite      = Color(255, 255, 255, alpha)
		local colBlack      = Color(0, 0, 0, alpha * 0.8)
		local colYellow     = Color(COL_POINTS.r, COL_POINTS.g, COL_POINTS.b, alpha)
		local colRedGlow    = Color(195, 110, 115, alpha * 0.5)
		local colRedOutline = Color(180, 0, 0, alpha * 0.8)

		local mat = Matrix()
		mat:Translate(Vector(cx, cy, 0))
		mat:Scale(Vector(scale, scale, 1))
		mat:Translate(Vector(-cx, -cy, 0))

		cam.PushModelMatrix(mat)

			-- ICON
			if activeMedal.hasIcon then
				surface.SetDrawColor(255, 255, 255, alpha)
				surface.SetMaterial(Material("icons/crosshair_red.png", "smooth"))
				surface.DrawTexturedRect(cx - S(60), cy - S(120), S(120), S(120))
			end

			-- TEXT
			local localizedText = language.GetPhrase("MW2_" .. activeMedal.text)

			draw.SimpleTextOutlined( localizedText, "MW2_MedalGlow", cx, cy, Color(0,0,0,0), 1, 1, 0.75, colRedGlow )
			draw.SimpleTextOutlined( localizedText, "MW2_MedalPrimary", cx, cy, colWhite, 1, 1, 0, colRedOutline )

			-- DESC / POINTS
			if activeMedal.desc then
				local localizedDesc = language.GetPhrase("MW2_" .. activeMedal.desc)

				if activeMedal.isSpecial then
					draw.SimpleTextOutlined( localizedDesc, "MW2_MedalDesc", cx, cy + S(35), colWhite, 1, 1, outlined and 1 or 0, colBlack )
				else
					local descText     = localizedDesc .. " ("
					local pointsText   = "+" .. activeMedal.points
					local bracketClose = ")"

					surface.SetFont("MW2_MedalDesc")
					local w1 = surface.GetTextSize(descText)
					local w2 = surface.GetTextSize(pointsText)
					local totalW = w1 + w2 + surface.GetTextSize(bracketClose)

					local startX = cx - (totalW / 2)

					draw.SimpleTextOutlined( descText, "MW2_MedalDesc", startX, cy + S(35), colWhite, 0, 1, outlined and 1 or 0, colBlack )
					draw.SimpleTextOutlined( pointsText, "MW2_MedalDesc", startX + w1, cy + S(35), colYellow, 0, 1, outlined and 1 or 0, colBlack )
					draw.SimpleTextOutlined( bracketClose, "MW2_MedalDesc", startX + w1 + w2, cy + S(35), colWhite, 0, 1, outlined and 1 or 0, colBlack )
				end
			else
				draw.SimpleTextOutlined( "+" .. activeMedal.points, "MW2_MedalDesc", cx, cy + S(35), colYellow, 1, 1, outlined and 1 or 0, colBlack )
			end

		cam.PopModelMatrix()
	end)
end