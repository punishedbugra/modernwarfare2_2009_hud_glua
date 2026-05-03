---- [ CLIENT SCOREBOARD ] ----

CoDHUD_ScoreboardOpened = false

CoDHUD = CoDHUD or {}
CoDHUD.Scoreboard = CoDHUD.Scoreboard or {}

CoDHUD.Scoreboard.Scroll = 0
CoDHUD.Scoreboard.ContentHeight = 0
CoDHUD.Scoreboard.VisibleHeight = CoDHUD_S(800)

hook.Add("OnScreenSizeChanged", "MW2_Scoreboard_Resize", function()
    CoDHUD.Scoreboard.VisibleHeight = CoDHUD_S(800)
end)

hook.Add("DrawOverlay", "MW2_Scoreboard_Main", function()
    if not CoDHUD_ScoreboardOpened then return end
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

	if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Scoreboard then
		CoDHUD[CoDHUD_GetHUDType()].Scoreboard()
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

hook.Add("PlayerBindPress", "MW2_Scoreboard_Scroll", function(ply, bind, pressed)
    if not CoDHUD_ScoreboardOpened then return end
    if not pressed then return end

    local sb = CoDHUD.Scoreboard

    -- how much we can scroll
    local maxScroll = math.max(0, sb.ContentHeight - sb.VisibleHeight)

    if bind == "invnext" then
        sb.Scroll = sb.Scroll + 60
    elseif bind == "invprev" then
        sb.Scroll = sb.Scroll - 60
    else
        return
    end

    -- clamp AFTER change
    sb.Scroll = math.Clamp(sb.Scroll, 0, maxScroll)

    return true
end)

hook.Add("HUDShouldDraw", "MW2_Scoreboard_HideHUD", function(name)
    -- Suppress the entire HUD when scoreboard is open (except crosshair)
	if (not GetConVar("codhud_enable_scoreboard"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
    if CoDHUD_ScoreboardOpened then
        if name == "CHudCrosshair" then return true end
        return false
    end
end)