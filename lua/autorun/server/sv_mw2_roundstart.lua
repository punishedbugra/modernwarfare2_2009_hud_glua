-- sv_mw2_roundstart.lua

util.AddNetworkString("MW2_StartRound")
util.AddNetworkString("MW2_RoundStart")
util.AddNetworkString("MW2_SetGamemode")

MW2_Gamemode = CreateConVar("mw2_selected_gamemode", "war", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Which gamemode to start the round on.")

net.Receive("MW2_SetGamemode", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local gm = net.ReadString()

    local valid = {
        war=true, dm=true, dom=true, sd=true, sab=true,
        ctf=true, hq=true, oneflag=true, arena=true, dd=true, gtnw=true
    }

    if not valid[gm] then return end

    RunConsoleCommand("mw2_selected_gamemode", gm)
end)

net.Receive("MW2_StartRound", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:PrintMessage(HUD_PRINTTALK, "[MW2] You must be an admin to start the round.")
        return
    end

    local gamemode = GetConVar("mw2_selected_gamemode"):GetString()

    for _, p in ipairs(player.GetAll()) do
        p:SetFrags(0)
        p:SetDeaths(0)
        p:Spawn()
    end

    net.Start("MW2_RoundStart")
        net.WriteString(gamemode)
    net.Broadcast()
end)