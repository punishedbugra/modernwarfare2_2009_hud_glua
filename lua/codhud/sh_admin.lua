---- [ SHARED CONVARS & FRIENDLY FIRE ] ----

CreateConVar("codhud_score_limit", "75", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sets the score limit for the HUD, measured in kills.")
CreateConVar("codhud_matchstart_timer", "10", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sets the match start timer.")
CreateConVar("codhud_friendly_fire", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "If 0, players on the same faction cannot damage each other.")

if SERVER then
    hook.Add("PlayerShouldTakeDamage", "CoDHUD_FactionFriendlyFire", function(victim, attacker)
        if GetConVar("codhud_friendly_fire"):GetBool() then return end
        if not IsValid(attacker) or not attacker:IsPlayer() then return end
        if victim == attacker then return end

        if victim:GetNW2String("CoDHUD_Faction", "rangers") == attacker:GetNW2String("CoDHUD_Faction", "rangers") then
            return false
        end
    end)
end

CreateConVar("codhud_game", "mw2", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Which CoD game factions and UI should utilize.")