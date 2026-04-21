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
local function TriggerChallenge(ply, id, header, level, sub, subval, pts)
    if not IsValid(ply) then return end

    net.Start("MW2_Challenge_Generic")
        net.WriteString(id)
        net.WriteString(header)
        net.WriteInt(level or 0, 5)
        net.WriteString(sub or "")
        net.WriteInt(subval or 0, 32)
        net.WriteInt(pts or 0, 32)
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
        rivals = {},
		weaponKills = {},
		weaponHeadshots = {}
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
        tickHeadshots = 0,
		weaponKills = {},
		weaponHeadshots = {}
    }
end)

local function GetWeaponClass(ply, inflictor)
    if IsValid(inflictor) and inflictor:IsWeapon() then
        return inflictor:GetClass()
    end

    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        return wep:GetClass()
    end

    return "unknown"
end

local function RegisterWeaponKill(ply, wepClass, isHeadshot)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply.MW2_Session.weaponKills = ply.MW2_Session.weaponKills or {}
    ply.MW2_Session.weaponHeadshots = ply.MW2_Session.weaponHeadshots or {}

    ply.MW2_Session.weaponKills[wepClass] =
        (ply.MW2_Session.weaponKills[wepClass] or 0) + 1

    if isHeadshot then
        ply.MW2_Session.weaponHeadshots[wepClass] =
            (ply.MW2_Session.weaponHeadshots[wepClass] or 0) + 1
    end
end

local function GetWeaponPrintName(class, ply)
    -- 1. Try active weapon first (MOST reliable)
    if IsValid(ply) then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == class then
            if wep.PrintName then
                return wep.PrintName
            end
        end
    end

    -- 2. Try SWEP stored (fallback)
    local swep = weapons.GetStored(class)
    if swep and swep.PrintName then
        return swep.PrintName
    end

    -- 3. CW2-style fallback (sometimes stored in SWEP data tables)
    if swep and swep.PrintName then
        return swep.PrintName
    end

    -- 4. Last resort cleanup
    return string.upper(string.gsub(class, "^weapon_", ""))
end

local function ProcessWeaponProgress(ply, wepClass, isHeadshot)
    ply.MW2_Session.weaponKills = ply.MW2_Session.weaponKills or {}
    ply.MW2_Session.weaponHeadshots = ply.MW2_Session.weaponHeadshots or {}

    local kills = ply.MW2_Session.weaponKills
    local heads = ply.MW2_Session.weaponHeadshots

    -- kills[wepClass] = (kills[wepClass] or 0) + 1
    local weaponKills = kills[wepClass]

    if isHeadshot then
        heads[wepClass] = (heads[wepClass] or 0) + 1
    end

    local hs = heads[wepClass] or 0

    local weaponName = GetWeaponPrintName(wepClass)

    local killTiers = {10, 25, 75, 150, 300, 500, 750, 1000}
    local killTierPts = {250, 1000, 2000, 5000, 10000, 10000, 10000, 10000}

	for i, req in ipairs(killTiers) do
		local pts = killTierPts[i] or 0

		if weaponKills >= req then
			TriggerChallenge( ply, wepClass .. "_MARKSMAN_" .. i, "[KILLS] " .. weaponName, i, "GET_N_KILLS", req, pts )
		end
	end

    local hsTiers = {5, 15, 30, 75, 150, 250, 350, 500}
    local hsTierPts = {500, 1000, 2500, 5000, 10000, 10000, 10000, 10000}

	for i, req in ipairs(hsTiers) do
		local pts = hsTierPts[i] or 0

		if hs >= req then
			TriggerChallenge( ply, wepClass .. "_EXPERT_" .. i, "[HS] " .. weaponName, i, "GET_N_HEADSHOTS", req, pts )
		end
	end
end

