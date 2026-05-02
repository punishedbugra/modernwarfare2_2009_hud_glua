---- [ CLIENT FACTION DATA ] ----

local function SyncFactionPersistence()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    local saved = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    local hudType = CoDHUD_GetHUDType()
	if not CoDHUD or not CoDHUD.Factions or not hudType or not CoDHUD.Factions[hudType] then return end

	if not CoDHUD.Factions[hudType][saved] then
		saved = "rangers"
	end
    lp:SetNW2String("CoDHUD_Faction", saved)
    RunConsoleCommand("codhud_setfaction", saved)
end

hook.Add("InitPostEntity", "MW2_SyncFactionOnJoin", function()
    timer.Simple(1.5, function()
        SyncFactionPersistence()
    end)
end)

hook.Add("NotifyShouldTransmit", "MW2_SyncFactionOnSpawn", function(ent, should)
    if ent == LocalPlayer() and should then
        SyncFactionPersistence()
    end
end)

concommand.Add("set_faction", function(ply, cmd, args)
    local faction = args[1] and string.lower(args[1]) or ""
    if CoDHUD.Factions[CoDHUD_GetHUDType()][faction] then
        LocalPlayer():SetNW2String("CoDHUD_Faction", faction)
        cookie.Set("CoDHUD_SelectedFaction", faction)
        RunConsoleCommand("codhud_setfaction", faction)
        print("[CoD HUD] You joined team " .. language.GetPhrase(CoDHUD.Factions[CoDHUD_GetHUDType()][faction].name))
    else
        print("[CoD HUD] Tried to join an invalid faction.")
    end
end)
