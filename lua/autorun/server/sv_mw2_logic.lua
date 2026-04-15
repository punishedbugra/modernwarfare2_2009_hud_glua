-- [[ sv_mw2_logic.lua ]]

-- Register all Medal and Challenge Network Strings
util.AddNetworkString("MW2_Medal_Headshot")
util.AddNetworkString("MW2_Medal_DoubleKill")
util.AddNetworkString("MW2_Medal_TripleKill")
util.AddNetworkString("MW2_Medal_MultiKill")
util.AddNetworkString("MW2_Medal_Longshot")
util.AddNetworkString("MW2_Medal_OneShot")
util.AddNetworkString("MW2_Medal_FirstBlood")
util.AddNetworkString("MW2_Medal_Comeback")
util.AddNetworkString("MW2_Medal_Payback")
util.AddNetworkString("MW2_Challenge_Generic")
util.AddNetworkString("MW2_Challenge_Flyswatter")

-- [[ HELPER: TRIGGER CHALLENGE ]]
local function TriggerChallenge(ply, id, header, sub)
    if not IsValid(ply) then return end
    net.Start("MW2_Challenge_Generic")
        net.WriteString(id)
        net.WriteString(header)
        net.WriteString(sub)
    net.Send(ply)
end

-- [[ INITIALIZE SESSION DATA ]]
hook.Add("PlayerSpawn", "MW2_InitStats", function(ply)
    ply.MW2_Session = ply.MW2_Session or {
        kills = 0,
        headshots = 0,
        oneShots = 0,
        grenadeKills = 0,
        crouchKills = 0,
        potatoKills = 0,
        rpgMultis = 0,
        fragMultis = 0,
        rivals = {}
    }

    ply.MW2_Life = {
        weaponsUsed = {},
        longshots = 0,
        midAirKills = 0,
        spawnTime = CurTime(),
        currentStreak = 0,
        nearDeathKills = 0,
        lastKillTick = 0,
        tickKills = 0,
        tickHeadshots = 0
    }
end)