-- [[ KILL TRACKING LOGIC ]]
hook.Add("PlayerDeath", "MW2_MainTracker", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

	local wepClass = GetWeaponClass(attacker, inflictor)
	
	attacker.MW2_Session.weaponKills = attacker.MW2_Session.weaponKills or {}
	attacker.MW2_Session.weaponHeadshots = attacker.MW2_Session.weaponHeadshots or {}

	RegisterWeaponKill(attacker, wepClass, victim:LastHitGroup() == HITGROUP_HEAD)

    attacker.MW2_Session = attacker.MW2_Session or { kills = 0, headshots = 0, oneShots = 0, rivals = {}, grenadeKills = 0, crouchKills = 0, potatoKills = 0, rpgMultis = 0, fragMultis = 0 }
    attacker.MW2_Life = attacker.MW2_Life or { weaponsUsed = {}, longshots = 0, midAirKills = 0, spawnTime = CurTime(), currentStreak = 0, nearDeathKills = 0, lastKillTick = 0, tickKills = 0, tickHeadshots = 0 }

    -- General Kill Progress
    attacker.MW2_Session.kills = attacker.MW2_Session.kills + 1
    attacker.MW2_Life.currentStreak = attacker.MW2_Life.currentStreak + 1
    
    local totalKills = attacker.MW2_Session.kills
	
    -- if totalKills == 100 then TriggerChallenge( attacker, "marksman1", "MARKSMAN_1", 1, "GET_N_KILLS", 100 )
    -- elseif totalKills == 250 then TriggerChallenge( attacker, "marksman2", "MARKSMAN_1", 2, "GET_N_KILLS", 250 )
    -- elseif totalKills == 500 then TriggerChallenge( attacker, "marksman3", "MARKSMAN_1", 3, "GET_N_KILLS", 500 )
    -- elseif totalKills == 750 then TriggerChallenge( attacker, "marksman4", "MARKSMAN_1", 4, "GET_N_KILLS", 750 )
    -- elseif totalKills == 1000 then TriggerChallenge( attacker, "marksman5", "MARKSMAN_1", 5, "GET_N_KILLS", 1000 )
    -- elseif totalKills == 3000 then TriggerChallenge( attacker, "marksman6", "MARKSMAN_1", 6, "GET_N_KILLS", 3000 )
    -- elseif totalKills == 5000 then TriggerChallenge( attacker, "marksman7", "MARKSMAN_1", 7, "GET_N_KILLS", 5000 )
    -- elseif totalKills == 10000 then TriggerChallenge( attacker, "marksman8", "MARKSMAN_1", 8, "GET_N_KILLS", 10000 )
	-- end

	-- Per-Weapon Challenges
	ProcessWeaponProgress(attacker, wepClass, victim:LastHitGroup() == HITGROUP_HEAD)

    -- Fearless (10 Killstreak)
    if attacker.MW2_Life.currentStreak == 10 then
        TriggerChallenge(attacker, "fearless", "FEARLESS", nil, "KILL_10_ENEMIES_IN_A", nil, 2000)
    end

    -- Near Death (The Brink)
    if attacker:Health() <= 30 then
        attacker.MW2_Life.nearDeathKills = attacker.MW2_Life.nearDeathKills + 1
        if attacker.MW2_Life.nearDeathKills == 3 then
            TriggerChallenge(attacker, "thebrink", "THE_BRINK", nil, "GET_A_3_OR_MORE_KILL", nil, 4500)
        end
    end

    -- 1. HEADSHOTS & ALL PRO
    if victim:LastHitGroup() == HITGROUP_HEAD then
		attacker.MW2_Session.headshots = attacker.MW2_Session.headshots + 1
		attacker.MW2_Session.weaponHeadshots[wepClass] = (attacker.MW2_Session.weaponHeadshots[wepClass] or 0) + 1
		
        net.Start("MW2_Medal_Headshot")
        net.Send(attacker)
        
        local h = attacker.MW2_Session.headshots
        -- if h == 50 then TriggerChallenge(attacker, "expert1", "EXPERT_1", 1, "GET_N_HEADSHOTS", 50)
        -- elseif h == 150 then TriggerChallenge(attacker, "expert2", "EXPERT_1", 2, "GET_N_HEADSHOTS", 150)
        -- elseif h == 300 then TriggerChallenge(attacker, "expert3", "EXPERT_1", 3, "GET_N_HEADSHOTS", 300)
        -- elseif h == 750 then TriggerChallenge(attacker, "expert4", "EXPERT_1", 4, "GET_N_HEADSHOTS", 750)
        -- elseif h == 1500 then TriggerChallenge(attacker, "expert5", "EXPERT_1", 5, "GET_N_HEADSHOTS", 1500)
        -- elseif h == 2500 then TriggerChallenge(attacker, "expert6", "EXPERT_1", 6, "GET_N_HEADSHOTS", 2500)
        -- elseif h == 3500 then TriggerChallenge(attacker, "expert7", "EXPERT_1", 7, "GET_N_HEADSHOTS", 3500)
        -- elseif h == 5000 then TriggerChallenge(attacker, "expert8", "EXPERT_1", 8, "GET_N_HEADSHOTS", 5000)
		-- end
    end

    -- 2. ONE SHOTS (Ghillie)
    if victim:GetMaxHealth() <= 100 and victim:Health() <= 0 then
        attacker.MW2_Session.oneShots = attacker.MW2_Session.oneShots + 1
        net.Start("MW2_Medal_OneShot")
        net.Send(attacker)
        
        local os = attacker.MW2_Session.oneShots
        if os == 50 then TriggerChallenge(attacker, "ghillie1", "GHILLIE", 1, "DESC_GHILLIE", 50, 1000)
        elseif os == 100 then TriggerChallenge(attacker, "ghillie2", "GHILLIE", 2, "DESC_GHILLIE", 100, 2500)
        elseif os == 200 then TriggerChallenge(attacker, "ghillie3", "GHILLIE", 3, "DESC_GHILLIE", 200, 5000) end
    end

    -- 3. LONGSHOTS & NBK
    local dist = attacker:GetPos():Distance(victim:GetPos())
    if dist >= 1200 then
        attacker.MW2_Life.longshots = attacker.MW2_Life.longshots + 1
        net.Start("MW2_Medal_Longshot")
        net.Send(attacker)
        if attacker.MW2_Life.longshots == 3 then
            TriggerChallenge(attacker, "nbk", "NBK", nil, "DESC_NBK", nil, 2000)
        end
    end

    -- 4. CROUCHING & GRENADES
    if attacker:Crouching() then
        attacker.MW2_Session.crouchKills = attacker.MW2_Session.crouchKills + 1
        if attacker.MW2_Session.crouchKills == 5 then TriggerChallenge(attacker, "crouch1", "CROUCH_SHOT", 1, "KILL_N_ENEMIES_WHILE_CROUCHING", 5, 500)
        elseif attacker.MW2_Session.crouchKills == 15 then TriggerChallenge(attacker, "crouch2", "CROUCH_SHOT", 2, "KILL_N_ENEMIES_WHILE_CROUCHING", 15, 1000)
        elseif attacker.MW2_Session.crouchKills == 30 then TriggerChallenge(attacker, "crouch3", "CROUCH_SHOT", 3, "KILL_N_ENEMIES_WHILE_CROUCHING", 30, 2500) end
    end

    if inflictor:GetClass() == "npc_grenade_frag" or inflictor:GetClass() == "weapon_frag" then
        attacker.MW2_Session.grenadeKills = attacker.MW2_Session.grenadeKills + 1
        if attacker.MW2_Session.grenadeKills == 10 then TriggerChallenge(attacker, "grenade1", "GRENADE_KILL", 1, "KILL_N_ENEMIES_WITH_A_GRENADE", 10, 500)
        elseif attacker.MW2_Session.grenadeKills == 25 then TriggerChallenge(attacker, "grenade2", "GRENADE_KILL", 2, "KILL_N_ENEMIES_WITH_A_GRENADE", 25, 2500) end

        -- Hot Potato Check
        if IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_physcannon" then
            attacker.MW2_Session.potatoKills = attacker.MW2_Session.potatoKills + 1
            if attacker.MW2_Session.potatoKills == 5 then TriggerChallenge(attacker, "potato1", "HOT_POTATO", 1, "KILL_N_ENEMIES_WITH_THROWN", 5, 5000)
            elseif attacker.MW2_Session.potatoKills == 10 then TriggerChallenge(attacker, "potato2", "HOT_POTATO", 2, "KILL_N_ENEMIES_WITH_THROWN", 10, 5000) end
        end
    end

    -- 5. AIRBORNE / HARD LANDING
    if not attacker:IsOnGround() then
        attacker.MW2_Life.midAirKills = attacker.MW2_Life.midAirKills + 1
        if attacker.MW2_Life.midAirKills == 2 then TriggerChallenge(attacker, "airborne", "AIRBORNE", nil, "GET_A_2_KILL_STREAK_WHILE", nil, 2000) end
    end
    if not victim:IsOnGround() then
        TriggerChallenge(attacker, "hardlanding", "HARD_LANDING", nil, "KILL_AN_ENEMY_THAT_IS", nil, 3000)
    end

    -- 6. RENAISSANCE MAN
    local wep = attacker:GetActiveWeapon()
    if IsValid(wep) then
        local class = wep:GetClass()
        if not attacker.MW2_Life.weaponsUsed[class] then
            attacker.MW2_Life.weaponsUsed[class] = true
            if table.Count(attacker.MW2_Life.weaponsUsed) == 3 then
                TriggerChallenge(attacker, "renaissance", "RENAISSANCE", nil, "DESC_RENAISSANCE", nil, 1000)
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
            if attacker.MW2_Session.fragMultis == 5 then TriggerChallenge(attacker, "frag1", "MULTIFRAG", 1, "KILL_2_OR_MORE_ENEMIES2", 5, 2000)
            elseif attacker.MW2_Session.fragMultis == 25 then TriggerChallenge(attacker, "frag2", "MULTIFRAG", 2, "KILL_2_OR_MORE_ENEMIES2", 25, 5000)
            elseif attacker.MW2_Session.fragMultis == 50 then TriggerChallenge(attacker, "frag3", "MULTIFRAG", 3, "KILL_2_OR_MORE_ENEMIES2", 50, 10000) end
        elseif string.find(infClass, "rpg") or string.find(infClass, "rocket") or string.find(infClass, "smg1_grenade") then
            attacker.MW2_Session.rpgMultis = attacker.MW2_Session.rpgMultis + 1
            if attacker.MW2_Session.rpgMultis == 5 then TriggerChallenge(attacker, "rpg1", "MULTIRPG", 1, "KILL_2_OR_MORE_ENEMIES", 5, 2000)
            elseif attacker.MW2_Session.rpgMultis == 25 then TriggerChallenge(attacker, "rpg2", "MULTIRPG", 2, "KILL_2_OR_MORE_ENEMIES", 25, 5000)
            elseif attacker.MW2_Session.rpgMultis == 50 then TriggerChallenge(attacker, "rpg3", "MULTIRPG", 3, "KILL_2_OR_MORE_ENEMIES", 50, 10000) end
        elseif inflictor:IsWeapon() then
            TriggerChallenge(attacker, "collateral", "COLLATERAL_DAMAGE", nil, "KILL_2_OR_MORE_ENEMIES4", nil, 2000)
            if attacker.MW2_Life.tickHeadshots == 2 then
                TriggerChallenge(attacker, "allpro", "ALLPRO", nil, "DESC_ALLPRO", nil, 2000)
            end
        end
    end

    -- 8. RIVAL
    local vicID = victim:SteamID() or "BOT"
    attacker.MW2_Session.rivals[vicID] = (attacker.MW2_Session.rivals[vicID] or 0) + 1
    if attacker.MW2_Session.rivals[vicID] == 5 then TriggerChallenge(attacker, "rival", "RIVAL", nil, "KILL_THE_SAME_ENEMY_5", nil, 3000) end
end)

