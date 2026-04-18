-- lua/autorun/client/cl_mw2_damage_indicator.lua
if CLIENT then
    local matDamage = Material("icons/hit_direction.png", "mips smooth")
    local attackers = {}

-- [[ SUPPRESS DEFAULT GMOD DAMAGE INDICATOR ]]
    hook.Add("HUDShouldDraw", "MW2_SuppressDefaultDamage", function(name)
        if name == "CHudDamageIndicator" then
            return false
        end
    end)
	
    -- SURGICAL FIX: We listen to the SERVER now. 
    -- This guarantees we get the correct NPC/Player entity every time.
    net.Receive("MW2_Damage_Update", function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end

        local ply = LocalPlayer()
        local curTime = CurTime()

        -- GWZ Stability Logic: Point far away in the direction of the threat
        -- This prevents the "jitter" when enemies are close.
        local incomingPos = ent:GetPos() + (ply:GetPos() - ent:GetPos()) * -33000

        -- Update existing indicator or create new one
        local found = false
        for _, v in ipairs(attackers) do
            if v.ent == ent then
                v.time = curTime + 4
                v.alpha = 255
                v.trackPos = incomingPos -- Update tracking spot
                found = true
                break
            end
        end

        if not found then
            table.insert(attackers, {
                ent = ent,
                trackPos = incomingPos,
                alpha = 255,
                time = curTime + 4
            })
        end
    end)

    hook.Add("HUDPaint", "MW2_DrawDamageIndicators_Pro", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then 
            if #attackers > 0 then table.Empty(attackers) end
            return 
        end

        local cx, cy = ScrW() / 2, ScrH() / 2
        local curTime = CurTime()

        for i = #attackers, 1, -1 do
            local v = attackers[i]
            
            -- Fade Logic
            if curTime > v.time - 1 then 
                v.alpha = math.Approach(v.alpha, 0, FrameTime() * 400)
                if v.alpha <= 0 then table.remove(attackers, i) continue end
            end

            -- Live Tracking: If they are still alive, grab their new position
            local targetWorldPos = v.trackPos
            if IsValid(v.ent) then
                -- Re-apply stability offset
                targetWorldPos = v.ent:GetPos() + (ply:GetPos() - v.ent:GetPos()) * -33000
            end

            -- === DIRECTION MATH (Grenade Pointer Logic) ===
            -- 1. Get relative position
            local localPos = ply:WorldToLocal(targetWorldPos)
            
            -- 2. Calculate Angle (Inverting Y for screen space)
            local dirVecX = localPos.x
            local dirVecY = -localPos.y 
            local screenAngleRad = math.atan2(dirVecX, dirVecY)

            -- 3. Position on Orbit
            local orbitRadius = 280
            local px = cx + math.cos(screenAngleRad) * orbitRadius
            local py = cy - math.sin(screenAngleRad) * orbitRadius

            -- 4. Rotate Texture (Angle + 270 degrees)
            local rotation = math.deg(screenAngleRad) + 270

            surface.SetMaterial(matDamage)
            surface.SetDrawColor(255, 255, 255, v.alpha)
            surface.DrawTexturedRectRotated(px, py, 180, 90, rotation)
        end
    end)
end