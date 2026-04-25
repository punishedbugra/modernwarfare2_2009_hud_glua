CreateConVar("mw2_score_limit", "7500", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sets the score limit for the HUD.")
CreateConVar("mw2_matchstart_timer", "10", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sets the match start timer.")
CreateConVar("mw2_friendly_fire", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "If 0, players on the same faction cannot damage each other.")

if SERVER then
    hook.Add("PlayerShouldTakeDamage", "MW2_FactionFriendlyFire", function(victim, attacker)
        if GetConVar("mw2_friendly_fire"):GetBool() then return end
        if not IsValid(attacker) or not attacker:IsPlayer() then return end
        if victim == attacker then return end

        if victim:GetNW2String("MW2_Faction", "rangers") == attacker:GetNW2String("MW2_Faction", "rangers") then
            return false
        end
    end)
end