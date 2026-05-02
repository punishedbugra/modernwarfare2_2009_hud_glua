---- [ SERVER ROUND START ] ----

util.AddNetworkString("CoDHUD_StartRound")
util.AddNetworkString("CoDHUD_RoundStart")
util.AddNetworkString("CoDHUD_SetGamemode")

MW2_Gamemode = CreateConVar("codhud_selected_gamemode", "war", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Which gamemode to start the round on.")
CreateConVar( "codhud_autobalance_on_roundstart", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "If enabled, rebalances all factions at the start of each round." )

local function AutoBalanceAllPlayers()
    local game = GetConVar("codhud_game"):GetString()
    local factionTable = CoDHUD.Factions.validfactions[game] or CoDHUD.Factions.validfactions["mw2"]

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local newFaction = CoDHUD.Factions.PickBestFaction(factionTable)

            ply.CoDHUD_StoredFaction = newFaction
            ply:SetNW2String("CoDHUD_Faction", newFaction)

            print("[CoDHUD] (Round Start Balance) " .. ply:Nick() .. " -> " .. CoDHUD.Factions.GetFactionName(newFaction))
        end
    end
end

net.Receive("CoDHUD_SetGamemode", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local gm = net.ReadString()

    -- local valid = {
        -- war=true, dm=true, dom=true, sd=true, sab=true,
        -- ctf=true, hq=true, oneflag=true, arena=true, dd=true, gtnw=true
    -- }

    -- if not valid[gm] then return end

    RunConsoleCommand("codhud_selected_gamemode", gm)
end)

net.Receive("CoDHUD_StartRound", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local gamemode = GetConVar("codhud_selected_gamemode"):GetString()
    local matchtimer = GetConVar("codhud_matchstart_timer"):GetInt()
    local maxtimer = GetConVar("codhud_time_limit"):GetFloat()

    -- NEW: set round timer (convert minutes → seconds)
	if maxtimer > 0 then
		CoDHUD_RoundEndTimeSV = CurTime() + (matchtimer + 1) + (maxtimer * 60)
	else
		CoDHUD_RoundEndTimeSV = nil
	end
	
	CoDHUD_FirstBloodOccurred = false

	if GetConVar("codhud_autobalance_on_roundstart"):GetBool() then
		AutoBalanceAllPlayers()
	end

    for _, p in ipairs(player.GetAll()) do
        p:SetFrags(0)
        p:SetDeaths(0)
        p:Spawn()
    end

	net.Start("CoDHUD_RoundStart")
		net.WriteString(gamemode)
		net.WriteInt(matchtimer, 6)
		net.WriteInt(maxtimer, 32)
		net.WriteFloat(CoDHUD_RoundEndTimeSV or 0) -- NEW
	net.Broadcast()
end)