-- [[ BACKSTABBER TRACKING ]]
hook.Add("PlayerShouldTakeDamage", "MW2_BackstabCheck", function(victim, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" then
        local dir = (victim:GetPos() - attacker:GetPos()):GetNormalized()
        if victim:GetForward():Dot(dir) > 0.5 and victim:Health() <= 25 then
            TriggerChallenge(attacker, "backstabber", "BACKSTABBER", nil, "STAB_AN_ENEMY_IN_THE", nil, 3000)
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
                TriggerChallenge(attacker, "thinkfast", "THINK_FAST", nil, "FINISH_AN_ENEMY_OFF_BY", nil, 3000)
            end
        end

        -- Fall Damage Check
        if dmginfo:IsDamageType(DMG_FALL) then
            if dmginfo:GetDamage() >= target:Health() then
                TriggerChallenge(target, "goodbye", "GOODBYE", nil, "FALL_30_FEET_OR_MORE", nil, 500)
            elseif dmginfo:GetDamage() > 1 then
                timer.Simple(0.1, function()
                    if IsValid(target) and target:Alive() then
                        TriggerChallenge(target, "basejump", "BASE_JUMP", nil, "FALL_15_FEET_OR_MORE", nil, 750)
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
            TriggerChallenge(ply, "survivalist", "SURVIVALIST", nil, "SURVIVE_FOR_5_CONSECUTIVE", nil, 4500)
            ply.MW2_Life.spawnTime = CurTime() + 100000 -- Prevent re-trigger in same life
        end
    end
end)

-- [[ FLYSWATTER ]]
hook.Add("OnNPCKilled", "MW2_NPCChallenges", function(npc, attacker, inflictor)
    if IsValid(attacker) and attacker:IsPlayer() then
        local wepClass = GetWeaponClass(attacker, inflictor or attacker:GetActiveWeapon())

        RegisterWeaponKill(attacker, wepClass, false)
		ProcessWeaponProgress(attacker, wepClass, false)

        local class = npc:GetClass()

        if class == "npc_helicopter" or class == "npc_combinedropship" or class == "npc_combinegunship" then
            TriggerChallenge(attacker, "flyswatter", "FLYSWATTER", nil, "SHOOT_DOWN_AN_ENEMY_HELICOPTER", nil, 1000)
        end
    end
end)