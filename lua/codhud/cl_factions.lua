---- [ CLIENT FACTION DATA ] ----


CoDHUD.Factions["universal"] = {
	["unassigned"] = {
		name = "Unassigned",
		short = "Unassigned",
	},
}

-- local function SyncFactionPersistence()
    -- local lp = LocalPlayer()
    -- if not IsValid(lp) then return end
    -- local saved = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    -- local hudType = CoDHUD_GetHUDType()
	-- if not CoDHUD or not CoDHUD.Factions or not hudType or not CoDHUD.Factions[hudType] then return end

	-- if not CoDHUD.Factions[hudType][saved] then
		-- saved = "rangers"
	-- end
    -- lp:SetNW2String("CoDHUD_Faction", saved)
    -- RunConsoleCommand("codhud_setfaction", saved)
-- end

-- hook.Add("InitPostEntity", "MW2_SyncFactionOnJoin", function()
    -- timer.Simple(1.5, function()
        -- SyncFactionPersistence()
    -- end)
-- end)

-- hook.Add("NotifyShouldTransmit", "MW2_SyncFactionOnSpawn", function(ent, should)
    -- if ent == LocalPlayer() and should then
        -- SyncFactionPersistence()
    -- end
-- end)
