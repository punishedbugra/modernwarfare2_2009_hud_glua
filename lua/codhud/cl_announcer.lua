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
function CoDHUD_GetAnnouncerSound(basePath, keys)
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end

    local faction = ply:GetNW2String("CoDHUD_Faction", "")
    if faction == "" then
        faction = cookie.GetString("CoDHUD_SelectedFaction", "rangers")
    end

    if not CoDHUD.Factions["mw2"] or not CoDHUD.Factions["mw2"][faction] then
        return nil
    end

    local voice = CoDHUD.Factions["mw2"][faction].voice
    local lang = GetConVar("gmod_language"):GetString() or "en"

    local function tryLang(l)
        for _, key in ipairs(keys) do

            -- suffix search
            for i = 1, 5 do
                local suffix = (i < 10 and "0" .. i or tostring(i))
                local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. "_" .. suffix .. ".wav"

				-- print("[ANNOUNCER] CHECKING:", path)

                if file.Exists("sound/" .. path, "GAME") then
                    return path
                end
            end

            -- fallback no suffix
            local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. ".wav"

            if file.Exists("sound/" .. path, "GAME") then
                return path
            end
        end

        return nil
    end

    local result = tryLang(lang) or tryLang("en")

    return result
end