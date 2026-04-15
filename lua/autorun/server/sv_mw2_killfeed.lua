-- [[ sv_mw2_killfeed.lua ]]

util.AddNetworkString("MW2_Killfeed_Death")

-- [[ 1. DAMAGE TRACKER ]]
-- Captures the damage type right before death so we know if it was a fall, blast, etc.
hook.Add("EntityTakeDamage", "MW2_Killfeed_CaptureDamage", function(target, dmginfo)
    if target:IsPlayer() or target:IsNPC() then
        target.MW2_LastDamageType = dmginfo:GetDamageType()
        
        -- Check for headshot
        if target:IsPlayer() and target:LastHitGroup() == HITGROUP_HEAD then
            target.MW2_WasHeadshot = true
        else
            target.MW2_WasHeadshot = false
        end
    end
end)

-- [[ 2. PLAYER DEATH BROADCAST ]]
hook.Add("PlayerDeath", "MW2_Killfeed_PlayerDeath", function(victim, inflictor, attacker)
    net.Start("MW2_Killfeed_Death")
        net.WriteEntity(victim)
        net.WriteEntity(attacker)
        
        -- Determine Damage Type
        local dmgType = victim.MW2_LastDamageType or 0
        
        -- If the last hit was a headshot, we pass -1 as a special ID
        if victim.MW2_WasHeadshot then
            net.WriteInt(-1, 32)
        else
            net.WriteInt(dmgType, 32)
        end
    net.Broadcast()

    -- Reset temp data
    victim.MW2_LastDamageType = nil
    victim.MW2_WasHeadshot = false
end)

-- [[ 3. NPC DEATH BROADCAST ]]
hook.Add("OnNPCKilled", "MW2_Killfeed_NPCDeath", function(npc, attacker, inflictor)
    net.Start("MW2_Killfeed_Death")
        net.WriteEntity(npc)
        net.WriteEntity(attacker)
        
        local dmgType = npc.MW2_LastDamageType or 0
        net.WriteInt(dmgType, 32)
    net.Broadcast()
end)

-- [[ 4. FACTION & TAG SYNC ]]
-- We removed the hardcoded "rangers" default here.
-- This hook now only ensures the NW2 string is updated if a stored value exists.
hook.Add("PlayerSpawn", "MW2_Killfeed_SyncData", function(ply)
    -- If the server already knows the faction (from sv_mw2_chat persistence), re-assert it.
    -- Otherwise, we let the client's SyncFactionPersistence() handle the update.
    if ply.MW2_StoredFaction then
        ply:SetNW2String("MW2_Faction", ply.MW2_StoredFaction)
    end
    
    -- Sync Clan Tag (if applicable)
    local tag = ply:GetInfo("mw2_clantag") or ""
    ply:SetNW2String("MW2_ClanTag", tag)
end)