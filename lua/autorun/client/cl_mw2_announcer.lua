-- cl_mw2_announcer.lua

local MW2_ANNOUNCER_DEBUG = false

-- Helper to play sounds with toggle checks
function MW2HUD_PlayAnnouncerSound(path, isMusic)
    if isMusic then
        if not GetConVar("mw2_enable_music"):GetBool() then return end
    else
        if not GetConVar("mw2_enable_announcer"):GetBool() then return end
    end

    if MW2_ANNOUNCER_DEBUG then
        print("[ANNOUNCER] PLAY:", path)
    end

    surface.PlaySound(path)
end

-- Resolve announcer sound with language + suffix fallback
function MW2HUD_GetAnnouncerSound(basePath, keys)
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end

    local faction = ply:GetNW2String("MW2_Faction", "")
    if faction == "" then
        faction = cookie.GetString("MW2_SelectedFaction", "rangers")
    end

    if not MW2Factions or not MW2Factions[faction] then
        if MW2_ANNOUNCER_DEBUG then
            print("[ANNOUNCER] Invalid faction:", faction)
        end
        return nil
    end

    local voice = MW2Factions[faction].voice
    local lang = GetConVar("gmod_language"):GetString() or "en"

    local function tryLang(l)
        if MW2_ANNOUNCER_DEBUG then
            print("[ANNOUNCER] Trying language:", l)
        end

        for _, key in ipairs(keys) do

            -- suffix search
            for i = 1, 5 do
                local suffix = (i < 10 and "0" .. i or tostring(i))
                local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. "_" .. suffix .. ".wav"

				-- print("[ANNOUNCER] CHECKING:", path)

                if file.Exists("sound/" .. path, "GAME") then
                    if MW2_ANNOUNCER_DEBUG then
                        -- print("[ANNOUNCER] FOUND (suffix):", path)
                    end
                    return path
                end
            end

            -- fallback no suffix
            local path = "announcer/" .. l .. "/" .. voice .. "/mp/" .. voice .. "_1mc_" .. key .. ".wav"

			-- print("[ANNOUNCER] CHECKING:", path)

            if file.Exists("sound/" .. path, "GAME") then
                if MW2_ANNOUNCER_DEBUG then
                    -- print("[ANNOUNCER] FOUND (base):", path)
                end
                return path
            end

            if MW2_ANNOUNCER_DEBUG then
                -- print("[ANNOUNCER] NOT FOUND:", key, "in", l, "voice:", voice)
            end
        end

        return nil
    end

    local result = tryLang(lang) or tryLang("en")

    if MW2_ANNOUNCER_DEBUG then
        -- print("[ANNOUNCER] FINAL RESULT:", result or "NONE")
    end

    return result
end