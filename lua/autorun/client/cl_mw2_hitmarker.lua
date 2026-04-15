if CLIENT then
    -- [[ RESOLUTION SCALING ]]
    local BASE_W, BASE_H = 1920, 1080
    local function SX(x) return math.Round(x * (ScrW() / BASE_W)) end
    local function SY(y) return math.Round(y * (ScrH() / BASE_H)) end
    local function S(x)  return math.Round(x * (ScrH() / BASE_H)) end

    -- [[ FONT INIT ]]
    local function MW2_InitHitFonts()
        surface.CreateFont("MW2_Score_Main", {
            font      = "BankGothic Md BT",
            size      = S(36),
            weight    = 400,
            antialias = true,
        })
        surface.CreateFont("MW2_Score_Plus", {
            font      = "BankGothic Md BT",
            size      = S(32),
            weight    = 800,
            antialias = true,
        })
    end

    MW2_InitHitFonts()

    hook.Add("OnScreenSizeChanged", "MW2_ReinitHitFonts", function()
        MW2_InitHitFonts()
    end)

    -- [[ VARIABLES ]]
    local matHit = Material("icons/hitmarker.png", "mips smooth")
    local hitAlpha, hitTime = 0, 0
    local scoreVal, scoreAlpha, scoreTime, scoreStart = 0, 0, 0, 0
    local scoreScale = 1
    local currentPulseAlpha = 255

    _G.MW2_AddScore = function(amount)
        local ct = CurTime()
        scoreVal   = scoreVal + amount
        scoreAlpha = 255
        scoreTime  = ct + 1.5
        scoreStart = ct
    end

    -- [[ SQUEEZED SCORE DRAW ]]
    local function DrawSqueezedScore(val, x, y, alpha)
        local textCol   = Color(255, 255, 50, alpha)
        local shadowCol = Color(0, 0, 0, alpha * 0.8)
        local s_val     = tostring(val)
        local partPlus  = "+"

        surface.SetFont("MW2_Score_Plus")
        local wP  = surface.GetTextSize(partPlus)
        local gapPlus = SX(-6)

        surface.SetFont("MW2_Score_Main")

        local totalW = wP + gapPlus
        for i = 1, #s_val do
            local char = s_val:sub(i, i)
            local w    = surface.GetTextSize(char)
            totalW = totalW + w
            if i < #s_val then
                local gap = (char == "1") and SX(-11) or SX(-5)
                totalW = totalW + gap
            end
        end

        local curX = x - (totalW / 2)

        local function DrawComponent(txt, font, px, py)
            -- draw.SimpleText(txt, font, px + SX(1), py + SY(1), shadowCol, 0, 1)
            -- draw.SimpleText(txt, font, px,          py,          textCol,   0, 1)
			
			draw.SimpleTextOutlined(txt, font, px, py, textCol, 0, 1, 1.0, shadowCol)
            surface.SetFont(font)
            local w = surface.GetTextSize(txt)
            return w
        end

        local runX = curX
        runX = runX + DrawComponent(partPlus, "MW2_Score_Plus", runX, y) + gapPlus

        for i = 1, #s_val do
            local char = s_val:sub(i, i)
            local w    = DrawComponent(char, "MW2_Score_Main", runX, y)
            if i < #s_val then
                local gap = (char == "1") and SX(-11) or SX(-5)
                runX = runX + w + gap
            end
        end
    end

    -- [[ HUD PAINT HOOK ]]
    hook.Add("HUDPaint", "MW2_DrawHitmarkerSystem", function()
        local ct = CurTime()
        local cx, cy = ScrW() / 2, ScrH() / 2

        -- DRAW HITMARKER (icon size intentionally fixed, not scaled)
        if ct < hitTime then
            local fade = math.Clamp((hitTime - ct) / 0.9, 0, 1) * 255
            surface.SetMaterial(matHit)
            surface.SetDrawColor(255, 255, 255, fade)
            local size = 36
            surface.DrawTexturedRect(cx - (size / 2), cy - (size / 2), size, size)
        end

        -- SCORE POPUP
        if ct < scoreTime then
            local animTime = ct - scoreStart

            if animTime < 0.1 then
                local frac = animTime / 0.2
                scoreScale        = Lerp(frac, 1, 2.7)
                currentPulseAlpha = Lerp(frac, 255, 120)
            elseif animTime < 0.3 then
                local frac = (animTime - 0.2) / 0.2
                scoreScale        = Lerp(frac, 2.7, 1.0)
                currentPulseAlpha = Lerp(frac, 120, 255)
            else
                scoreScale        = 1
                currentPulseAlpha = 255
            end

            local finalAlpha = scoreAlpha
            if scoreTime - ct < 0.3 then
                scoreAlpha = math.Approach(scoreAlpha, 0, FrameTime() * 800)
                finalAlpha = scoreAlpha
            end

            local drawAlpha = (currentPulseAlpha / 255) * finalAlpha
            local drawY     = cy - SY(140)

            local mat = Matrix()
            mat:Translate(Vector(cx, drawY, 0))
            mat:Scale(Vector(scoreScale, scoreScale, 1))
            mat:Translate(Vector(-cx, -drawY, 0))

            cam.PushModelMatrix(mat)
                DrawSqueezedScore(scoreVal, cx, drawY, drawAlpha)
            cam.PopModelMatrix()
        else
            scoreVal = 0
        end
    end)

    net.Receive("MW2_HitNotification", function()
        local isKill = net.ReadBool()
        local ct     = CurTime()
        local ply    = LocalPlayer()

        hitAlpha = 255
        hitTime  = ct + 0.5

        ply:EmitSound("hud/hitmarker.mp3", 100, 100, 1, CHAN_AUTO)

        if isKill then _G.MW2_AddScore(100) end
    end)
end