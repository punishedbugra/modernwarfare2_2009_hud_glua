---- [ SERVER ROUND START ] ----

util.AddNetworkString("CoDHUD_StartRound")
util.AddNetworkString("CoDHUD_RoundStart")
util.AddNetworkString("CoDHUD_SetGamemode")
util.AddNetworkString("CoDHUD_SetAutoFaction")

MW2_Gamemode = CreateConVar("codhud_selected_gamemode", "war", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Which gamemode to start the round on.")
CreateConVar( "codhud_autobalance_on_roundstart", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "If enabled, rebalances all factions at the start of each round." )

function CoDHUD.Factions.BuildFactionPool(factionTable)
    local limit = GetConVar("codhud_autofaction_limit"):GetInt()
    local game = GetConVar("codhud_game"):GetString()

    local all = {}
    for k, _ in pairs(factionTable) do
        table.insert(all, k)
    end

    table.Shuffle(all)

    local pool = {}

    if limit <= 0 or limit >= #all then
        return all -- no restriction
    end

    for i = 1, limit do
        table.insert(pool, all[i])
    end

    return pool
end

function CoDHUD.Factions.RebuildPool()
    local game = GetConVar("codhud_game"):GetString()
	local factionTable = CoDHUD.Factions.validfactions[game] or CoDHUD.Factions.validfactions["mw2"]
    
    CoDHUD.Factions.ActivePool = CoDHUD.Factions.BuildFactionPool(factionTable)

    print("[CoDHUD] Active faction pool:")
    PrintTable(CoDHUD.Factions.ActivePool)
end

function CoDHUD.Factions.PickFromPool(counts)
    local pool = CoDHUD.Factions.ActivePool
    if not pool or #pool == 0 then return "rangers" end

    -- Find empty factions first
    local empty = {}
    for _, f in ipairs(pool) do
        if not counts[f] or counts[f] == 0 then
            table.insert(empty, f)
        end
    end

    -- STEP 1: unique seeding
    if #empty > 0 then
        return empty[math.random(#empty)]
    end

    -- STEP 2: least populated
    local lowest = math.huge
    local best = {}

    for _, f in ipairs(pool) do
        local c = counts[f] or 0

        if c < lowest then
            lowest = c
            best = { f }
        elseif c == lowest then
            table.insert(best, f)
        end
    end

    return best[math.random(#best)]
end

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

hook.Add("PlayerInitialSpawn", "CoDHUD_LateJoinRoundSync", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end

        if ply.CoDHUD_HasSyncedRound then return end
        ply.CoDHUD_HasSyncedRound = true

        local gamemode = GetConVar("codhud_selected_gamemode"):GetString()
        local matchtimer = GetConVar("codhud_matchstart_timer"):GetInt()
        local maxtimer = GetConVar("codhud_time_limit"):GetFloat()

        local game = GetConVar("codhud_game"):GetString()
        local factionTable = CoDHUD.Factions.validfactions[game] or CoDHUD.Factions.validfactions["mw2"]

        local faction = ply.CoDHUD_StoredFaction

        if not faction or not factionTable[faction] then
            faction = CoDHUD.Factions.PickBestFaction(factionTable)
            ply.CoDHUD_StoredFaction = faction
            ply:SetNW2String("CoDHUD_Faction", faction)
        end

        net.Start("CoDHUD_RoundStart")
            net.WriteString(gamemode)
            net.WriteInt(0, 6)
            net.WriteInt(maxtimer, 32)
            net.WriteFloat(CoDHUD_RoundEndTimeSV or 0)
        net.Send(ply)
    end)
end)

hook.Add("PlayerDisconnected", "CoDHUD_ResetLateJoinFlag", function(ply)
    ply.CoDHUD_HasSyncedRound = nil
end)