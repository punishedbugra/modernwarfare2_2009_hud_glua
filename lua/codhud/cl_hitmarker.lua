---- [ HITMARKER ] ----

if CLIENT then
    -- [[ VARIABLES ]]
    local hitAlpha, hitTime = 0, 0
    local scoreVal, scoreAlpha, scoreTime, scoreStart = 0, 0, 0, 0
    local scoreScale = 1
    local currentPulseAlpha = 255

    _G.CoDHUD_AddScore = function(amount)
        local ct = CurTime()
        scoreVal   = scoreVal + amount
        scoreAlpha = 255
        scoreTime  = ct + 1.5
        scoreStart = ct
    end

    -- [[ HUD PAINT HOOK ]]
    hook.Add("HUDPaint", "CoDHUD_DrawHitmarkerSystem", function()
        local ct = CurTime()
        local cx, cy = ScrW() / 2, ScrH() / 2

        -- DRAW HITMARKER (icon size intentionally fixed, not scaled)
        if ct < hitTime and (GetConVar("codhud_enable_hitmarker"):GetBool() and not GetConVar("codhud_quickdisable_hud"):GetBool()) then
			if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Hitmarker then
				CoDHUD[CoDHUD_GetHUDType()].Hitmarker(hitTime)
			end
        end

        -- SCORE POPUP
        if ct < scoreTime then
            if (GetConVar("codhud_enable_xp"):GetBool() and not GetConVar("codhud_quickdisable_hud"):GetBool()) then
                local animTime = ct - scoreStart

                if animTime < 0.1 then
                    local frac = animTime / 0.2
                    scoreScale        = Lerp(frac, 1, 2.7)
                    currentPulseAlpha = Lerp(frac, 255, 120)
                elseif animTime < 0.3 then
                    local frac = (animTime - 0.2) / 0.2
                    scoreScale        = Lerp(frac, 2.7, 1.0)
                    currentPulseAlpha = Lerp(frac, 120, 255)
                else
                    scoreScale        = 1
                    currentPulseAlpha = 255
                end

                local finalAlpha = scoreAlpha
                if scoreTime - ct < 0.3 then
                    scoreAlpha = math.Approach(scoreAlpha, 0, FrameTime() * 800)
                    finalAlpha = scoreAlpha
                end

				if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].XP then
					CoDHUD[CoDHUD_GetHUDType()].XP(animtime, scoreTime, finalAlpha, scoreScale, currentPulseAlpha, scoreVal)
				end
            end
        else
            scoreVal = 0
        end
    end)

    net.Receive("CoDHUD_HitNotification", function()
        local isKill = net.ReadBool()
        local ct     = CurTime()
        local ply    = LocalPlayer()

        hitAlpha = 255
        hitTime  = ct + 0.5

		if GetConVar("codhud_enable_hitmarker"):GetBool() and not GetConVar("codhud_quickdisable_hud"):GetBool() then
			ply:EmitSound("hud/hitmarker.mp3", 100, 100, 1, CHAN_AUTO)
		end

        if isKill then _G.CoDHUD_AddScore(100) end
    end)
end