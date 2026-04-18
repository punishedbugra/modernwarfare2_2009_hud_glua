-- sv_mw2_roundstart.lua

util.AddNetworkString("MW2_StartRound")
util.AddNetworkString("MW2_RoundStart")

net.Receive("MW2_StartRound", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:PrintMessage(HUD_PRINTTALK, "[MW2] You must be an admin to start the round.")
        return
    end

    local gamemode = net.ReadString()

    for _, p in ipairs(player.GetAll()) do
        p:SetFrags(0)
        p:SetDeaths(0)
        p:Spawn()
    end

    net.Start("MW2_RoundStart")
        net.WriteString(gamemode)
    net.Broadcast()
end)