-- [[ KILL TRACKING LOGIC ]]
hook.Add("PlayerDeath", "MW2_MainTracker", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

    attacker.MW2_Session = attacker.MW2_Session or { kills = 0, headshots = 0, oneShots = 0, rivals = {}, grenadeKills = 0, crouchKills = 0, potatoKills = 0, rpgMultis = 0, fragMultis = 0 }
    attacker.MW2_Life = attacker.MW2_Life or { weaponsUsed = {}, longshots = 0, midAirKills = 0, spawnTime = CurTime(), currentStreak = 0, nearDeathKills = 0, lastKillTick = 0, tickKills = 0, tickHeadshots = 0 }

    -- General Kill Progress
    attacker.MW2_Session.kills = attacker.MW2_Session.kills + 1
    attacker.MW2_Life.currentStreak = attacker.MW2_Life.currentStreak + 1
    
    local totalKills = attacker.MW2_Session.kills
    if totalKills == 100 then TriggerChallenge(attacker, "marksman1", "Marksman I", "Get 100 kills")
    elseif totalKills == 250 then TriggerChallenge(attacker, "marksman2", "Marksman II", "Get 250 kills")
    elseif totalKills == 500 then TriggerChallenge(attacker, "marksman3", "Marksman III", "Get 500 kills")
    elseif totalKills == 750 then TriggerChallenge(attacker, "marksman4", "Marksman IV", "Get 750 kills")
    elseif totalKills == 1000 then TriggerChallenge(attacker, "marksman5", "Marksman V", "Get 1000 kills")
    elseif totalKills == 3000 then TriggerChallenge(attacker, "marksman6", "Marksman VI", "Get 3000 kills")
    elseif totalKills == 5000 then TriggerChallenge(attacker, "marksman7", "Marksman VII", "Get 5000 kills")
    elseif totalKills == 10000 then TriggerChallenge(attacker, "marksman8", "Marksman VIII", "Get 10000 kills") end

    -- Fearless (10 Killstreak)
    if attacker.MW2_Life.currentStreak == 10 then
        TriggerChallenge(attacker, "fearless", "Fearless", "Kill 10 enemies in a single match without dying")
    end

    -- Near Death (The Brink)
    if attacker:Health() <= 30 then
        attacker.MW2_Life.nearDeathKills = attacker.MW2_Life.nearDeathKills + 1
        if attacker.MW2_Life.nearDeathKills == 3 then
            TriggerChallenge(attacker, "thebrink", "The Brink", "Get 3 kills while near death")
        end
    end

    -- 1. HEADSHOTS & ALL PRO
    if victim:LastHitGroup() == HITGROUP_HEAD then
        attacker.MW2_Session.headshots = attacker.MW2_Session.headshots + 1
        net.Start("MW2_Medal_Headshot")
        net.Send(attacker)
        
        local h = attacker.MW2_Session.headshots
        if h == 50 then TriggerChallenge(attacker, "expert1", "Expert I", "Get 50 headshot kills")
        elseif h == 150 then TriggerChallenge(attacker, "expert2", "Expert II", "Get 150 headshot kills")
        elseif h == 300 then TriggerChallenge(attacker, "expert3", "Expert III", "Get 300 headshot kills")
        elseif h == 750 then TriggerChallenge(attacker, "expert4", "Expert IV", "Get 750 headshot kills")
        elseif h == 1500 then TriggerChallenge(attacker, "expert5", "Expert V", "Get 1500 headshot kills")
        elseif h == 2500 then TriggerChallenge(attacker, "expert6", "Expert VI", "Get 2500 headshot kills")
        elseif h == 3500 then TriggerChallenge(attacker, "expert7", "Expert VII", "Get 3500 headshot kills")
        elseif h == 5000 then TriggerChallenge(attacker, "expert8", "Expert VIII", "Get 5000 headshot kills") end
    end

    -- 2. ONE SHOTS (Ghillie)
    if victim:GetMaxHealth() <= 100 and victim:Health() <= 0 then
        attacker.MW2_Session.oneShots = attacker.MW2_Session.oneShots + 1
        net.Start("MW2_Medal_OneShot")
        net.Send(attacker)
        
        local os = attacker.MW2_Session.oneShots
        if os == 50 then TriggerChallenge(attacker, "ghillie1", "Ghillie in the Mist I", "Get 50 one-shot kills")
        elseif os == 100 then TriggerChallenge(attacker, "ghillie2", "Ghillie in the Mist II", "Get 100 one-shot kills")
        elseif os == 200 then TriggerChallenge(attacker, "ghillie3", "Ghillie in the Mist III", "Get 200 one-shot kills") end
    end

    -- 3. LONGSHOTS & NBK
    local dist = attacker:GetPos():Distance(victim:GetPos())
    if dist >= 1200 then
        attacker.MW2_Life.longshots = attacker.MW2_Life.longshots + 1
        net.Start("MW2_Medal_Longshot")
        net.Send(attacker)
        if attacker.MW2_Life.longshots == 3 then
            TriggerChallenge(attacker, "nbk", "NBK", "Get 3 longshot kills in one life")
        end
    end

    -- 4. CROUCHING & GRENADES
    if attacker:Crouching() then
        attacker.MW2_Session.crouchKills = attacker.MW2_Session.crouchKills + 1
        if attacker.MW2_Session.crouchKills == 50 then TriggerChallenge(attacker, "crouch1", "Crouch Shot I", "Kill 50 enemies while crouching")
        elseif attacker.MW2_Session.crouchKills == 150 then TriggerChallenge(attacker, "crouch2", "Crouch Shot II", "Kill 150 enemies while crouching")
        elseif attacker.MW2_Session.crouchKills == 300 then TriggerChallenge(attacker, "crouch3", "Crouch Shot III", "Kill 300 enemies while crouching") end
    end

    if inflictor:GetClass() == "npc_grenade_frag" or inflictor:GetClass() == "weapon_frag" then
        attacker.MW2_Session.grenadeKills = attacker.MW2_Session.grenadeKills + 1
        if attacker.MW2_Session.grenadeKills == 100 then TriggerChallenge(attacker, "grenade1", "Grenade Kill I", "Kill 100 enemies with grenades")
        elseif attacker.MW2_Session.grenadeKills == 250 then TriggerChallenge(attacker, "grenade2", "Grenade Kill II", "Kill 250 enemies with grenades")
        elseif attacker.MW2_Session.grenadeKills == 500 then TriggerChallenge(attacker, "grenade3", "Grenade Kill III", "Kill 500 enemies with grenades") end

        -- Hot Potato Check
        if IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_physcannon" then
            attacker.MW2_Session.potatoKills = attacker.MW2_Session.potatoKills + 1
            if attacker.MW2_Session.potatoKills == 5 then TriggerChallenge(attacker, "potato1", "Hot Potato I", "Kill 5 enemies with thrown back grenades")
            elseif attacker.MW2_Session.potatoKills == 10 then TriggerChallenge(attacker, "potato2", "Hot Potato II", "Kill 10 enemies with thrown back grenades") end
        end
    end

    -- 5. AIRBORNE / HARD LANDING
    if not attacker:IsOnGround() then
        attacker.MW2_Life.midAirKills = attacker.MW2_Life.midAirKills + 1
        if attacker.MW2_Life.midAirKills == 2 then TriggerChallenge(attacker, "airborne", "Airborne", "2 kill streak while in mid-air") end
    end
    if not victim:IsOnGround() then
        TriggerChallenge(attacker, "hardlanding", "Hard Landing", "Kill an enemy that is in mid-air")
    end

    -- 6. RENAISSANCE MAN
    local wep = attacker:GetActiveWeapon()
    if IsValid(wep) then
        local class = wep:GetClass()
        if not attacker.MW2_Life.weaponsUsed[class] then
            attacker.MW2_Life.weaponsUsed[class] = true
            if table.Count(attacker.MW2_Life.weaponsUsed) == 3 then
                TriggerChallenge(attacker, "renaissance", "Renaissance Man", "Kill 3 enemies with 3 different weapons")
            end
        end
    end

    -- 7. TICK-BASED MULTI-KILLS (Collateral, All Pro, Multi-RPG, Multi-Frag)
    if attacker.MW2_Life.lastKillTick == engine.TickCount() then
        attacker.MW2_Life.tickKills = attacker.MW2_Life.tickKills + 1
        if victim:LastHitGroup() == HITGROUP_HEAD then
            attacker.MW2_Life.tickHeadshots = attacker.MW2_Life.tickHeadshots + 1
        end
    else
        attacker.MW2_Life.lastKillTick = engine.TickCount()
        attacker.MW2_Life.tickKills = 1
        attacker.MW2_Life.tickHeadshots = (victim:LastHitGroup() == HITGROUP_HEAD) and 1 or 0
    end

    if attacker.MW2_Life.tickKills == 2 then
        local infClass = inflictor:GetClass()
        if infClass == "npc_grenade_frag" or infClass == "weapon_frag" then
            attacker.MW2_Session.fragMultis = attacker.MW2_Session.fragMultis + 1
            if attacker.MW2_Session.fragMultis == 5 then TriggerChallenge(attacker, "frag1", "Multi-Frag I", "Kill 2 or more enemies with one Frag 5 times")
            elseif attacker.MW2_Session.fragMultis == 25 then TriggerChallenge(attacker, "frag2", "Multi-Frag II", "Kill 2 or more enemies with one Frag 25 times")
            elseif attacker.MW2_Session.fragMultis == 50 then TriggerChallenge(attacker, "frag3", "Multi-Frag III", "Kill 2 or more enemies with one Frag 50 times") end
        elseif string.find(infClass, "rpg") or string.find(infClass, "rocket") or string.find(infClass, "smg1_grenade") then
            attacker.MW2_Session.rpgMultis = attacker.MW2_Session.rpgMultis + 1
            if attacker.MW2_Session.rpgMultis == 5 then TriggerChallenge(attacker, "rpg1", "Multi-RPG I", "Kill 2 or more enemies with one RPG 5 times")
            elseif attacker.MW2_Session.rpgMultis == 25 then TriggerChallenge(attacker, "rpg2", "Multi-RPG II", "Kill 2 or more enemies with one RPG 25 times")
            elseif attacker.MW2_Session.rpgMultis == 50 then TriggerChallenge(attacker, "rpg3", "Multi-RPG III", "Kill 2 or more enemies with one RPG 50 times") end
        elseif inflictor:IsWeapon() then
            TriggerChallenge(attacker, "collateral", "Collateral Damage", "Kill 2 or more enemies with one sniper bullet")
            if attacker.MW2_Life.tickHeadshots == 2 then
                TriggerChallenge(attacker, "allpro", "All Pro", "2 headshots with 1 bullet")
            end
        end
    end

    -- 8. RIVAL
    local vicID = victim:SteamID() or "BOT"
    attacker.MW2_Session.rivals[vicID] = (attacker.MW2_Session.rivals[vicID] or 0) + 1
    if attacker.MW2_Session.rivals[vicID] == 5 then TriggerChallenge(attacker, "rival", "Rival", "Kill the same enemy 5 times") end
end)

