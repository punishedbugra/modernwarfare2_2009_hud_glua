---- [ MINIMAP ] ----
CoDHUD_DeathCache = CoDHUD_DeathCache or {}
CoDHUD_VisCache = CoDHUD_VisCache or {}

hook.Add("HUDPaint", "MW2_Minimap_UAV", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if (not GetConVar("codhud_enable_minimap"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
	if not GetConVar("cl_drawhud"):GetBool() then return end

	if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Minimap then
		CoDHUD[CoDHUD_GetHUDType()].Minimap()
	end
end)