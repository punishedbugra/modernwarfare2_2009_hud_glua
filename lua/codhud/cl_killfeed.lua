---- [ KILLFEED ] ----

-- ==========================================
-- CONFIGURATION & TINKERING
-- ==========================================
local CFG = {
    MAX_MESSAGES = 6,
    LIFETIME = 6,
}

local KillFeed = {}

-- [[ SUPPRESSION OF DEFAULT HUD ]]
hook.Add("HUDShouldDraw", "CoDHUD_Killfeed_HideDefault", function(name)
	if (not GetConVar("codhud_enable_killfeed"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
    if name == "CHudDeathNotice" then return false end
end)

hook.Add("DrawDeathNotice", "CoDHUD_Killfeed_ForceSuppression", function()
	if (not GetConVar("codhud_enable_killfeed"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end
    return false
end)

-- [[ NETWORKING ]]
hook.Add("AddDeathNotice", "CoDHUD_Killfeed_Core", function(attacker, team1, inflictor, victim, team2, flags)

    local ct = CurTime()

    local aEnt = IsValid(attacker) and attacker or nil
    local vEnt = IsValid(victim) and victim or nil
	local suicided = nil
	
	local isHeadshot = vEnt and vEnt.CoDHUD_WasHeadshot == true or false -- Doesn't work atm

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

        weaponClass = suicided and "CoDHUD_MW2_Suicide" or inflictor,

        spawnTime = ct,
        dieTime = ct + CFG.LIFETIME,
		isHeadshot = isHeadshot
    })

    if #KillFeed > CFG.MAX_MESSAGES then
        table.remove(KillFeed, 1)
    end

end)

-- Meta Events
gameevent.Listen("player_connect")
hook.Add("player_connect", "CoDHUD_Feed_Join", function(data)
    table.insert(KillFeed, { type = "meta", msg = string.format( language.GetPhrase("MW2_MP_CONNECTED"), data.name ), spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "CoDHUD_Feed_Leave", function(data)
    table.insert(KillFeed, { type = "meta", msg = string.format( language.GetPhrase("MW2_EXE_LEFTGAME"), data.name ), spawnTime = CurTime(), dieTime = CurTime() + CFG.LIFETIME })
end)

-- [[ RENDERING ]]
hook.Add("HUDPaint", "CoDHUD_Killfeed_Draw", function()
    if (not GetConVar("codhud_enable_killfeed"):GetBool()) or GetConVar("codhud_quickdisable_hud"):GetBool() then return end

	if CoDHUD[CoDHUD_GetHUDType()] and CoDHUD[CoDHUD_GetHUDType()].Killfeed then
		CoDHUD[CoDHUD_GetHUDType()].Killfeed(KillFeed, CFG)
	end
end)