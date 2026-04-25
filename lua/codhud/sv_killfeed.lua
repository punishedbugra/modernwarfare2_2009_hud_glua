---- [ SERVER KILLFEED ] ----

-- [[ 1. DAMAGE TRACKER ]]
-- Captures the damage type right before death so we know if it was a fall, blast, etc.
hook.Add("EntityTakeDamage", "CoDHUD_Killfeed_CaptureDamage", function(target, dmginfo)
    if target:IsPlayer() or target:IsNPC() then
        target.CoDHUD_LastDamageType = dmginfo:GetDamageType()
        
        -- Check for headshot
        if target:IsPlayer() and target:LastHitGroup() == HITGROUP_HEAD then
            target.CoDHUD_WasHeadshot = true
        else
            target.CoDHUD_WasHeadshot = false
        end
    end
end)

-- [[ 2. FACTION & TAG SYNC ]]
-- We removed the hardcoded "rangers" default here.
-- This hook now only ensures the NW2 string is updated if a stored value exists.
hook.Add("PlayerSpawn", "CoDHUD_Killfeed_SyncData", function(ply)
    -- If the server already knows the faction (from sv_mw2_chat persistence), re-assert it.
    -- Otherwise, we let the client's SyncFactionPersistence() handle the update.
    if ply.CoDHUD_StoredFaction then
        ply:SetNW2String("CoDHUD_Faction", ply.CoDHUD_StoredFaction)
    end
    
    -- Sync Clan Tag (if applicable)
    local tag = ply:GetInfo("codhud_clantag") or ""
    ply:SetNW2String("CoDHUD_ClanTag", tag)
end)