-- [[ BACKSTABBER TRACKING ]]
hook.Add("PlayerShouldTakeDamage", "MW2_BackstabCheck", function(victim, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" then
        local dir = (victim:GetPos() - attacker:GetPos()):GetNormalized()
        if victim:GetForward():Dot(dir) > 0.5 and victim:Health() <= 25 then
            TriggerChallenge(attacker, "backstabber", "Backstabber", "Stab an enemy in the back")
        end
    end
    return true
end)

-- [[ RESET AIRBORNE ]]
hook.Add("OnPlayerHitGround", "MW2_AirborneReset", function(ply)
    if IsValid(ply) and ply.MW2_Life then ply.MW2_Life.midAirKills = 0 end
end)

-- [[ FALL DAMAGE & THINK FAST ]]
hook.Add("EntityTakeDamage", "MW2_FallDamageTracker", function(target, dmginfo)
    if target:IsPlayer() then
        -- Think Fast Check
        local inflictor = dmginfo:GetInflictor()
        if IsValid(inflictor) and inflictor:GetClass() == "npc_grenade_frag" and dmginfo:GetDamage() >= target:Health() and (dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_CLUB)) then
            local attacker = dmginfo:GetAttacker()
            if IsValid(attacker) and attacker:IsPlayer() and attacker ~= target then
                TriggerChallenge(attacker, "thinkfast", "Think Fast", "Kill an enemy with a grenade impact")
            end
        end

        -- Fall Damage Check
        if dmginfo:IsDamageType(DMG_FALL) then
            if dmginfo:GetDamage() >= target:Health() then
                TriggerChallenge(target, "goodbye", "Goodbye", "Fall 30 feet or more to your death")
            elseif dmginfo:GetDamage() > 15 then
                timer.Simple(0.1, function()
                    if IsValid(target) and target:Alive() then
                        TriggerChallenge(target, "basejump", "Base Jump", "Fall 15 feet or more and survive")
                    end
                end)
            end
        end
    end
end)

-- [[ SURVIVALIST ]]
timer.Create("MW2_SurvivalistCheck", 10, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and ply.MW2_Life and (CurTime() - ply.MW2_Life.spawnTime >= 300) then
            TriggerChallenge(ply, "survivalist", "Survivalist", "Survive for 5 minutes straight")
            ply.MW2_Life.spawnTime = CurTime() + 100000 -- Prevent re-trigger in same life
        end
    end
end)

-- [[ FLYSWATTER ]]
hook.Add("OnNPCKilled", "MW2_NPCChallenges", function(npc, attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        local class = npc:GetClass()
        if class == "npc_helicopter" or class == "npc_combinedropship" or class == "npc_combinegunship" then
            TriggerChallenge(attacker, "flyswatter", "Flyswatter", "Shoot down an enemy helicopter")
        end
    end
end)