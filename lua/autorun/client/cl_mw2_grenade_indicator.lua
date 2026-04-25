-- cl_mw2_indicator_grenade.lua

MW2_HUD = MW2_HUD or {}

CreateClientConVar("cl_mw2_grenade_indicator", "1", true, false, "Enable MW2 grenade indicator")

MW2_HUD.GrenadeList = {
    ["npc_grenade_frag"] = true,
    ["cw_grenade_frag"] = true,
    ["m9k_released_frag"] = true,
}

function IsGrenade(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    if ent.ArcCWProjectile or ent.ARC9Projectile then return true end
    if MW2_HUD.GrenadeList[class] then return true end
    if bit.band(ent:GetFlags(), FL_GRENADE) > 0 then return true end
    return false
end

local matIcon = Material("icons/grenadeicon_white.png", "mips smooth")
local matPointer = Material("icons/grenadepointer_white.png", "mips smooth")

hook.Add("HUDPaint", "MW2_Grenade_Indicator", function()
    if not GetConVar("cl_mw2_grenade_indicator"):GetBool() then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local scrW, scrH = ScrW(), ScrH()
    local cx, cy = scrW / 2, scrH / 2
    local curTime = CurTime()

    -- 0.6s Flash Logic
    local showIcon = math.fmod(curTime, 0.6) < 0.4
    local nearEnts = ents.FindInSphere(ply:GetPos(), 250) 
    
    for _, ent in ipairs(nearEnts) do
        if not IsGrenade(ent) then continue end

        -- 1. LOCALIZED COORDINATES
        local localPos = ply:WorldToLocal(ent:GetPos())
        local dirVecX = localPos.x
        local dirVecY = -localPos.y 
        
        -- 2. CALC ANGLE
        local screenAngleRad = math.atan2(dirVecX, dirVecY)
        local screenAngleDeg = math.deg(screenAngleRad)

        -- 3. POSITIONING
        local ringRadius = 150
        local px = cx + math.cos(screenAngleRad) * ringRadius
        local py = cy - math.sin(screenAngleRad) * ringRadius

        -- 4. POINTER POSITION
        local pointerRadius = ringRadius + 40
        local ptrX = cx + math.cos(screenAngleRad) * pointerRadius
        local ptrY = cy - math.sin(screenAngleRad) * pointerRadius

        surface.SetDrawColor(255, 255, 255, 255)

        -- 5. DRAW THE POINTER
        if matPointer and not matPointer:IsError() then
            surface.SetMaterial(matPointer)
            surface.DrawTexturedRectRotated(ptrX, ptrY, 70, 35, screenAngleDeg + 270)
        end

        -- 6. DRAW THE ICON
        if showIcon then
            if matIcon and not matIcon:IsError() then
                surface.SetMaterial(matIcon)
                surface.DrawTexturedRectRotated(px, py, 50, 50, 0)
            end
        end
    end
end)