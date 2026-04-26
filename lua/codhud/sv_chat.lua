---- [ CHAT ] ----

util.AddNetworkString("CoDHUD_ChatMessage")

-- Faction Name Mapping
local validfactions = {
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

-- [[ 1. FACTION SYNC ]]

local function GetFactionName(factionID)
	local c = GetConVar("codhud_game")
	c = c and c:GetString() or "mw2"
	
    local factionTable = validfactions[c]

    if not factionTable then
        factionTable = validfactions["mw2"] -- fallback
    end

    return factionTable[factionID]
end

cvars.AddChangeCallback("codhud_game", function(convar, oldValue, newValue)
    print("[CoDHUD] Game changed from " .. oldValue .. " to " .. newValue)

    -- Fallback safety
    if not validfactions[newValue] then
        newValue = "mw2"
    end

    local factionTable = validfactions[newValue]
    local factionKeys = {}

    -- Collect valid faction IDs
    for k, _ in pairs(factionTable) do
        table.insert(factionKeys, k)
    end

    -- Assign random faction to every player
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local randomFaction = factionKeys[math.random(#factionKeys)]

            -- Store + network it (same logic as your concommand)
            ply.CoDHUD_StoredFaction = randomFaction
            ply:SetNW2String("CoDHUD_Faction", randomFaction)

            print("[CoDHUD] " .. ply:Nick() .. " reassigned to " .. GetFactionName(randomFaction))
        end
    end
end, "CoDHUD_GameChangeCallback")

-- This command is called by the client's SyncFactionPersistence() 
-- whenever they join or change their faction menu.
concommand.Add("codhud_setfaction", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local faction = args[1] and string.lower(args[1]) or "rangers"
    
    -- Validate that it is a real faction
    if not GetFactionName(faction) then faction = "rangers" end

    -- Store it in the player object so it survives through the session
    ply.CoDHUD_StoredFaction = faction
    
    -- Update the networked string so the HUD and Scoreboard see it
    ply:SetNW2String("CoDHUD_Faction", faction)
    
    print("[CoDHUD] Player " .. ply:Nick() .. " joined team " .. GetFactionName(faction))
end)

-- Ensure the faction persists through death/respawn on the server side
hook.Add("PlayerSpawn", "CoDHUD_Chat_PersistenceSync", function(ply)
    -- If we already know their faction from this session, re-apply it immediately
    if ply.CoDHUD_StoredFaction then
        ply:SetNW2String("CoDHUD_Faction", ply.CoDHUD_StoredFaction)
    else
        -- Default to rangers ONLY if we haven't received a client sync yet
        ply:SetNW2String("CoDHUD_Faction", "rangers")
    end
end)

-- [[ 2. CHAT INTERCEPTION ]]
hook.Add("PlayerSay", "CoDHUD_Chat_Interceptor", function(ply, text, teamOnly)
    if text == "" then return "" end

    -- Get faction ID and exact Name
    local factionID = ply:GetNW2String("CoDHUD_Faction", "rangers")
    local factionName = GetFactionName(factionID) or "Army Rangers"

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