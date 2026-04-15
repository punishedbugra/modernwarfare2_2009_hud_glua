local VOICE_FONT = "MW2_VoiceFont"
surface.CreateFont(VOICE_FONT, {
    font = "Conduit ITC", 
    size = 30, 
    weight = 600, 
    antialias = true,
    shadow = true
})

local ICON_ON = Material("icons/voice_on.png", "noclamp smooth")
local ICON_DIM = Material("icons/voice_on_dim.png", "noclamp smooth")

-- Positioning Config
local VOICE_X = 22
local VOICE_Y_START = ScrH() * 0.30 
local SPACING = 28 
local ICON_SIZE = 36
local TEXT_X_OFFSET = 2 

local activeSpeakers = {}

hook.Add("PlayerStartVoice", "MW2_VoiceStart", function(ply)
    activeSpeakers[ply] = true
end)

hook.Add("PlayerEndVoice", "MW2_VoiceEnd", function(ply)
    activeSpeakers[ply] = nil
end)

hook.Add("HUDPaint", "MW2_DrawVoiceChat", function()
    local yOffset = 0

    for ply, _ in pairs(activeSpeakers) do
        if not IsValid(ply) then 
            activeSpeakers[ply] = nil 
            continue 
        end

        local drawY = VOICE_Y_START + yOffset
        
        -- Volume check for icon swapping
        local isSpeaking = ply:VoiceVolume() > 0.05 
        local icon = isSpeaking and ICON_ON or ICON_DIM

        -- Draw Icon
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(VOICE_X, drawY, ICON_SIZE, ICON_SIZE)

        -- Draw Name
        draw.SimpleText(ply:Nick(), VOICE_FONT, VOICE_X + ICON_SIZE + TEXT_X_OFFSET, drawY, Color(255, 255, 255, 255), 0, 0)

        yOffset = yOffset + SPACING
    end
end)

timer.Create("MW2_VoiceKiller", 1, 0, function()
    if IsValid(g_VoicePanelList) then
        g_VoicePanelList:SetVisible(false)
        g_VoicePanelList:SetAlpha(0)
    end
end)

hook.Add("HUDShouldDraw", "MW2_HideVoiceHUD", function(name)
    if name == "CHudVoiceStatus" then return false end
end)