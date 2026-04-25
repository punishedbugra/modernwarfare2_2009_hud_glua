---- [ DAMAGE, STAT AND HITMARKER TRACKER ] ----

util.AddNetworkString("CoDHUD_Damage_Update")

util.AddNetworkString("CoDHUD_Hitmarker")

-- We use PostEntityTakeDamage to ensure we only track real, confirmed damage
hook.Add("PostEntityTakeDamage", "CoDHUD_Server_Track_Attacker", function(target, dmginfo, took)
    if not IsValid(target) or not target:IsPlayer() or not took then return end
    if dmginfo:GetDamage() <= 0 then return end
    
    -- Filter out fall damage
    if dmginfo:IsFallDamage() then return end

    local attacker = dmginfo:GetAttacker()
    local inflictor = dmginfo:GetInflictor()

    -- LOGIC: Prioritize the Inflictor (Rocket/Grenade) if it exists and isn't a generic weapon.
    -- If it's a standard gun, track the Attacker (NPC/Player).
    local entToSend = attacker

    if IsValid(inflictor) and inflictor ~= attacker and inflictor ~= target then
        -- If it's a grenade or rocket, track THAT object, not the guy who threw it
        if not inflictor:IsWeapon() then
            entToSend = inflictor
        end
    end

    -- If the attacker is the world or invalid, don't send anything
    if not IsValid(entToSend) or entToSend == target then return end

    net.Start("CoDHUD_Damage_Update")
        net.WriteEntity(entToSend)
    net.Send(target)
end)