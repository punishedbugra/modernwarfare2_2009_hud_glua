---- [ SERVER HITMARKER & XP ] ----

-- Network Strings
util.AddNetworkString("CoDHUD_HitNotification")

-- ==========================================
-- CONFIGURATION: REWARDS
-- ==========================================
local XP_PER_KILL = 100
local XP_PER_HIT  = 10  -- Optional: small XP for just hitting
-- ==========================================

hook.Add("PostEntityTakeDamage", "MW2_Server_Hitmarker_Logic", function(target, dmginfo, took)
    local attacker = dmginfo:GetAttacker()
    
    -- 1. Validation: Must be a valid hit, attacker must be a player, no self-damage
    if took and IsValid(attacker) and attacker:IsPlayer() and attacker ~= target then
        
        -- 2. Filter: Only living entities (NPCs, Players, Nextbots)
        if target:IsNPC() or target:IsPlayer() or target:IsNextBot() then
            
            -- Check if this hit was the killing blow
            local isKill = (target:Health() <= 0)
            
            -- 3. PROGRESSION INTEGRATION (The "Server Sum")
            -- We give XP on the server so the client cannot fake it.
            if isKill then
                -- Global function from sv_mw2_progression.lua
                if _G.CoDHUD_GiveXP then
                    _G.CoDHUD_GiveXP(attacker, XP_PER_KILL)
                end
            elseif XP_PER_HIT > 0 then
                -- Optional: Give small XP for chips/hits
                if _G.CoDHUD_GiveXP then
                    _G.CoDHUD_GiveXP(attacker, XP_PER_HIT)
                end
            end

            -- 4. NOTIFY CLIENT
            -- Tells the client to play the hitmarker sound, draw the X, 
            -- and update the visual score (+100)
            net.Start("CoDHUD_HitNotification")
                net.WriteBool(isKill)
                net.WriteInt(isKill and XP_PER_KILL or XP_PER_HIT, 32)
            net.Send(attacker)
        end
    end
end)