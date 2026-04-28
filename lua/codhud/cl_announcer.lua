---- [ ANNOUNCER & MUSIC ] ----

-- Queue system
CoDHUD_AnnouncerQueue = CoDHUD_AnnouncerQueue or {}
CoDHUD_AnnouncerPlaying = CoDHUD_AnnouncerPlaying or false
CoDHUD_AnnouncerNextTime = CoDHUD_AnnouncerNextTime or 0

local ANNOUNCER_COOLDOWN = 1 -- small gap between lines

local function CoDHUD_ProcessAnnouncerQueue()
    if CoDHUD_AnnouncerPlaying then return end
    if #CoDHUD_AnnouncerQueue == 0 then return end

    if CurTime() < CoDHUD_AnnouncerNextTime then return end

    local entry = table.remove(CoDHUD_AnnouncerQueue, 1)
    if not entry then return end

    CoDHUD_AnnouncerPlaying = true

    surface.PlaySound(entry.path)

    -- estimate duration
    local duration = SoundDuration(entry.path) or 2

    timer.Simple(duration, function()
        CoDHUD_AnnouncerPlaying = false
        CoDHUD_AnnouncerNextTime = CurTime() + ANNOUNCER_COOLDOWN
    end)
end

hook.Add("Think", "CoDHUD_AnnouncerQueue_Think", CoDHUD_ProcessAnnouncerQueue)

-- Helper to play sounds with toggle checks
function CoDHUD_PlayAnnouncerSound(path, isMusic)
    if isMusic then
        if not GetConVar("codhud_enable_music"):GetBool() then return end
        surface.PlaySound(path)
        return
    else
        if not GetConVar("codhud_enable_announcer"):GetBool() then return end
    end

    table.insert(CoDHUD_AnnouncerQueue, {
        path = path
    })
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

	local forceEnglish = GetConVar("codhud_enable_announcer_english"):GetBool()

	if forceEnglish then
		lang = "en"
	end

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

	return tryLang(lang) or tryLang("en")
end