-- [[ sv_mw2_killfeed.lua ]]

util.AddNetworkString("MW2_Killfeed_Death")
util.AddNetworkString("MW2_Killfeed_MetaEvent")

-- [[ 1. DAMAGE TRACKER ]]
hook.Add("EntityTakeDamage", "MW2_Killfeed_CaptureDamage", function(target, dmginfo)
    if not (target:IsPlayer() or target:IsNPC()) then return end

    -- Store the damage type to check for fall/explosion icons later
    target.MW2_LastDamageType = dmginfo:GetDamageType()
    
    -- Headshot Detection
    if target:IsPlayer() and target:LastHitGroup() == HITGROUP_HEAD then
        target.MW2_WasHeadshot = true
    else
        target.MW2_WasHeadshot = false
    end
end)

-- [[ HELPER: Determine Icon/Weapon Class ]]
local function DetermineWeaponClass(victim, attacker, inflictor)
    -- Priority 1: Headshots
    if victim.MW2_WasHeadshot then return "MW2_Headshot" end
    
    -- Priority 2: Environmental & Special Damage
    if victim.MW2_LastDamageType then
        local dmg = victim.MW2_LastDamageType
        if bit.band(dmg, DMG_BLAST) != 0 then return "MW2_Blast" end
        if bit.band(dmg, DMG_FALL) != 0 then return "MW2_Fall" end
        if bit.band(dmg, DMG_CRUSH) != 0 then return "MW2_Crush" end
        if bit.band(dmg, DMG_PHYSGUN) != 0 then return "MW2_Impale" end
    end

    -- Priority 3: Suicides & World Kills
    if attacker == victim or attacker:IsWorld() then
        return "MW2_Suicide"
    end

    -- Priority 4: The actual weapon used
    local weapon = "worldspawn"
    if IsValid(inflictor) then
        if inflictor:IsWeapon() then 
            weapon = inflictor:GetClass() 
        elseif inflictor:IsPlayer() then 
            local activeWep = inflictor:GetActiveWeapon()
            if IsValid(activeWep) then weapon = activeWep:GetClass() end
        else 
            weapon = inflictor:GetClass() 
        end
    elseif IsValid(attacker) and attacker:IsPlayer() then
        local activeWep = attacker:GetActiveWeapon()
        if IsValid(activeWep) then weapon = activeWep:GetClass() end
    end

    return weapon
end

-- [[ 2. PLAYER DEATH BROADCAST ]]
hook.Add("PlayerDeath", "MW2_Killfeed_PlayerDeath", function(victim, inflictor, attacker)
    local weaponClass = DetermineWeaponClass(victim, attacker, inflictor)

    net.Start("MW2_Killfeed_Death")
        net.WriteEntity(victim)
        net.WriteEntity(attacker)
        net.WriteString(weaponClass)
    net.Broadcast()

    -- Reset temp data
    victim.MW2_LastDamageType = nil
    victim.MW2_WasHeadshot = false
end)

-- [[ 3. NPC DEATH BROADCAST ]]
hook.Add("OnNPCKilled", "MW2_Killfeed_NPCDeath", function(npc, attacker, inflictor)
    local weaponClass = DetermineWeaponClass(npc, attacker, inflictor)

    net.Start("MW2_Killfeed_Death")
        net.WriteEntity(npc)
        net.WriteEntity(attacker)
        net.WriteString(weaponClass)
    net.Broadcast()
    
    npc.MW2_LastDamageType = nil
    npc.MW2_WasHeadshot = false
end)

-- [[ 4. FACTION & TAG SYNC ]]
hook.Add("PlayerSpawn", "MW2_Killfeed_SyncData", function(ply)
    if ply.MW2_StoredFaction then
        ply:SetNW2String("MW2_Faction", ply.MW2_StoredFaction)
    end
    
    local tag = ply:GetInfo("mw2_clantag") or ""
    ply:SetNW2String("MW2_ClanTag", tag)
end)

-- [[ 5. META EVENTS (Connect/Disconnect) ]]
gameevent.Listen("player_connect")
hook.Add("player_connect", "MW2_Killfeed_PlayerConnect", function(data)
    local name = data.name
    net.Start("MW2_Killfeed_MetaEvent")
        net.WriteString(name)
        net.WriteBool(true)
    net.Broadcast()
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "MW2_Killfeed_PlayerDisconnect", function(data)
    local name = data.name
    net.Start("MW2_Killfeed_MetaEvent")
        net.WriteString(name)
        net.WriteBool(false)
    net.Broadcast()
end)