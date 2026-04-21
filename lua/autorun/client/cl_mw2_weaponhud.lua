-- [[ cl_mw2_weaponhud.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x)  return math.Round(x * GetUIScale()) end
local function SX(x) return math.Round(x * GetUIScale()) end
local function SY(y) return math.Round(y * GetUIScale()) end

-- [[ COMPASS CFG ]]
local MASK = {
    FOV      = 152,
    FADE_DEG = 10,
}

-- [[ WEAPON HUD CFG ]]
local CFG = {
    -- Base Bar
    BAR_W       = 776,
    BAR_H       = 122,
    BAR_X_OFF   = 2,
    BAR_Y_OFF   = 48,

    -- Grenades
    GRENADE_X_OFF     = -230,
    GRENADE_Y_OFF     = -24,
    GRENADE_ICON_W    = 40,
    GRENADE_ICON_H    = 40,
    GRENADE_STACK_GAP = 8,
    GRENADE_MAX       = 4,
    GRENADE_SHADES    = { 255, 200, 175, 120 },

    -- Reserve Ammo (1-2 digit: 0-99)
    RES_SIZE    = 64,
    RES_X       = -244,
    RES_Y       = 32,

    -- Reserve Ammo (3 digit: 100-999)
    RES3_SIZE   = 48,
    RES3_X      = -244,
    RES3_Y      = 48,

    -- Reserve Ammo (4 digit: 1000+)
    RES4_SIZE   = 38,
    RES4_X      = -243,
    RES4_Y      = 52,

    -- Text kerning
    SQUEEZE            = -6,
    SQUEEZE_ONE        = -14,
    SQUEEZE_ONE_BEFORE = -10,

    -- Weapon Name
    WEP_NAME_SIZE  = 38,
    WEP_NAME_X_OFF = -206,
    WEP_NAME_Y_OFF = 12,
    WEP_NAME_FADE  = 2,
    WEP_NAME_SQ    = -3,
    WEP_NAME_SQ1   = -8,

    -- Status Indicator
    STAT_FONT_SIZE = 28,
    STAT_LOW_PERC  = 0.40,
    STAT_FLASH_SPD = 8,
    STAT_Y_OFF     = 62,

    -- Bullet Icons
    BULLET_ALPHA      = 155,
    BULLET_RELOAD_R   = 180,
    BULLET_RELOAD_G   = 60,
    BULLET_RELOAD_B   = 60,
    BULLET_RELOAD_SPD = 6,

    -- Alt Ammo (Underbarrel / Secondary)
    ALT_ICON_SIZE  = 78,
    ALT_ICON_X     = -140,
    ALT_ICON_Y     = 64,
    ALT_TEXT_X     = -80,
    ALT_TEXT_Y     = 92,
    ALT_FONT_SIZE  = 36,
    ALT_TEXT_SQ    = -3,
    ALT_TEXT_SQ1   = -7,
}

local AMMO = {
    ["default"] = { mat = "hud/ammo_counter_bullet_mp.png",      w = 3,  h = 20, gap = 1, y_off = 62, x_start = -294, dim = 75 },
    ["357"]     = { mat = "hud/ammo_counter_riflebullet_mp.png", w = 4,  h = 14, gap = 1, y_off = 41, x_start = -242, dim = 75 },
    ["rifle"]   = { mat = "hud/ammo_counter_riflebullet_mp.png", w = 4,  h = 14, gap = 1, y_off = 41, x_start = -242, dim = 75 },
    ["rocket"]  = { mat = "hud/ammo_counter_rocket_mp.png",      w = 12, h = 24, gap = 1, y_off = 58, x_start = -290, dim = 75 },
    ["sniper"]  = { mat = "hud/ammo_counter_rocket_mp.png",      w = 4,  h = 14, gap = 1, y_off = 41, x_start = -242, dim = 75 },
    ["shotgun"] = { mat = "hud/ammo_counter_rocket_mp.png",      w = 10, h = 20, gap = 1, y_off = 64, x_start = -300, dim = 75 },
    ["pistol"]  = { mat = "hud/ammo_counter_bullet_mp.png",      w = 4,  h = 14, gap = 1, y_off = 41, x_start = -242, dim = 75 },
    ["belt"]    = { row_size = 25, row_gap = 0, mat = "hud/ammo_counter_beltbullet_mp.png", w = 7, h = 5, gap = 0, y_off = 78, x_start = -298, dim = 75 },
}

local AMMO_MAP = {
    ["ammo_357"]      = "357",
    ["ammo_ar2"]      = "rifle",
    ["ammo_crossbow"] = "sniper",
    ["ammo_pistol"]   = "pistol",
    ["ammo_smg1"]     = "default",
    ["buckshot"]      = "shotgun",
    ["rpg_round"]     = "rocket",
}

local function GetAmmoConfig(wep)
    if not IsValid(wep) then return AMMO["default"] end
    if wep:GetMaxClip1() >= 100 then return AMMO["belt"] end
    local ammoName = string.lower(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "")
    return AMMO[AMMO_MAP[ammoName]] or AMMO["default"]
end

-- [[ ASSET PRE-CACHING ]]
local MAT_BAR  = Material("hud/hud_weaponbar.png", "smooth")
local MAT_ALT  = Material("hud/dpad_40mm_grenade.png", "smooth mips")
local MAT_GRENADE = Material("hud/hud_us_grenade.png", "smooth")
local MAT_AMMO = {}
for key, data in pairs(AMMO) do
    MAT_AMMO[key] = Material(data.mat, "smooth")
end
local MAT_COMPASS_SHADOW  = Material("hud/compass_letters_shadow.png", "smooth")
local MAT_COMPASS_LETTERS = Material("hud/compass_letters.png", "smooth")

local function GetAmmoKey(ammoCfg)
    for key, data in pairs(AMMO) do
        if data == ammoCfg then return key end
    end
    return "default"
end

-- [[ FONT INIT ]]
local function MW2_InitFonts()
    surface.CreateFont("MW2_Res",       { font = "BankGothic Md BT", size = S(CFG.RES_SIZE),       weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Res_3D",    { font = "BankGothic Md BT", size = S(CFG.RES3_SIZE),      weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Res_4D",    { font = "BankGothic Md BT", size = S(CFG.RES4_SIZE),      weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Wep_Name",  { font = "BankGothic Md BT", size = S(CFG.WEP_NAME_SIZE),  weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Stat_Font", { font = "BankGothic Md BT", size = S(CFG.STAT_FONT_SIZE), weight = 400, antialias = true, shadow = true, extended = true })
    surface.CreateFont("MW2_Ammo_Alt",  { font = "BankGothic Md BT", size = S(CFG.ALT_FONT_SIZE),  weight = 400, antialias = true, shadow = true, extended = true })
end

MW2_InitFonts()
hook.Add("OnScreenSizeChanged", "MW2_ReinitFonts", MW2_InitFonts)

-- [[ HUD HIDING ]]
local HIDE = { ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true, ["CHudHealth"] = true, ["CHudBattery"] = true }
hook.Add("HUDShouldDraw", "MW2_HideDefaultHUD", function(name)
	if not GetConVar("mw2_enable_weaponinfo"):GetBool() then return end
	
    if HIDE[name] then return false end
end)

-- [[ SQUEEZED TEXT DRAW ]]
local function DrawSqueezedText(text, font, x, y, color, squeeze, squeezeOne, align, squeezeOneBefore)
    local str = tostring(text)
    surface.SetFont(font)
    squeeze          = squeeze          or CFG.SQUEEZE
    squeezeOne       = squeezeOne       or CFG.SQUEEZE_ONE
    squeezeOneBefore = squeezeOneBefore or CFG.SQUEEZE_ONE_BEFORE

    local totalW = 0
    for i = 1, #str do
        local char     = str:sub(i, i)
        local nextChar = str:sub(i + 1, i + 1)
        local w = surface.GetTextSize(char)
        totalW = totalW + w
        if i < #str then
            local gap
            if char == "1" then gap = squeezeOne
            elseif nextChar == "1" then gap = squeezeOneBefore
            else gap = squeeze end
            totalW = totalW + gap
        end
    end

    local runX
    if align == 1 then runX = x - (totalW / 2)
    elseif align == 2 then runX = x
    else runX = x - totalW end

    for i = 1, #str do
        local char     = str:sub(i, i)
        local nextChar = str:sub(i + 1, i + 1)
        -- draw.SimpleText(char, font, runX + SX(2), y + SY(2), Color(0, 0, 0, color.a * 0.8), 0, 0)
        -- draw.SimpleText(char, font, runX,         y,         color,                          0, 0)
		draw.SimpleTextOutlined(char, font, runX, y, color, 0, 0, 1.5, Color(0,0,0, color.a * 0.8))
        local w = surface.GetTextSize(char)
        if i < #str then
            local gap
            if char == "1" then gap = squeezeOne
            elseif nextChar == "1" then gap = squeezeOneBefore
            else gap = squeeze end
            runX = runX + w + gap
        end
    end
end

-- [[ WEAPON SWITCH TRACKING ]]
local lastWep       = nil
local wepSwitchTime = 0

-- [[ MAIN MERGED DRAW HOOK ]]
hook.Add("HUDPaint", "MW2_MergedHUD", function()
	if not GetConVar("mw2_enable_weaponinfo"):GetBool() then return end
	if not GetConVar("cl_drawhud"):GetBool() then return end
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()
	
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local scrW, scrH = ScrW(), ScrH()

    -- ==========================================
    -- 1. COMPASS DRAWING
    -- ==========================================
    local cX   = scrW - S(104)
    local cY   = scrH - S(82)
    local size = S(274)
    local yaw  = ply:EyeAngles().y
    local angle = -(yaw - 90)

    local halfFOV = MASK.FOV / 2.2
    local fadeDeg = MASK.FADE_DEG
    local radius  = size * math.sqrt(2) / 2 + 2
    local steps   = 5

    render.SetStencilEnable(true)
    render.ClearStencil()
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

    -- FIX: Disable Color Writing to prevent the solid white stencil shape from rendering visually
    render.OverrideColorWriteEnable(true, false)
    draw.NoTexture() -- Use NoTexture instead of a material to safely mask the area
    surface.SetDrawColor(255, 255, 255, 255)
    
    for i = 0, steps - 1 do
        local a0 = math.rad(-halfFOV + (i / steps)       * MASK.FOV)
        local a1 = math.rad(-halfFOV + ((i + 1) / steps) * MASK.FOV)
        surface.DrawPoly({
            { x = cX,                         y = cY },
            { x = cX + math.sin(a0) * radius, y = cY - math.cos(a0) * radius },
            { x = cX + math.sin(a1) * radius, y = cY - math.cos(a1) * radius },
        })
    end
    render.OverrideColorWriteEnable(false, false) -- Re-enable color drawing

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

    surface.SetMaterial(MAT_COMPASS_SHADOW)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawTexturedRectRotated(cX, cY, size, size, angle)

    surface.SetMaterial(MAT_COMPASS_LETTERS)
    surface.SetDrawColor(255, 255, 255, 165)
    surface.DrawTexturedRectRotated(cX, cY, size, size, angle)

    render.SetStencilEnable(false)

    -- ==========================================
    -- 2. GRENADE DRAWING
    -- ==========================================
    local grenadeCount = math.Clamp(ply:GetAmmoCount("Grenade") or 0, 0, CFG.GRENADE_MAX)
    if grenadeCount > 0 then
        local barW = SX(CFG.BAR_W)
        local barH = SY(CFG.BAR_H)
        local barX = scrW - SX(CFG.BAR_X_OFF) - barW
        local barY = scrH - SY(CFG.BAR_Y_OFF) - barH

        local iW = S(CFG.GRENADE_ICON_W)
        local iH = S(CFG.GRENADE_ICON_H)
        local stackGap = S(CFG.GRENADE_STACK_GAP)

        local anchorX = (barX + barW) + SX(CFG.GRENADE_X_OFF)
        local anchorY = (barY + barH) + SY(CFG.GRENADE_Y_OFF)

        surface.SetMaterial(MAT_GRENADE)

        for i = (CFG.GRENADE_MAX - 1), 0, -1 do
            if i < grenadeCount then
                local colorIndex = i + 1
                local shade = CFG.GRENADE_SHADES[colorIndex] or CFG.GRENADE_SHADES[#CFG.GRENADE_SHADES]
                surface.SetDrawColor(shade, shade, shade, 255)

                local xPos = anchorX - (i * stackGap)
                local yPos = anchorY

                surface.DrawTexturedRect(xPos, yPos, iW, iH)
            end
        end
    end

    -- ==========================================
    -- 3. WEAPON HUD DRAWING
    -- ==========================================
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    if wep ~= lastWep then
        lastWep       = wep
        wepSwitchTime = CurTime()
    end

    local clip    = wep:Clip1()
    local maxClip = wep:GetMaxClip1()
    local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())

    local barW = SX(CFG.BAR_W)
    local barH = SY(CFG.BAR_H)
    local barX = scrW - SX(CFG.BAR_X_OFF) - barW
    local barY = scrH - SY(CFG.BAR_Y_OFF) - barH

    surface.SetMaterial(MAT_BAR)
    surface.SetDrawColor(255, 255, 255, 125)
    surface.DrawTexturedRect(barX, barY, barW, barH)

    if clip >= 0 then
        local resCol = (reserve == 0 or reserve < maxClip)
            and Color(255, 120, 120, 255)
            or  Color(255, 255, 255, 255)

        if reserve >= 1000 then
            DrawSqueezedText(reserve, "MW2_Res_4D", barX + barW + SX(CFG.RES4_X), barY + SY(CFG.RES4_Y), resCol, nil, nil, 1)
        elseif reserve >= 100 then
            DrawSqueezedText(reserve, "MW2_Res_3D", barX + barW + SX(CFG.RES3_X), barY + SY(CFG.RES3_Y), resCol, nil, nil, 1)
        else
            DrawSqueezedText(reserve, "MW2_Res", barX + barW + SX(CFG.RES_X), barY + SY(CFG.RES_Y), resCol, nil, nil, 1)
        end
    end

    local timeSinceSwitch = CurTime() - wepSwitchTime
    if timeSinceSwitch < CFG.WEP_NAME_FADE then
        local alpha = math.Clamp(1 - (timeSinceSwitch / CFG.WEP_NAME_FADE), 0, 1)
        local name  = (wep:GetPrintName() or wep:GetClass()):upper()
        -- DrawSqueezedText(name, "MW2_Wep_Name", barX + barW + SX(CFG.WEP_NAME_X_OFF), barY + SY(CFG.WEP_NAME_Y_OFF), Color(255, 255, 255, 255 * alpha), CFG.WEP_NAME_SQ, CFG.WEP_NAME_SQ1, 0)

        draw.SimpleTextOutlined(name, "MW2_Wep_Name", barX + barW + SX(CFG.WEP_NAME_X_OFF), barY + SY(CFG.WEP_NAME_Y_OFF), Color(255, 255, 255, 255 * alpha), 2, 0, outlined and 1.5 or 0, Color(0, 0, 0, 255 * alpha))
    end

    if clip >= 0 and maxClip > 0 then
        local perc      = clip / maxClip
        local isLowClip = (perc <= CFG.STAT_LOW_PERC)
        local reloadSine = isLowClip and ((math.sin(CurTime() * CFG.BULLET_RELOAD_SPD) + 1) / 2) or 0

        local ammoCfg = GetAmmoConfig(wep)
        local ammoKey = GetAmmoKey(ammoCfg)
        local iW      = S(ammoCfg.w)
        local iH      = S(ammoCfg.h)
        local iGap    = S(ammoCfg.gap)
        local iYOff   = SY(ammoCfg.y_off)
        local iXStart = SX(ammoCfg.x_start)

        surface.SetMaterial(MAT_AMMO[ammoKey])

        local isBelt  = (ammoCfg.row_size ~= nil)
        local rowSize = isBelt and ammoCfg.row_size or maxClip
        local rowGap  = isBelt and S(ammoCfg.row_gap) or 0

        for i = 0, maxClip - 1 do
            local isSpent = (i >= clip)
            local shade   = isSpent and ammoCfg.dim or 255

            local r, g, b
            if not isSpent and isLowClip then
                r = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_R))
                g = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_G))
                b = math.floor(Lerp(reloadSine, shade, CFG.BULLET_RELOAD_B))
            else
                r = shade
                g = shade
                b = shade
            end

            surface.SetDrawColor(r, g, b, CFG.BULLET_ALPHA)

            local col = i % rowSize
            local row = math.floor(i / rowSize)

            local xPos = barX + barW + iXStart - (col * (iW + iGap))
            local yPos = barY + iYOff - (row * (iH + rowGap))

            surface.DrawTexturedRect(xPos, yPos, iW, iH)
        end
    end

    local altType = wep:GetSecondaryAmmoType()
    if altType ~= -1 then
        local altCount = ply:GetAmmoCount(altType)

        surface.SetMaterial(MAT_ALT)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(barX + barW + SX(CFG.ALT_ICON_X), barY + SY(CFG.ALT_ICON_Y), S(CFG.ALT_ICON_SIZE), S(CFG.ALT_ICON_SIZE))

        local altCol = (altCount > 0) and Color(255, 255, 255, 255) or Color(255, 120, 120, 255)
        DrawSqueezedText(altCount, "MW2_Ammo_Alt", barX + barW + SX(CFG.ALT_TEXT_X), barY + SY(CFG.ALT_TEXT_Y), altCol, CFG.ALT_TEXT_SQ, CFG.ALT_TEXT_SQ1, 1)
    end

    if clip >= 0 and maxClip > 0 then
        local perc      = clip / maxClip
        local statText  = ""
        local statCol   = Color(255, 255, 255)
        local isNoAmmo  = false
        local isLowAmmo = false
        local isReloadText  = false

        if clip == 0 and reserve == 0 then
            statText = "#MW2_WEAPON_NO_AMMO"
            isNoAmmo = true
        elseif clip > 0 and reserve == 0 then
            statText = "#MW2_PLATFORM_LOW_AMMO_NO_RELOAD"
            statCol  = Color(255, 230, 0)
            isLowAmmo = true
        elseif perc <= CFG.STAT_LOW_PERC and reserve > 0 then
            statText = "#MW2_PLATFORM_RELOAD"
            isReloadText = true
        end

        if statText ~= "" then
            local cx   = scrW / 2
            local cy   = (scrH / 2) + SY(CFG.STAT_Y_OFF)
            local sine = (math.sin(CurTime() * CFG.STAT_FLASH_SPD) + 1) / 2

            local finalCol = table.Copy(statCol)

            if isNoAmmo then
                local glow = 225 + (sine * 30)
                finalCol = Color(glow, 40, 40, glow)
            elseif isLowAmmo or isReloadText then
                finalCol.a = 100 + (sine * 155)
            end

            -- draw.SimpleText(statText, "MW2_Stat_Font", cx + SX(2), cy + SY(2), Color(0, 0, 0, finalCol.a * 0.8), 1, 1)
            -- draw.SimpleText(statText, "MW2_Stat_Font", cx,         cy,         finalCol,                          1, 1)
			
            draw.SimpleTextOutlined(statText, "MW2_Stat_Font", cx + SX(2), cy + SY(2), finalCol, 1, 1, 1.5, Color(0, 0, 0, finalCol.a * 0.8))
        end
    end
end)