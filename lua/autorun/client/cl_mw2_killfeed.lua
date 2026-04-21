-- [[ cl_mw2_killfeed.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x) return math.Round(x * GetUIScale()) end

-- ==========================================
-- CONFIGURATION & TINKERING
-- ==========================================
local CFG = {
    X_POS = 10,
    Y_POS = 210,
    SPACING = 26,
    MAX_MESSAGES = 6,
    LIFETIME = 6,

    ICON_W = 32,
    ICON_H = 32,
    ICON_ALPHA = 165,
    ICON_OFFSET_Y = 0,

    TEXT_ALPHA = 155,

    FONT_SIZE = 34,
    
    -- Animation Settings
    ANIM_TIME = 0.25, -- How long the fade-in lasts
    ANIM_RISE = 15,   -- How many pixels it rises from below
}

-- [[ FONT ]]
local function MW2_InitKillfeedFont()
    surface.CreateFont("MW2_KillfeedFont", {
        font = "Conduit ITC",
        size = S(CFG.FONT_SIZE),
        weight = 400,
        antialias = true,
        shadow = true,
        outline = false,
    })
end

MW2_InitKillfeedFont()

hook.Add("OnScreenSizeChanged", "MW2_ReinitKillfeedFont", function()
    MW2_InitKillfeedFont()
end)

local KillFeed = {}

-- [[ COLORS & FACTION MAPPING ]]
local COL_WEST  = Color(100, 110, 120) 
local COL_EAST  = Color(120, 110, 100)
local COL_WHITE = Color(255, 255, 255)

local function GetFactionColor(ent)
    if not IsValid(ent) then return COL_WHITE end
    local faction = ent:GetNW2String("MW2_Faction", "none")
    local axis = { ["arab"] = true, ["ussr"] = true, ["militia"] = true }
    local allies = { ["rangers"] = true, ["taskforce141"] = true, ["seals"] = true }

    if axis[faction] then return COL_EAST end
    if allies[faction] then return COL_WEST end
    return COL_WHITE
end

-- [[ SPECIAL ICONS ]]
killicon.Add("MW2_Suicide", "killfeed/death_suicide.png", Color(255, 255, 255, 0))
killicon.Add("MW2_Headshot", "killfeed/death_headshot.png", Color(255, 255, 255, 0))

-- [[ SUPPRESSION OF DEFAULT HUD ]]
hook.Add("HUDShouldDraw", "MW2_Killfeed_HideDefault", function(name)
	if not GetConVar("mw2_enable_killfeed"):GetBool() then return end
    if name == "CHudDeathNotice" then return false end
end)

hook.Add("DrawDeathNotice", "MW2_Killfeed_ForceSuppression", function()
	if not GetConVar("mw2_enable_killfeed"):GetBool() then return end
    return false
end)

-- [[ NETWORKING ]]
hook.Add("AddDeathNotice", "MW2_Killfeed_Core", function(attacker, team1, inflictor, victim, team2, flags)

    local ct = CurTime()

    local aEnt = IsValid(attacker) and attacker or nil
    local vEnt = IsValid(victim) and victim or nil
	local suicided = nil
	
	local isHeadshot = vEnt and vEnt.MW2_WasHeadshot == true or false -- Doesn't work atm

    -- fallback: try resolving players by name (IMPORTANT)
    if not aEnt and isstring(attacker) then
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == attacker then
                aEnt = ply
                break
            end
        end
    end

    if not vEnt and isstring(victim) then
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == victim then
                vEnt = ply
                break
            end
        end
    end

	if ( inflictor == "suicide" ) then
		attacker = ""
		suicided = true
	end

    table.insert(KillFeed, {
        type = "kill",

        attackerName = isstring(attacker) and attacker or (IsValid(aEnt) and aEnt:Nick() or "World"),
        victimName   = isstring(victim) and victim or (IsValid(vEnt) and vEnt:Nick() or "Unknown"),

        attackerEnt = aEnt,
        victimEnt = vEnt,

        weaponClass = suicided and "MW2_Suicide" or inflictor,

        spawnTime = ct,
        dieTime = ct + CFG.LIFETIME,
		isHeadshot = isHeadshot
    })

    if #KillFeed > CFG.MAX_MESSAGES then
        table.remove(KillFeed, 1)
    end

end)

-- Meta Events
gameevent.Listen("player_connect_client")
hook.Add("player_connect_client", "MW2_Feed_Join", function(data)
    table.insert(KillFeed, { type = "meta", msg = string.format( language.GetPhrase("MW2_MP_CONNECTED"), data.name ), spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "MW2_Feed_Leave", function(data)
    table.insert(KillFeed, { type = "meta", msg = string.format( language.GetPhrase("MW2_EXE_LEFTGAME"), data.name ), spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

-- [[ RENDERING ]]
hook.Add("HUDPaint", "MW2_Killfeed_Draw", function()
    if not GetConVar("mw2_enable_killfeed"):GetBool() then return end

    local ct = CurTime()

    -- Scale all layout values uniformly at draw time.
    local xPos = S(CFG.X_POS)
    local yPos = S(CFG.Y_POS)
    local spacing = S(CFG.SPACING)
    local iconW = S(CFG.ICON_W)
    local iconH = S(CFG.ICON_H)
    local iconOffY = S(CFG.ICON_OFFSET_Y)
    local gap_name = S(10)
    local gap_icon = S(5)
    local gap_extra = S(25)

    local baseY = ScrH() - yPos

    for i = #KillFeed, 1, -1 do
        local data = KillFeed[i]
        local age = ct - data.spawnTime
        local timeLeft = data.dieTime - ct

		local ICON_BOX_W = iconW
		local ICON_BOX_H = iconH

        if timeLeft <= 0 then
            table.remove(KillFeed, i)
            continue
        end

        -- Calculate Animation and Fading
        local animProgress = math.Clamp(age / CFG.ANIM_TIME, 0, 1)
        local fadeFactor = 1

        if age < CFG.ANIM_TIME then
            -- Fade in from below
            fadeFactor = animProgress
        elseif timeLeft < 1 then
            -- Fade out (standard)
            fadeFactor = math.Clamp(timeLeft, 0, 1)
        end

		-- Check kill icon size
		local cls = data.isHeadshot and "MW2_Headshot" or data.weaponClass
		local w, h = killicon.GetSize(cls)

        -- Vertical Offset Logic: Start lower and rise up
        local yOffset = (1 - animProgress) * S(CFG.ANIM_RISE)
        -- local currentY = baseY - ((#KillFeed - i) * spacing) + yOffset
        local currentY = baseY - ((#KillFeed - i) * h) + yOffset

        local x = xPos
        local finalTxtAlpha = CFG.TEXT_ALPHA * fadeFactor

        surface.SetFont("MW2_KillfeedFont")

		local attackerEnt = data.attackerEnt
		local victimEnt = data.victimEnt

		local aColBase = GetFactionColor(attackerEnt)
		local vColBase = GetFactionColor(victimEnt)

		local aCol = Color(aColBase.r, aColBase.g, aColBase.b, finalTxtAlpha)
		local vCol = Color(vColBase.r, vColBase.g, vColBase.b, finalTxtAlpha)

        if data.type == "kill" then
            -- 1. Attacker
            if data.attackerName != "" then
                draw.SimpleText(data.attackerName, "MW2_KillfeedFont", x, currentY, aCol)
                -- draw.SimpleTextOutlined( data.attackerName, "MW2_KillfeedFont", x, currentY, aCol, 0, 0, 1, Color(0, 0, 0, math.Clamp(finalTxtAlpha, 0, 50)) )

                local tw, _ = surface.GetTextSize(data.attackerName)
                x = x + tw + gap_name
            end

            -- 2. Icon
			local iconBoxX = x + gap_extra
			local iconBoxY = currentY

			local alpha = math.min(CFG.ICON_ALPHA * fadeFactor, 255)

			w = w or ICON_BOX_W
			h = h or ICON_BOX_H

			local drawX = iconBoxX + (ICON_BOX_W - w) * 0.5
			local drawY = iconBoxY + (ICON_BOX_H - h) * 0.5

			killicon.Draw(drawX, drawY, cls, alpha)

			x = iconBoxX + ICON_BOX_W + gap_icon + gap_extra

            -- 3. Victim
            draw.SimpleText(data.victimName, "MW2_KillfeedFont", x, currentY, vCol)
            -- draw.SimpleTextOutlined( data.victimName, "MW2_KillfeedFont", x, currentY, vCol, 0, 0, 1, Color(0, 0, 0, math.Clamp(finalTxtAlpha, 0, 50)) )
        else
            draw.SimpleText(data.msg, "MW2_KillfeedFont", x, currentY, Color(255, 255, 255, finalTxtAlpha))
        end
    end
end)