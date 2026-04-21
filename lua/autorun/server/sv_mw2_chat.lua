-- [[ sv_mw2_chat.lua ]]
util.AddNetworkString("MW2_ChatMessage")

-- Faction Name Mapping
local FACTION_NAMES = {
    ["rangers"]      = "Army Rangers",
    ["taskforce141"] = "Task Force 141",
    ["seals"]        = "Navy SEALs",
    ["ussr"]         = "Spetsnaz",
    ["arab"]         = "OpFor",
    ["militia"]      = "Militia"
}

-- [[ 1. FACTION SYNC ]]

-- This command is called by the client's SyncFactionPersistence() 
-- whenever they join or change their faction menu.
concommand.Add("mw2_setfaction", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local faction = args[1] and string.lower(args[1]) or "rangers"
    
    -- Validate that it is a real faction
    if not FACTION_NAMES[faction] then faction = "rangers" end

    -- Store it in the player object so it survives through the session
    ply.MW2_StoredFaction = faction
    
    -- Update the networked string so the HUD and Scoreboard see it
    ply:SetNW2String("MW2_Faction", faction)
    
    print("[MW2 Server] " .. ply:Nick() .. " synchronized as: " .. FACTION_NAMES[faction])
end)

-- Ensure the faction persists through death/respawn on the server side
hook.Add("PlayerSpawn", "MW2_Chat_PersistenceSync", function(ply)
    -- If we already know their faction from this session, re-apply it immediately
    if ply.MW2_StoredFaction then
        ply:SetNW2String("MW2_Faction", ply.MW2_StoredFaction)
    else
        -- Default to rangers ONLY if we haven't received a client sync yet
        ply:SetNW2String("MW2_Faction", "rangers")
    end
end)

-- [[ 2. CHAT INTERCEPTION ]]

hook.Add("PlayerSay", "MW2_Chat_Interceptor", function(ply, text, teamOnly)
    if text == "" then return "" end

    -- Get faction ID and exact Name
    local factionID = ply:GetNW2String("MW2_Faction", "rangers")
    local factionName = FACTION_NAMES[factionID] or "Army Rangers"

    -- Broadcast to relevant players via Net Message
    net.Start("MW2_ChatMessage")
        net.WriteEntity(ply)
        net.WriteString(text)
        net.WriteBool(teamOnly)
        net.WriteString(factionName)
        
    if teamOnly then
        -- TEAM CHAT: Only send to players with the exact same faction
        local targets = {}
        for _, v in ipairs(player.GetAll()) do
            if v:GetNW2String("MW2_Faction", "rangers") == factionID then
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