if SERVER then
    -- Register all Network Strings
    util.AddNetworkString("MW2_Medal_Headshot")
    util.AddNetworkString("MW2_Medal_DoubleKill")
    util.AddNetworkString("MW2_Medal_TripleKill")
    util.AddNetworkString("MW2_Medal_MultiKill")
    util.AddNetworkString("MW2_Medal_Longshot")
    util.AddNetworkString("MW2_Medal_OneShot")
    util.AddNetworkString("MW2_Medal_FirstBlood")
    util.AddNetworkString("MW2_Medal_Comeback")
    util.AddNetworkString("MW2_Medal_Payback")

    local MW2_FirstBloodOccurred = false

    -- Track Headshots
    local function MarkHeadshot(ent, hitgroup, dmginfo)
        if not IsValid(ent) then return end
        if hitgroup == HITGROUP_HEAD then
            ent.WasHeadshotByMW2 = true
        end
    end
    hook.Add("ScaleNPCDamage", "MW2_MarkHeadshotNPC", MarkHeadshot)
    hook.Add("ScalePlayerDamage", "MW2_MarkHeadshotPlayer", MarkHeadshot)

    -- Capture damage data for One Shot Kill logic
    hook.Add("EntityTakeDamage", "MW2_CaptureLastDamage", function(target, dmginfo)
        if not IsValid(target) then return end
        target.LastMW2DmgData = {
            damage = dmginfo:GetDamage(),
            isExplosion = dmginfo:IsExplosionDamage(),
            type = dmginfo:GetDamageType()
        }
    end)

    local function MW2_CheckMedals(victim, attacker)
        if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

        -- 1. FIRST BLOOD (Only triggers on the first kill of the round/map)
        if not MW2_FirstBloodOccurred then
            net.Start("MW2_Medal_FirstBlood")
            net.Send(attacker)
            MW2_FirstBloodOccurred = true
        end

        -- 2. PAYBACK (Revenge on the person who last killed you)
        if attacker.mw2_LastKiller == victim then
            net.Start("MW2_Medal_Payback")
            net.Send(attacker)
            attacker.mw2_LastKiller = nil -- Revenge complete
        end

        -- 3. COMEBACK (Getting a kill after a death streak of 3+)
        attacker.mw2_DeathStreak = attacker.mw2_DeathStreak or 0
        if attacker.mw2_DeathStreak >= 3 then
            net.Start("MW2_Medal_Comeback")
            net.Send(attacker)
        end
        attacker.mw2_DeathStreak = 0 -- Streak broken by getting a kill

        -- 4. HEADSHOT
        if victim.WasHeadshotByMW2 then
            net.Start("MW2_Medal_Headshot")
            net.Send(attacker)
            victim.WasHeadshotByMW2 = false 
        end

        -- 5. LONGSHOT (Distance based)
        local dist = attacker:GetPos():Distance(victim:GetPos())
        if dist > 1200 then
            net.Start("MW2_Medal_Longshot")
            net.Send(attacker)
        end

        -- 6. ONE SHOT KILL
        local dData = victim.LastMW2DmgData
        if dData then
            local maxHP = victim:GetMaxHealth()
            -- Check if one hit dealt >= Max Health and wasn't melee (DMG_CLUB) or explosion
            if dData.damage >= maxHP and not dData.isExplosion and not (bit.band(dData.type, DMG_CLUB) ~= 0) then
                net.Start("MW2_Medal_OneShot")
                net.Send(attacker)
            end
            victim.LastMW2DmgData = nil 
        end

        -- 7. MULTI-KILLS (Time based)
        local ct = CurTime()
        attacker.mw2_KillCount = attacker.mw2_KillCount or 0
        attacker.mw2_lastKill  = attacker.mw2_lastKill or 0

        if (ct - attacker.mw2_lastKill) < 2.0 then
            attacker.mw2_KillCount = attacker.mw2_KillCount + 1
        else
            attacker.mw2_KillCount = 1
        end
        attacker.mw2_lastKill = ct

        if attacker.mw2_KillCount == 2 then
            net.Start("MW2_Medal_DoubleKill")
            net.Send(attacker)
        elseif attacker.mw2_KillCount == 3 then
            net.Start("MW2_Medal_TripleKill")
            net.Send(attacker)
        elseif attacker.mw2_KillCount >= 4 then
            net.Start("MW2_Medal_MultiKill")
            net.Send(attacker)
            -- Reset multi-kill count every 4 kills to allow cycling
            if attacker.mw2_KillCount == 4 then attacker.mw2_KillCount = 0 end 
        end
    end

    -- Hook for Player Deaths
    hook.Add("PlayerDeath", "MW2_Medal_PlayerDeath", function(victim, inflictor, attacker)
        -- Track death streak for the victim
        victim.mw2_DeathStreak = (victim.mw2_DeathStreak or 0) + 1
        
        -- Track who killed the victim for Payback logic
        if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
            victim.mw2_LastKiller = attacker
        end

        MW2_CheckMedals(victim, attacker)
    end)

    -- Hook for NPC Deaths
    hook.Add("OnNPCKilled", "MW2_Medal_NPCDeath", function(npc, attacker, inflictor)
        MW2_CheckMedals(npc, attacker)
    end)
    
    -- Reset First Blood when the map is cleaned up or round resets
    hook.Add("PostCleanupMap", "MW2_ResetFirstBlood", function()
        MW2_FirstBloodOccurred = false
    end)
end