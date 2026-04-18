-- [[ cl_mw2_chat.lua ]]

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

-- The universal scale factor used to keep UI elements proportionate across resolutions
local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

-- Scaling function for pixels/sizes
local function S(x) return math.Round(x * GetUIScale()) end

local CHAT_FONT = "MW2_ChatFont"

-- Function to (re)initialize font on screen size change
local function MW2_InitChatFont()
    surface.CreateFont(CHAT_FONT, {
        font = "Conduit ITC", 
        size = S(22), 
        weight = 400, 
        antialias = true,
        shadow = true
    })
end

-- Initialize immediately on load so the font exists before HUDPaint fires
MW2_InitChatFont()

hook.Add("OnScreenSizeChanged", "MW2_ReinitChatFont", function()
    MW2_InitChatFont()
end)

local chatHistory = {}
local MAX_MESSAGES = 4 
local MESSAGE_LIFETIME = 10 
local FADE_TIME = 1

-- Ratio for vertical positioning (45% down the screen)
local CHAT_INPUT_Y_RATIO = 0.45

local COL_WHITE = Color(255, 255, 255)
local COL_TEAM  = Color(85, 195, 190)
local MAT_GRAD  = Material("vgui/gradient-l")

-- Faction Color Definitions
local COL_FACTION_WEST = Color(100, 110, 120) -- rangers, taskforce141, seals
local COL_FACTION_EAST = Color(120, 110, 100) -- ussr, arab, militia

local isTyping = false
local chatType = "say"

-- [[ LOGIC: CLOSE CHAT ]]
local function CloseMW2Chat()
    if IsValid(MW2_ChatEntry) then MW2_ChatEntry:Remove() end
    isTyping = false
    gui.EnableScreenClicker(false)
    if not vgui.CursorVisible() then gui.HideGameUI() end
end

-- [[ LOGIC: OPEN CHAT ]]
local function OpenMW2Chat(isTeam)
    if isTyping then return end
    isTyping = true
    chatType = isTeam and "say_team" or "say"
    
    MW2_ChatEntry = vgui.Create("DTextEntry")
    MW2_ChatEntry:SetSize(1, 1) 
    MW2_ChatEntry:SetPos(-10, -10)
    MW2_ChatEntry:MakePopup()
    MW2_ChatEntry:RequestFocus()
    
    -- Allow common command prefixes to be handled correctly
    MW2_ChatEntry.OnKeyCodeTyped = function(self, code)
        if code == KEY_ESCAPE then
            CloseMW2Chat()
            return true 
        elseif code == KEY_ENTER then
            local txt = self:GetText()
            
            if txt and txt:Trim() ~= "" then
                -- This ensures that hooks like "OnPlayerChat" and "PlayerSay" 
                -- are triggered properly for commands like !help or /menu
                RunConsoleCommand(chatType, txt) 
            end
            
            CloseMW2Chat()
            return true
        end
    end

    -- Fix: Ensure clicking away or losing focus cleans up the UI properly
    MW2_ChatEntry.OnFocusChanged = function(self, gained)
        if not gained then 
            timer.Simple(0, function() 
                if not IsValid(self) then return end
                CloseMW2Chat() 
            end) 
        end
    end
end

hook.Add("PlayerBindPress", "MW2_Chat_BindPress", function(ply, bind, pressed)
    if not pressed then return end
    if bind == "messagemode" then OpenMW2Chat(false) return true
    elseif bind == "messagemode2" then OpenMW2Chat(true) return true end
end)

-- [[ RENDERING ]]
hook.Add("HUDPaint", "MW2_DrawChat", function()
    local curTime = CurTime()

    -- We calculate these inside the hook using S(x) so they update instantly if resolution changes
    local chatInputY = ScrH() * CHAT_INPUT_Y_RATIO
    local lineHeight = S(22)
    local marginX    = S(25)

    -- 1. INPUT AREA
    if isTyping and IsValid(MW2_ChatEntry) then
        local prompt      = (chatType == "say_team" and "say_team:" or "say:")
        local currentText = MW2_ChatEntry:GetText()
        draw.SimpleText(prompt .. " " .. currentText, CHAT_FONT, marginX, chatInputY, Color(255, 255, 255, 225), 0, 0)

        if math.floor(CurTime() * 3) % 2 == 0 then
            surface.SetFont(CHAT_FONT)
            local tw = surface.GetTextSize(prompt .. " " .. currentText)
            draw.SimpleText("_", CHAT_FONT, marginX + tw + 2, chatInputY, Color(255, 255, 255, 225), 0, 0)
        end
    end

    -- 2. MESSAGE HISTORY
    local currentY = chatInputY - lineHeight

    for i = #chatHistory, 1, -1 do
        local data = chatHistory[i]
        local timeActive = curTime - data.time
        local alpha = 0

        if isTyping then
            alpha = 225
        elseif timeActive <= MESSAGE_LIFETIME then
            alpha = 225
        elseif timeActive <= MESSAGE_LIFETIME + FADE_TIME then
            alpha = math.Clamp(225 - (((timeActive - MESSAGE_LIFETIME) / FADE_TIME) * 225), 0, 225)
        end

        if alpha > 0 then
            surface.SetFont(CHAT_FONT)

            -- Determine Name Color based on Server Faction (NW2String)
            local nameCol = COL_WHITE
            if IsValid(data.ply) then
                local fac = data.ply:GetNW2String("MW2_Faction", "rangers")
                if fac == "rangers" or fac == "taskforce141" or fac == "seals" then
                    nameCol = COL_FACTION_WEST
                elseif fac == "ussr" or fac == "arab" or fac == "militia" then
                    nameCol = COL_FACTION_EAST
                end
            end

            -- Prefix format: (Faction)Player:
            local prefix  = data.isTeam and ("(" .. data.faction .. ")") or ""
            local nameStr = prefix .. data.sender .. ": "
            
            local nw = surface.GetTextSize(nameStr)
            local mw = surface.GetTextSize(data.msg)
            local totalW  = nw + mw

            -- Draw Individual Background Gradient using S(60) for scaled padding
            surface.SetMaterial(MAT_GRAD)
            surface.SetDrawColor(0, 0, 0, math.Clamp(alpha - 45, 0, 180))
            surface.DrawTexturedRect(0, currentY, marginX + totalW + S(60), lineHeight)

            -- Draw Text
            local bodyCol = data.isTeam and COL_TEAM or COL_WHITE
            draw.SimpleText(nameStr, CHAT_FONT, marginX,      currentY, Color(nameCol.r, nameCol.g, nameCol.b, alpha), 0, 0)
            draw.SimpleText(data.msg, CHAT_FONT, marginX + nw, currentY, Color(bodyCol.r, bodyCol.g, bodyCol.b, alpha), 0, 0)
            
            currentY = currentY - lineHeight
        end
    end
end)

-- [[ NETWORKING ]]
net.Receive("MW2_ChatMessage", function()
    local ply = net.ReadEntity()
    local text = net.ReadString()
    local isTeam = net.ReadBool()
    local factionName = net.ReadString()

    if not IsValid(ply) then return end

    table.insert(chatHistory, {
        ply = ply,
        sender = ply:Nick(),
        faction = factionName,
        msg = text,
        isTeam = isTeam,
        time = CurTime()
    })

    if #chatHistory > MAX_MESSAGES then table.remove(chatHistory, 1) end
end)

hook.Add("HUDShouldDraw", "MW2_HideDefaultChat", function(name)
    if name == "CHudChat" then return false end
end)