---- [ SERVER ROUND START ] ----

util.AddNetworkString("CoDHUD_StartRound")
util.AddNetworkString("CoDHUD_RoundStart")
util.AddNetworkString("CoDHUD_SetGamemode")
util.AddNetworkString("CoDHUD_SetAutoFaction")
util.AddNetworkString("CoDHUD_RestrictFactionChange")
util.AddNetworkString("CoDHUD_SyncFactionPool")

CreateConVar( "codhud_selected_gamemode", "war", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Which gamemode to start the round on." )
CreateConVar( "codhud_autobalance_on_roundstart", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "If enabled, rebalances all factions at the start of each round." )

net.Receive("CoDHUD_SetGamemode", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local gm = net.ReadString()

    RunConsoleCommand("codhud_selected_gamemode", gm)
end)

net.Receive("CoDHUD_SetAutoFaction", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local val = net.ReadString()

    RunConsoleCommand("codhud_autofaction_limit", val)
end)

net.Receive("CoDHUD_StartRound", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local gamemode = GetConVar("codhud_selected_gamemode"):GetString()
    local matchtimer = GetConVar("codhud_matchstart_timer"):GetInt()
    local maxtimer = GetConVar("codhud_time_limit"):GetFloat()

	if maxtimer > 0 then
		CoDHUD_RoundEndTimeSV = CurTime() + (matchtimer + 1) + (maxtimer * 60)
	else
		CoDHUD_RoundEndTimeSV = nil
	end
	
	CoDHUD_FirstBloodOccurred = false

	if GetConVar("codhud_autobalance_on_roundstart"):GetBool() then
		CoDHUD.Factions.RebuildPool()
		
		net.Start("CoDHUD_SyncFactionPool")
		net.WriteTable(CoDHUD.Factions.ActivePool or {})
		net.Broadcast()
		
		local players = player.GetAll()
		table.Shuffle(players)

		local counts = {}

		for _, ply in ipairs(players) do
			if IsValid(ply) then
				local faction = CoDHUD.Factions.PickFromPool(counts)

				counts[faction] = (counts[faction] or 0) + 1

				ply.CoDHUD_StoredFaction = faction
				ply:SetNW2String("CoDHUD_Faction", faction)

				print("[CoDHUD] (Round Start) " .. ply:Nick() .. " -> " .. faction)
			end
		end
		
		timer.Simple( 0.1, function()
			for _, p in ipairs(player.GetAll()) do
				p:SetFrags(0)
				p:SetDeaths(0)
				p:Spawn()
				p:Freeze(true)
			end

			net.Start("CoDHUD_RoundStart")
				net.WriteString(gamemode)
				net.WriteInt(matchtimer, 6)
				net.WriteInt(maxtimer, 32)
				net.WriteFloat(CoDHUD_RoundEndTimeSV or 0) -- NEW
			net.Broadcast()
		end)
		
		timer.Simple( matchtimer, function()
			for _, p in ipairs(player.GetAll()) do
				p:Freeze(false)
			end
		end)
		return
	end

    for _, p in ipairs(player.GetAll()) do
        p:SetFrags(0)
        p:SetDeaths(0)
        p:Spawn()
		p:Freeze(true)
    end
		
	timer.Simple( matchtimer, function()
		for _, p in ipairs(player.GetAll()) do
			p:Freeze(false)
		end
	end)
	
	net.Start("CoDHUD_RoundStart")
		net.WriteString(gamemode)
		net.WriteInt(matchtimer, 6)
		net.WriteInt(maxtimer, 32)
		net.WriteFloat(CoDHUD_RoundEndTimeSV or 0) -- NEW
	net.Broadcast()
end)