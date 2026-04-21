-- [[ sv_mw2_roundend.lua ]]

local RE_Triggered     = false
local RE_ThinkThrottle = 0

hook.Add("Think", "MW2_RoundEnd_ScoreCheck", function()
    if RE_Triggered then
        local allZero = true
        for _, ply in ipairs(player.GetAll()) do
            if ply:Frags() ~= 0 then allZero = false; break end
        end
        if allZero then RE_Triggered = false end
        return
    end

    local now = CurTime()
    if now < RE_ThinkThrottle then return end
    RE_ThinkThrottle = now + 0.5

    local limitCV = GetConVar("mw2_score_limit")
    if not limitCV then return end
    local scoreLimit = limitCV:GetInt()
    if scoreLimit <= 0 then scoreLimit = 7500 end

    local winnerFaction = nil
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        if math.max(0, ply:Frags()) * 100 >= scoreLimit then
            winnerFaction = ply:GetNW2String("MW2_Faction", "rangers")
            break
        end
    end

    if not winnerFaction then return end

    RE_Triggered = true

    local factionScores = {}
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        local faction = ply:GetNW2String("MW2_Faction", "rangers")
        local score   = math.max(0, ply:Frags()) * 100
        factionScores[faction] = (factionScores[faction] or 0) + score
    end

    local winnerScore  = factionScores[winnerFaction] or 0
    local loserFaction = ""
    local loserScore   = 0
    for faction, score in pairs(factionScores) do
        if faction ~= winnerFaction then
            loserFaction = faction
            loserScore   = score
            break
        end
    end

    net.Start("MW2_RoundEnd")
        net.WriteString(winnerFaction)
        net.WriteString(loserFaction)
        net.WriteInt(winnerScore, 32)
        net.WriteInt(loserScore, 32)
    net.Broadcast()

    -- Calculate the approximate center of the map
    local spawns = ents.FindByClass("info_player_start")
    table.Add(spawns, ents.FindByClass("info_player_terrorist"))
    table.Add(spawns, ents.FindByClass("info_player_counterterrorist"))
    if #spawns == 0 then
        for _, p in ipairs(player.GetAll()) do
            table.insert(spawns, p)
        end
    end

    local mapCenter = Vector(0, 0, 0)
    if #spawns > 0 then
        for _, spawn in ipairs(spawns) do
            mapCenter = mapCenter + spawn:GetPos()
        end
        mapCenter = mapCenter / #spawns
    end

    -- Delay the kill and camera placement by 6 seconds
    timer.Simple(6, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                if ply:Alive() then
                    ply:StripWeapons()
                    ply:KillSilent()
                end
                
                ply:Spectate(OBS_MODE_ROAMING)
                
                if #spawns > 0 then
                    local randEnt = spawns[math.random(1, #spawns)]
                    if IsValid(randEnt) then
                        -- Target 800 units above the spawn point
                        local targetPos = randEnt:GetPos() + Vector(0, 0, 800)
                        
                        -- Trace upwards to prevent putting the camera out of bounds/in the skybox
                        local tr = util.TraceLine({
                            start = randEnt:GetPos(),
                            endpos = targetPos,
                            mask = MASK_SOLID_BRUSHONLY
                        })
                        
                        -- Place slightly below the ceiling hit
                        local finalPos = tr.HitPos - Vector(0, 0, 64)
                        ply:SetPos(finalPos)
                        
                        -- Angle the camera down towards the calculated map center
                        local dir = (mapCenter - finalPos):GetNormalized()
                        ply:SetEyeAngles(dir:Angle())
                    end
                end
            end
        end
    end)

    -- Respawn all players 10 seconds after the client screen triggers
    timer.Simple(15, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply:SetFrags(0)
                ply:UnSpectate()
                ply:Spawn()
            end
        end
        RE_Triggered = false
    end)
end)

hook.Add("PlayerDeathThink", "MW2_RE_PreventRespawn", function(ply)
    if RE_Triggered then return false end
end)