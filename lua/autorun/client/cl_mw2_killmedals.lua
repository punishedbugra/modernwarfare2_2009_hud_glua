-- [[ cl_mw2_killmedals.lua ]]

-- Global flag for the Challenge System to read
_G.MW2_MedalsActive = _G.MW2_MedalsActive or false

if CLIENT then
    -- [[ RESOLUTION SCALING ]]
    -- Uniform scale: takes the smaller axis ratio so nothing stretches on
    -- ultrawide (21:9) or narrow (4:3) screens. Matches cl_vgui's GetUIScale().
    local BASE_W, BASE_H = 1920, 1080

    local function GetUIScale()
        local scaleX = ScrW() / BASE_W
        local scaleY = ScrH() / BASE_H
        return math.max(math.min(scaleX, scaleY), 0.5)
    end

    local function S(x) return math.Round(x * GetUIScale()) end

    -- [[ TINKERING MENU ]]
    local MEDAL_CFG = {
        X_OFFSET = 0,    -- Horizontal offset from center
        Y_OFFSET = -250, -- Vertical offset (Match this with cl_mw2_challenge.lua)
    }

    local medalQueue  = {}
    local activeMedal = nil

    -- TIMING
    local MEDAL_DURATION = 1.5
    local FADE_IN_TIME   = 0.15
    local EXIT_DURATION  = 0.15
    local FADE_OUT_START = MEDAL_DURATION - EXIT_DURATION

    local COL_POINTS = Color(205, 215, 95)

    -- [[ FONT INIT ]]
    local function MW2_InitMedalFonts()
        surface.CreateFont("MW2_MedalPrimary", { font = "Conduit ITC", size = S(42), weight = 800,  antialias = true })
        surface.CreateFont("MW2_MedalGlow",    { font = "Conduit ITC", size = S(44), weight = 1000, blursize = S(12), antialias = true })
        surface.CreateFont("MW2_MedalOutline", { font = "Conduit ITC", size = S(42), weight = 900,  outline = false,  antialias = true })
        surface.CreateFont("MW2_MedalPoints",  { font = "Conduit ITC", size = S(30), weight = 400,  antialias = true })
        surface.CreateFont("MW2_MedalDesc",    { font = "Conduit ITC", size = S(26), weight = 500,  antialias = true })
    end
    MW2_InitMedalFonts()

    hook.Add("OnScreenSizeChanged", "MW2_ReinitMedalFonts", function()
        MW2_InitMedalFonts()
    end)

    local function AddMedalToQueue(txt, hasIcon, pts, desc, isSpecial)
        table.insert(medalQueue, {
            text      = txt,
            hasIcon   = hasIcon,
            points    = pts,
            desc      = desc,
            isSpecial = isSpecial
        })
        if _G.MW2_AddScore then _G.MW2_AddScore(pts) end
    end

    -- [[ NETWORK RECEIVERS (Communicating with Challenge System) ]]
    net.Receive("MW2_Medal_Headshot",   function()
        AddMedalToQueue("SPLASHES_HEADSHOT", true, 50)
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("headshot") end
    end)

    net.Receive("MW2_Medal_DoubleKill", function() AddMedalToQueue("SPLASHES_DOUBLEKILL", false, 50)  end)
    net.Receive("MW2_Medal_TripleKill", function() AddMedalToQueue("SPLASHES_TRIPLEKILL", false, 100) end)
    net.Receive("MW2_Medal_MultiKill",  function() AddMedalToQueue("SPLASHES_MULTIKILL",  false, 100) end)

    net.Receive("MW2_Medal_Longshot",   function()
        AddMedalToQueue("SPLASHES_LONGSHOT", true, 50, "SPLASHES_LONGSHOT_DESC")
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("longshot") end
    end)

    net.Receive("MW2_Medal_OneShot",    function()
        AddMedalToQueue("SPLASHES_ONE_SHOT_KILL", true, 0, "SPLASHES_ONE_SHOT_KILL_DESC", true)
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("oneshot") end
    end)

    net.Receive("MW2_Medal_FirstBlood", function() AddMedalToQueue("SPLASHES_FIRSTBLOOD", true,  100, "SPLASHES_FIRSTBLOOD_DESC")              end)
    net.Receive("MW2_Medal_Comeback",   function() AddMedalToQueue("SPLASHES_COMEBACK",    true,  100, "SPLASHES_COMEBACK_DESC") end)
    net.Receive("MW2_Medal_Payback",    function()
        AddMedalToQueue("SPLASHES_REVENGE", true, 50, "SPLASHES_REVENGE_DESC")
        if _G.MW2_OnMedalReceived then _G.MW2_OnMedalReceived("payback") end
    end)

    -- [[ RENDERING ]]
    hook.Add("HUDPaint", "MW2_DrawMedalsSystem", function()
        local ct = CurTime()

        -- UPDATE GLOBAL FLAG: Tell the Challenge system if we are busy
        if activeMedal ~= nil or #medalQueue > 0 then
            _G.MW2_MedalsActive = true
        else
            _G.MW2_MedalsActive = false
        end

        if activeMedal == nil and #medalQueue > 0 then
            activeMedal       = table.remove(medalQueue, 1)
            activeMedal.start = ct
            surface.PlaySound("hud/hud_medal.mp3")
        end

        if activeMedal then
            local age = ct - activeMedal.start

            if age > MEDAL_DURATION then
                activeMedal = nil
            else
                local alpha = 255
                local scale = 1

                if age < FADE_IN_TIME then
                    local progress = age / FADE_IN_TIME
                    alpha = progress * 255
                    scale = Lerp(progress, 3.5, 1.0)
                elseif age > FADE_OUT_START then
                    local progress = (age - FADE_OUT_START) / EXIT_DURATION
                    alpha = math.Clamp((1 - progress) * 255, 0, 255)
                    scale = Lerp(progress, 1.0, 2.0)
                end

                -- Center of screen plus uniform-scaled offsets.
                -- S() on both axes keeps the medal centered correctly on any
                -- aspect ratio — no more horizontal drift on 21:9.
                local cx = (ScrW() / 2) + S(MEDAL_CFG.X_OFFSET)
                local cy = (ScrH() / 2) + S(MEDAL_CFG.Y_OFFSET)

                local colWhite      = Color(255, 255, 255, alpha)
                local colYellow     = Color(COL_POINTS.r, COL_POINTS.g, COL_POINTS.b, alpha)
                local colRedGlow    = Color(195, 110, 115, alpha * 0.5)
                local colRedOutline = Color(180, 0, 0, alpha * 0.8)

                local mat = Matrix()
                mat:Translate(Vector(cx, cy, 0))
                mat:Scale(Vector(scale, scale, 1))
                mat:Translate(Vector(-cx, -cy, 0))

                cam.PushModelMatrix(mat)
                    -- 1. Draw Medal Icon
                    -- S() for both position offsets and size keeps the icon
                    -- square and correctly placed on any aspect ratio.
                    if activeMedal.hasIcon then
                        surface.SetDrawColor(255, 255, 255, alpha)
                        surface.SetMaterial(Material("icons/crosshair_red.png", "smooth"))
                        surface.DrawTexturedRect(cx - S(60), cy - S(120), S(120), S(120))
                    end

                    -- 2. Draw Medal Text
                    draw.SimpleText( language.GetPhrase("MW2_" .. activeMedal.text ), "MW2_MedalGlow",    cx, cy, colRedGlow,    1, 1)
                    draw.SimpleText( language.GetPhrase("MW2_" .. activeMedal.text ), "MW2_MedalOutline", cx, cy, colRedOutline, 1, 1)
                    draw.SimpleText( language.GetPhrase("MW2_" .. activeMedal.text ), "MW2_MedalPrimary", cx, cy, colWhite,      1, 1)

                    -- 3. Draw Description or Points
                    if activeMedal.desc then
                        if activeMedal.isSpecial then
                            draw.SimpleText( language.GetPhrase("MW2_" .. activeMedal.desc ), "MW2_MedalDesc", cx, cy + S(35), colWhite, 1, 1)
                        else
                            local descText     =  language.GetPhrase("MW2_" .. activeMedal.desc ) .. " ("
                            local pointsText   = "+" .. activeMedal.points
                            local bracketClose = ")"

                            surface.SetFont("MW2_MedalDesc")
                            local w1 = surface.GetTextSize(descText)
                            local w2 = surface.GetTextSize(pointsText)
                            local totalW = w1 + w2 + surface.GetTextSize(bracketClose)

                            local startX = cx - (totalW / 2)
                            draw.SimpleText(descText,     "MW2_MedalDesc", startX,           cy + S(35), colWhite,  0, 1)
                            draw.SimpleText(pointsText,   "MW2_MedalDesc", startX + w1,      cy + S(35), colYellow, 0, 1)
                            draw.SimpleText(bracketClose, "MW2_MedalDesc", startX + w1 + w2, cy + S(35), colWhite,  0, 1)
                        end
                    else
                        draw.SimpleText("+" .. activeMedal.points, "MW2_MedalPoints", cx + S(2), cy + S(37), Color(0, 0, 0, alpha * 0.8), 1, 1)
                        draw.SimpleText("+" .. activeMedal.points, "MW2_MedalPoints", cx,         cy + S(35), colYellow,                   1, 1)
                    end
                cam.PopModelMatrix()
            end
        end
    end)
end