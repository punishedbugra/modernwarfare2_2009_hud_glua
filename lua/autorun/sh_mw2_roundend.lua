-- [[ sh_mw2_roundend.lua ]]

if SERVER then
    util.AddNetworkString("MW2_RoundEnd")
    CreateConVar("mw2_score_limit", "7500", FCVAR_NOTIFY, "MW2 Score Limit", 100, 7500)
end