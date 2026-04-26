---- [ ANNOUNCER & MUSIC ] ----

-- Helper to play sounds with toggle checks
function CoDHUD_PlayAnnouncerSound(path, isMusic)
    if isMusic then
        if not GetConVar("codhud_enable_music"):GetBool() then return end
    else
        if not GetConVar("codhud_enable_announcer"):GetBool() then return end
    end

    surface.PlaySound(path)
end

-- Resolve announcer sound with language + suffix fallback
function CoDHUD_GetAnnouncerSound(keys)
    if isstring(keys) then
        keys = { keys }
    end

    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end

    local faction = ply:GetNW2String("CoDHUD_Faction", "")
    if faction == "" then
        faction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    end

    if not CoDHUD.Factions[CoDHUD_GetHUDType()] or not CoDHUD.Factions[CoDHUD_GetHUDType()][faction] then
        return nil
    end

	local voice = CoDHUD.Factions[CoDHUD_GetHUDType()][faction].voicepath
    local lang = GetConVar("gmod_language"):GetString() or "en"

    local function tryLang(l)
        for _, key in ipairs(keys) do
		
            -- suffix search
            for i = 1, 5 do
                local suffix = (i < 10 and "0" .. i or tostring(i))
				local path = "announcer/" .. CoDHUD_GetHUDType() .. "/" .. l .. "/" .. CoDHUD.Factions[CoDHUD_GetHUDType()][faction].voicepath .. key .. "_" .. suffix .. ".wav"

                if file.Exists("sound/" .. path, "GAME") then
                    return path
                end
            end

            -- fallback no suffix
            local path = "announcer/" .. CoDHUD_GetHUDType() .. "/" .. l .. "/" .. CoDHUD.Factions[CoDHUD_GetHUDType()][faction].voicepath .. key .. ".wav"

            if file.Exists("sound/" .. path, "GAME") then
                return path
            end
        end

        return nil
    end

    local result = tryLang(lang) or tryLang("en")

    return result
end