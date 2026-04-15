-- Configuration
local flashDuration = 3.1 

-- State Variables
local lastHealth = 100
local flashEndTime = 0

-- Materials
local MAT_BLOOD_DEFOCUS = Material("lowhealth/blood_defocus_color.png")
local MAT_BLOOD_OVERLAY = Material("lowhealth/blood_overlay_lowhp.png")

hook.Add("HUDPaint", "LowHealth_BloodHUD_Dynamic", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local hp = ply:Health()
    local curTime = CurTime()
    
    -- 1. Damage Detection
    if hp < lastHealth then
        flashEndTime = curTime + flashDuration
    end
    lastHealth = hp

    -----------------------------------------
    -- 2. DEFOCUS CALCULATION (The one you wanted fixed)
    -----------------------------------------
    -- This creates the "Passive" alpha that scales with health (0 at 100hp, 200 at 10hp)
    local passiveDefocus = math.Clamp((100 - hp) * (200 / 90), 0, 200)
    
    local finalDefocusAlpha = passiveDefocus

    -- If we are in the 1-second damage window, Lerp from 255 down to the passive value
    if curTime < flashEndTime then
        local fraction = (flashEndTime - curTime) / flashDuration
        finalDefocusAlpha = Lerp(fraction, passiveDefocus, 255)
    end

    -----------------------------------------
    -- 3. OVERLAY CALCULATION
    -----------------------------------------
    -- Standard scale: 0 at 100hp, 255 at 10hp
    local finalOverlayAlpha = math.Clamp((100 - hp) * (255 / 90), 0, 255)

    -----------------------------------------
    -- 4. DRAWING
    -----------------------------------------
    -- Draw Defocus
    if finalDefocusAlpha > 0 then
        surface.SetDrawColor(255, 255, 255, finalDefocusAlpha)
        surface.SetMaterial(MAT_BLOOD_DEFOCUS)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    -- Draw Overlay
    if finalOverlayAlpha > 0 then
        surface.SetDrawColor(255, 255, 255, finalOverlayAlpha)
        surface.SetMaterial(MAT_BLOOD_OVERLAY)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end
end)