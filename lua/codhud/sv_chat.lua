---- [ SERVER CHAT & KILLFEED ] ----
CoDHUD = CoDHUD or {}
CoDHUD.Factions = CoDHUD.Factions or {}

util.AddNetworkString("CoDHUD_ChatMessage")
util.AddNetworkString("CoDHUD_PlayerChangeTeam")
util.AddNetworkString("CoDHUD_PlayerAutoBalanced")

CreateConVar("codhud_autofaction_limit", "2", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Max number of active factions before enforcing auto-balance.")

-- Faction Name Mapping
CoDHUD.Factions.validfactions = {
	["mw2"] = {
		["rangers"]      = "Army Rangers",
		["taskforce141"] = "Task Force 141",
		["seals"]        = "Navy SEALs",
		["ussr"]         = "Spetsnaz",
		["arab"]         = "OpFor",
		["militia"]      = "Militia"
	},
	["mw3"] = {
		["sas"]			= "Special Air Service",
		["delta"]		= "Delta Force",
		["gign"]		= "GIGN",
		["innercircle"]	= "Inner Circle",
		["militia"]		= "Africa Militia",
		["ussr"]		= "Spetsnaz",
		["pmc"]			= "P.M.C."
	},
}

function CoDHUD.Factions.GetFactionCounts()
    local counts = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local f = ply:GetNW2String("CoDHUD_Faction", "rangers")
            counts[f] = (counts[f] or 0) + 1
        end
    end

    return counts
end

function CoDHUD.Factions.PickBestFaction(factionTable)
    local counts = CoDHUD.Factions.GetFactionCounts()

    local limit = GetConVar("codhud_autofaction_limit"):GetInt()

    local factions = {}
    for k, _ in pairs(factionTable) do
        table.insert(factions, k)
    end

    -- If we are still below the faction cap, allow free random seeding
    local activeFactionCount = 0
    for _, c in pairs(counts) do
        if c > 0 then activeFactionCount = activeFactionCount + 1 end
    end

    if limit > 0 and activeFactionCount < limit then
        -- still seeding factions → random but avoid empty duplication bias
        return factions[math.random(#factions)]
    end

    -- Otherwise: pick least populated faction
    local lowestCount = math.huge
    local best = {}

    for _, f in ipairs(factions) do
        local c = counts[f] or 0

        if c < lowestCount then
            lowestCount = c
            best = { f }
        elseif c == lowestCount then
            table.insert(best, f)
        end
    end

    return best[math.random(#best)]
end

-- [[ 1. FACTION SYNC ]]

function CoDHUD.Factions.GetFactionName(factionID)
	local c = GetConVar("codhud_game")
	c = c and c:GetString() or "mw2"
	
    local factionTable = CoDHUD.Factions.validfactions[c]

    if not factionTable then
        factionTable = CoDHUD.Factions.validfactions["mw2"] -- fallback
    end

    return factionTable[factionID]
end

cvars.AddChangeCallback("codhud_game", function(convar, oldValue, newValue)
    print("[CoDHUD] Game changed from " .. oldValue .. " to " .. newValue)

    if not CoDHUD.Factions.validfactions[newValue] then
        newValue = "mw2"
    end

    local players = player.GetAll()

    if GetConVar("codhud_autobalance_on_roundstart"):GetBool() then
        CoDHUD.Factions.RebuildPool()

        local counts = {}
        table.Shuffle(players)

        for _, ply in ipairs(players) do
            if IsValid(ply) then
                local faction = CoDHUD.Factions.PickFromPool(counts)

                counts[faction] = (counts[faction] or 0) + 1

                ply.CoDHUD_StoredFaction = faction
                ply:SetNW2String("CoDHUD_Faction", faction)

				local textstr = "MW2_GAME_CHANGEDTO"
				local factionName = CoDHUD.Factions[CoDHUD_GetHUDType()][faction].name

				net.Start("CoDHUD_PlayerAutoBalanced")
				net.WriteString(textstr)
				net.WriteString(ply:Nick())
				net.WriteString(factionName)
				net.Broadcast()

                print("[CoDHUD] (Game Change) " .. ply:Nick() .. " -> " .. faction)
            end
        end
    else
        local factionTable = CoDHUD.Factions.validfactions[newValue]

        for _, ply in ipairs(players) do
            if IsValid(ply) then
                local faction = CoDHUD.Factions.PickBestFaction(factionTable)

                ply.CoDHUD_StoredFaction = faction
                ply:SetNW2String("CoDHUD_Faction", faction)

				local textstr = "MW2_GAME_CHANGEDTO"
				local factionName = CoDHUD.Factions[CoDHUD_GetHUDType()][faction].name

				net.Start("CoDHUD_PlayerAutoBalanced")
				net.WriteString(textstr)
				net.WriteString(ply:Nick())
				net.WriteString(factionName)
				net.Broadcast()

                print("[CoDHUD] (Game Change) " .. ply:Nick() .. " -> " .. faction)
            end
        end
    end

    timer.Simple(0.1, function()
        for _, ply in ipairs(players) do
            if IsValid(ply) then
                ply:SetFrags(0)
                ply:SetDeaths(0)

                if ply:Alive() then
                    ply:KillSilent()
                end

                ply:Spawn()
            end
        end
    end)
end, "CoDHUD_GameChangeCallback")

-- This command is called by the client's SyncFactionPersistence() 
-- whenever they join or change their faction menu.
concommand.Add("codhud_setfaction", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local faction = args[1] and string.lower(args[1]) or nil

	if faction and CoDHUD.Factions.GetFactionName(faction) then
		-- manual selection overrides everything
	else
		local game = GetConVar("codhud_game"):GetString()
		local factionTable = CoDHUD.Factions.validfactions[game] or CoDHUD.Factions.validfactions["mw2"]

		faction = CoDHUD.Factions.PickBestFaction(factionTable)
	end
    
    -- Validate that it is a real faction
    if not CoDHUD.Factions.GetFactionName(faction) then faction = "rangers" end

    -- Store it in the player object so it survives through the session
    ply.CoDHUD_StoredFaction = faction
    
    -- Update the networked string so the HUD and Scoreboard see it
    ply:SetNW2String("CoDHUD_Faction", faction)
    
	local textstr = "MW2_GAME_CHANGEDTO"
	local factionName = CoDHUD.Factions[CoDHUD_GetHUDType()].name or ""

	if factionName ~= "" then
		net.Start("CoDHUD_PlayerAutoBalanced")
		net.WriteString(textstr)
		net.WriteString(ply:Nick())
		net.WriteString(factionName)
		net.Broadcast()
	end
	
    print("[CoDHUD] Player " .. ply:Nick() .. " joined team " .. CoDHUD.Factions.GetFactionName(faction))
end)

-- Ensure the faction persists through death/respawn on the server side
hook.Add("PlayerSpawn", "CoDHUD_Chat_PersistenceSync", function(ply)
    local game = GetConVar("codhud_game")
    game = game and game:GetString() or "mw2"

    local factionTable = CoDHUD.Factions.validfactions[game] or CoDHUD.Factions.validfactions["mw2"]

    local currentFaction = ply.CoDHUD_StoredFaction or ply:GetNW2String("CoDHUD_Faction", "rangers")

    if factionTable[currentFaction] then
        ply.CoDHUD_StoredFaction = currentFaction
        ply:SetNW2String("CoDHUD_Faction", currentFaction)
        return
    end

    local keys = {}
    for k, _ in pairs(factionTable) do
        table.insert(keys, k)
    end

    local newFaction = CoDHUD.Factions.PickBestFaction(factionTable)

    ply.CoDHUD_StoredFaction = newFaction
    ply:SetNW2String("CoDHUD_Faction", newFaction)
	
	local textstr = "MW2_GAME_CHANGEDTO"
	local factionName = CoDHUD.Factions.GetFactionName(newFaction)

    print("[CoDHUD] " .. ply:Nick() .. " had invalid faction, reassigned to " .. CoDHUD.Factions.GetFactionName(newFaction))

	net.Start("CoDHUD_PlayerAutoBalanced")
	net.WriteString(textstr)
	net.WriteString(ply:Nick())
	net.WriteString(factionName)
	net.Broadcast()
end)

-- [[ 2. CHAT INTERCEPTION ]]
hook.Add("PlayerSay", "CoDHUD_Chat_Interceptor", function(ply, text, teamOnly)
    if text == "" then return "" end

    -- Get faction ID and exact Name
    local factionID = ply:GetNW2String("CoDHUD_Faction", "rangers")
    local factionName = CoDHUD.Factions.GetFactionName(factionID) or "Army Rangers"

    -- Broadcast to relevant players via Net Message
    net.Start("CoDHUD_ChatMessage")
        net.WriteEntity(ply)
        net.WriteString(text)
        net.WriteBool(teamOnly)
        net.WriteString(factionName)
        
    if teamOnly then
        -- TEAM CHAT: Only send to players with the exact same faction
        local targets = {}
        for _, v in ipairs(player.GetAll()) do
            if v:GetNW2String("CoDHUD_Faction", "rangers") == factionID then
                table.insert(targets, v)
            end
        end
        net.Send(targets)
    else
        -- GLOBAL CHAT: Send to everyone
        net.Broadcast()
    end

    -- Suppress the default Garry's Mod chat so we don't get double messages
    -- return "" -- Unnecessary.
end)