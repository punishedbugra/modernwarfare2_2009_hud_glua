---- [ IDENTIFY FRIEND-OR-FOE ] ----

if CLIENT then
    -- Master toggle for the entire label logic
    CreateClientConVar("mw2_targetid_label", "1", true, false, "Enable/Disable target identification labels")
    CreateClientConVar("mw2_targetid_death_icon", "1", true, false, "Show death icon when a friendly dies")

    local CFG = {
        Y_OFFSET_NEAR       = 12, 
        Y_OFFSET_FAR        = 24, 
        OFFSET_DIST         = 800,
        GLOBAL_ALPHA        = 175, 
        NEAR_DISTANCE       = 500, 
        MIN_SCALE           = 0.6, 
        MAX_SCALE           = 1.0, 
        FOCUS_TIME          = 0.4, 
        
        -- Death Icon Settings
        DEATH_ICON_DURATION = 3.7, 
        DEATH_ICON_ALPHA    = 185,
        DEATH_ICON_SIZE     = 76,
        DEATH_ICON_Y_ADJUST = 80, -- [TINKERING OPTION] Adjust height of the death icon
    }

    local ENEMY_COLOR    = Color(210, 30, 50)  
    local FRIENDLY_COLOR = Color(60, 200, 60)
    local CENTER_RADIUS  = 60 
    local MAT_DEAD_ICON  = Material("icons/headicon_dead.png", "smooth")
    
    local targetAlphas = {} 
    local focusTimers  = {} 
    local deathMarkers = {} 
    local playerAliveState = {}

    hook.Add("HUDDrawTargetID", "MW2_SuppressDefaultHealth", function() return false end)
    local hide = { ["CHudTargetID"] = true, ["CHudSecondaryWeaponAmmo"] = true }
    hook.Add("HUDShouldDraw", "MW2_DisableGmodHUDParts", function(name) if hide[name] then return false end end)

    hook.Add("Think", "MW2_TrackFriendlyDeaths", function()
        local lp = LocalPlayer()
        if not IsValid(lp) then return end
        local myFaction = lp:GetNW2String("CoDHUD_Faction", "rangers")

        for _, ply in ipairs(player.GetAll()) do
            if ply == lp then continue end
            
            local isAlive = ply:Alive()
            
            if playerAliveState[ply] ~= nil then
                if playerAliveState[ply] and not isAlive then
                    local entFaction = ply:GetNW2String("CoDHUD_Faction", "none")
                    if entFaction != "none" and entFaction == myFaction then
                        -- Uses the config Y adjustment here
                        table.insert(deathMarkers, {
                            pos = ply:GetPos() + Vector(0, 0, CFG.DEATH_ICON_Y_ADJUST),
                            time = CurTime()
                        })
                    end
                end
            end
            
            playerAliveState[ply] = isAlive
        end
    end)

    hook.Add("HUDPaint", "MW2_Target_Detection", function()
		if not GetConVar("cl_drawhud"):GetBool() then return end
		
        local lp = LocalPlayer()
        if not IsValid(lp) or not lp:Alive() then return end

        local myFaction = lp:GetNW2String("CoDHUD_Faction", "rangers")
        local shootPos = lp:GetShootPos()
        local scrW, scrH = ScrW(), ScrH()
        local screenCenter = Vector(scrW / 2, scrH / 2, 0)

        -- Handle Death Icons
        if GetConVar("mw2_targetid_death_icon"):GetBool() and not GetConVar("codhud_quickdisable_hud"):GetBool() then
            for i = #deathMarkers, 1, -1 do
                local m = deathMarkers[i]
                local elapsed = CurTime() - m.time
                
                if elapsed > CFG.DEATH_ICON_DURATION then 
                    table.remove(deathMarkers, i) 
                    continue 
                end

                local screenData = m.pos:ToScreen()
                if screenData.visible then
                    local currentAlpha = CFG.DEATH_ICON_ALPHA
                    
                    if elapsed > (CFG.DEATH_ICON_DURATION - 1.0) then
                        currentAlpha = Lerp((elapsed - (CFG.DEATH_ICON_DURATION - 1.0)) / 1.0, CFG.DEATH_ICON_ALPHA, 0)
                    end

                    local dist = lp:GetPos():Distance(m.pos)
                    local scale = math.Clamp(1 - (dist / 2500), 0.5, 1)
                    local scaledSize = CFG.DEATH_ICON_SIZE * scale

                    surface.SetMaterial(MAT_DEAD_ICON)
                    surface.SetDrawColor(255, 255, 255, currentAlpha)
                    surface.DrawTexturedRect(screenData.x - (scaledSize/2), screenData.y - (scaledSize/2), scaledSize, scaledSize)
                end
            end
        end

        -- Handle Target Labels (Only if enabled)
        if (not GetConVar("mw2_targetid_label"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) or ent == lp then continue end
            if not (ent:IsPlayer() or ent:IsNPC()) or ent:Health() <= 0 then continue end

            local entID = ent:EntIndex()
            targetAlphas[entID] = targetAlphas[entID] or 0
            focusTimers[entID]  = focusTimers[entID] or 0

            local distToPlayer = lp:GetPos():Distance(ent:GetPos())
            local fraction = math.Clamp(distToPlayer / CFG.OFFSET_DIST, 0, 1)
            local dynamicY = Lerp(fraction, CFG.Y_OFFSET_NEAR, CFG.Y_OFFSET_FAR)

            local targetPos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z + 2)
            local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
            if headBone then
                local pos, _ = ent:GetBonePosition(headBone)
                targetPos = pos + Vector(0, 0, dynamicY) 
            end

            local screenData = targetPos:ToScreen()
            local distToCenter = Vector(screenData.x, screenData.y, 0):Distance(screenCenter)

            local tr = util.TraceLine({
                start = shootPos,
                endpos = ent:WorldSpaceCenter(),
                filter = lp, 
                mask = MASK_SHOT
            })

            local hasLOS = (tr.Entity == ent) 
            
            -- Labels are visible if you have Line of Sight
            -- (Removed specific friendly-only logic to make it universal per your request)
            if screenData.visible and hasLOS then
                focusTimers[entID] = math.Approach(focusTimers[entID], CFG.FOCUS_TIME, FrameTime())
            else
                focusTimers[entID] = math.Approach(focusTimers[entID], 0, FrameTime() * 2)
            end

            local canSee = focusTimers[entID] >= CFG.FOCUS_TIME
            
            if canSee then
                targetAlphas[entID] = math.Approach(targetAlphas[entID], CFG.GLOBAL_ALPHA, FrameTime() * 700)
            else
                targetAlphas[entID] = math.Approach(targetAlphas[entID], 0, FrameTime() * 500)
            end

            if targetAlphas[entID] > 0 then
                local alpha = targetAlphas[entID]
                local targetFaction = ent:GetNW2String("CoDHUD_Faction", "none")
                local isFriendly = (targetFaction != "none" and targetFaction == myFaction)
                local factionColor = isFriendly and FRIENDLY_COLOR or ENEMY_COLOR
                
                local displayName = ""
                if ent:IsPlayer() then
                    displayName = ent:Nick()
                else
                    displayName = language.GetPhrase(ent:GetClass())
                    if displayName == ent:GetClass() then
                        displayName = displayName:gsub("npc_", ""):gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
                            return first:upper() .. rest:lower()
                        end)
                    end
                end

                local distScale = 1 - math.Clamp((distToPlayer - CFG.NEAR_DISTANCE) / (CFG.OFFSET_DIST - CFG.NEAR_DISTANCE), 0, 1)
                local finalScale = Lerp(distScale, CFG.MIN_SCALE, CFG.MAX_SCALE)

                surface.SetFont("MW2_TargetName_Primary")
                local tw, th = surface.GetTextSize(displayName)
                tw, th = tw * finalScale, th * finalScale

                local drawX, drawY = screenData.x - (tw / 2), screenData.y - (th / 2)

                local matrix = Matrix()
                matrix:Translate(Vector(drawX, drawY, 0))
                matrix:Scale(Vector(finalScale, finalScale, 1))

                cam.PushModelMatrix(matrix)
                    draw.SimpleText(displayName, "MW2_TargetName_Primary", 0, 0, Color(factionColor.r, factionColor.g, factionColor.b, alpha), 0, 0)
                cam.PopModelMatrix()
            end
        end
    end)
end