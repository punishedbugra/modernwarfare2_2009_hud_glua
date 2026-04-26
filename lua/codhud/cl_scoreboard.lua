---- [ SCOREBOARD ] ----

CoDHUD_ScoreboardOpened = false

local hudtype = GetConVar("codhud_game"):GetString() or "mw2"

hook.Add("DrawOverlay", "MW2_Scoreboard_Main", function()
    if not CoDHUD_ScoreboardOpened then return end
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

	if CoDHUD[hudtype] and CoDHUD[hudtype].Scoreboard then
		CoDHUD[hudtype].Scoreboard()
	end

    -- Manually call the custom chat hook so it draws while the rest of the HUD is suppressed
    local hudHooks = hook.GetTable()["HUDPaint"]
    if hudHooks and hudHooks["MW2_DrawChat"] then
        hudHooks["MW2_DrawChat"]()
    end
end)

hook.Add("ScoreboardShow", "MW2_Scoreboard_Open",  function() 
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
	CoDHUD_ScoreboardOpened = true 
	return true
end)

hook.Add("ScoreboardHide", "MW2_Scoreboard_Close", function() 
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
	CoDHUD_ScoreboardOpened = false
end)

hook.Add("HUDShouldDraw", "MW2_Scoreboard_HideHUD", function(name)
    -- Suppress the entire HUD when scoreboard is open (except crosshair)
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
    if CoDHUD_ScoreboardOpened then
        if name == "CHudCrosshair" then return true end
        return false
    end
end)