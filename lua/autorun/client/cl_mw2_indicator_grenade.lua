-- cl_mw2_indicator_grenade.lua

MW2_HUD = MW2_HUD or {}

-- ==========================================
-- TINKER BLOCK: ADJUST SETTINGS HERE
-- ==========================================
local THROWBACK_DIST    = 100  -- Distance to trigger throwback
local TEXT_Y_POS       = 0.72 -- Vertical position (0.0 to 1.0)
local ICON_WIDTH       = 56   -- Throwback prompt icon width
local ICON_HEIGHT      = 56   -- Throwback prompt icon height
local PROMPT_ALPHA     = 115  -- Alpha of the grenade icon in the prompt
-- ==========================================

-- Ensure the font exists for this file
surface.CreateFont("MW2_Grenade_Font", {
    font = "Conduit ITC Light", 
    size = 31, 
    weight = 400, 
    antialias = true,
    shadow = true
})

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
local matThrowback = Material("icons/grenadethrowback_white.png", "mips smooth")
local matPointer = Material("icons/grenadepointer_white.png", "mips smooth")
local matPromptIcon = Material("hud_weapon/hud_us_grenade.png", "mips smooth")

hook.Add("HUDPaint", "MW2_Grenade_Final_Fixed", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local scrW, scrH = ScrW(), ScrH()
    local cx, cy = scrW / 2, scrH / 2
    local curTime = CurTime()

    -- 0.6s Flash Logic
    local showIcon = math.fmod(curTime, 0.6) < 0.4
    local nearEnts = ents.FindInSphere(ply:GetPos(), 250) 
    
    local canThrowbackAny = false

    for _, ent in ipairs(nearEnts) do
        if not IsGrenade(ent) then continue end

        local dist = ply:GetPos():Distance(ent:GetPos())
        local isThrowbackRange = dist <= THROWBACK_DIST

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

        -- 6. DRAW THE ICON (Swap to throwback if close)
        if showIcon then
            local currentMat = isThrowbackRange and matThrowback or matIcon
            if currentMat and not currentMat:IsError() then
                surface.SetMaterial(currentMat)
                surface.DrawTexturedRectRotated(px, py, 50, 50, 0)
            end
        end

        if isThrowbackRange then canThrowbackAny = true end
    end

    -- 7. THROWBACK PROMPT
    if canThrowbackAny then
        local alpha = 175
        local drawY = scrH * TEXT_Y_POS
        local font = "MW2_Grenade_Font"
        surface.SetFont(font)
        
        local text1 = "G or Middle Mouse "
        local text2 = "throw back"
        local tw1, th = surface.GetTextSize(text1)
        local tw2, _ = surface.GetTextSize(text2)
        
        -- Calculate total width for centering
        local spacing = 10
        local totalW = tw1 + tw2 + spacing + ICON_WIDTH
        local startX = cx - (totalW / 2)

        -- "G or Middle Mouse" (Gold)
        draw.SimpleText(text1, font, startX, drawY, Color(255, 215, 0, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- "throw back" (White)
        draw.SimpleText(text2, font, startX + tw1, drawY, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Grenade Icon
        if matPromptIcon and not matPromptIcon:IsError() then
            surface.SetMaterial(matPromptIcon)
            surface.SetDrawColor(255, 255, 255, PROMPT_ALPHA)
            surface.DrawTexturedRect(startX + tw1 + tw2 + spacing, drawY - (ICON_HEIGHT / 2), ICON_WIDTH, ICON_HEIGHT)
        end
    end
end)