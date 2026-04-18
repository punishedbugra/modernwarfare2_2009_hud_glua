local BASE_W, BASE_H = 1920, 1080
local function SX(x) return math.Round(x * (ScrW() / BASE_W)) end
local function SY(y) return math.Round(y * (ScrH() / BASE_H)) end
local function S(x)  return math.Round(x * (ScrH() / BASE_H)) end

local MAP_CFG = {
    X = 12,
    Y = 16,
    W = 224,
    H = 224,

    ALPHA_BORDER    = 255,
    ALPHA_MAP_BG    = 120,
    ALPHA_PLAYER    = 255,
    ALPHA_STATIC_S  = 100,
    ALPHA_MOVING_S  = 255,

    SIZE_PLAYER     = 42,
    SIZE_FRIENDLY   = 42,
    SIZE_ENEMY      = 42,

    SCAN_SPEED      = 48,
    FADE_TIME       = 0.7,
    FADE_TIME_VIS   = 1.3,

    -- [ TINKERING ] 
    -- Adjust this to control how close icons get to the edge. 
    -- 0 means the center of the icon sits exactly on the border line. 
    EDGE_PADDING    = 0, 
}

local MAT_BORDER        = Material("minimap/minimap_background.png", "smooth")
local MAT_MAP_BG        = Material("minimap/compass_map_default.png", "smooth")
local MAT_PLAYER        = Material("minimap/compassping_player.png", "smooth")
local MAT_STATIC_SCAN   = Material("minimap/minimap_scanlines.png", "smooth")
local MAT_MOVING_SCAN   = Material("minimap/scanlines.png", "smooth")

local MAT_FRIEND_HOLLOW  = Material("minimap/compassping_green_hollow_mp.png", "smooth")
local MAT_ENEMY_FIRING   = Material("minimap/compassping_enemyfiring.png", "smooth")

MW2_DeathCache = MW2_DeathCache or {}
MW2_VisCache = MW2_VisCache or {}

hook.Add("HUDPaint", "MW2_Minimap_UAV", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if not GetConVar("mw2_enable_minimap"):GetBool() then return end
	if not GetConVar("cl_drawhud"):GetBool() then return end

    local x, y = SX(MAP_CFG.X), SY(MAP_CFG.Y)
    local w, h = S(MAP_CFG.W), S(MAP_CFG.H)
    local centerX, centerY = x + (w / 2), y + (h / 2)

    -- 1. LAYER: MINIMAP BORDER
    surface.SetMaterial(MAT_BORDER)
    surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_BORDER)
    surface.DrawTexturedRect(x, y, w, h)

    -- [[ STENCIL MASKING ]]
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)

    surface.SetMaterial(MAT_BORDER)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(x, y, w, h)

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)

        -- 2. LAYER: COMPASS MAP BACKGROUND
        surface.SetMaterial(MAT_MAP_BG)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_MAP_BG)
        surface.DrawTexturedRect(x, y, w, h)
        
        -- 3. LAYER: STATIC SCANLINES
        surface.SetMaterial(MAT_STATIC_SCAN)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_STATIC_S)
        surface.DrawTexturedRect(x, y, w, h)

        -- 4. LAYER: REPETITIVE MOVING SCANLINES
        surface.SetMaterial(MAT_MOVING_SCAN)
        surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_MOVING_S)
        local moveOffset = (CurTime() * MAP_CFG.SCAN_SPEED) % h
        surface.DrawTexturedRect(x, y - moveOffset, w, h)
        surface.DrawTexturedRect(x, y - moveOffset + h, w, h)

    render.SetStencilEnable(false)
    -- [[ STENCIL END ]]

    -- 5. LAYER: THE ICONS
    local pSize = S(MAP_CFG.SIZE_PLAYER)
    local fSize = S(MAP_CFG.SIZE_FRIENDLY)
    local eSize = S(MAP_CFG.SIZE_ENEMY)
    
    local localFaction = ply:GetNW2String("MW2_Faction", "")
    local targets = ents.FindByClass("npc_*")
    table.Add(targets, player.GetAll())

    for _, ent in ipairs(targets) do
        if not IsValid(ent) or ent == ply then continue end
        
        local isAlive = (ent:IsPlayer() and ent:Alive()) or (ent:IsNPC() and ent:Health() > 0)
        local targetFaction = ent:GetNW2String("MW2_Faction", "")
        local isFriendly = (localFaction ~= "" and targetFaction == localFaction)
        local entIdx = ent:EntIndex()

        -- Visibility / Shared Vision Check (Enemies only)
        local isVisibleToTeam = false
        if not isFriendly then
            for _, observer in ipairs(player.GetAll()) do
                local obsFaction = observer:GetNW2String("MW2_Faction", "")
                local isObserverFriendly = (localFaction ~= "" and obsFaction == localFaction)
                
                if observer == ply or (isObserverFriendly and observer:Alive()) then
                    local dirToEnt = (ent:WorldSpaceCenter() - observer:EyePos()):GetNormalized()
                    local dot = observer:GetAimVector():Dot(dirToEnt)
                    local fovRad = math.rad((observer:IsPlayer() and observer:GetFOV() or 90) / 2)
                    
                    if dot > math.cos(fovRad) then
                        local tr = util.TraceLine({
                            start = observer:EyePos(),
                            endpos = ent:WorldSpaceCenter(),
                            filter = {observer, ent},
                            mask = MASK_SHOT
                        })
                        if not tr.Hit then
                            isVisibleToTeam = true
                            break
                        end
                    end
                end
            end

            if isVisibleToTeam and isAlive then
                MW2_VisCache[entIdx] = CurTime() + MAP_CFG.FADE_TIME_VIS
            end
        end

        local visAlpha = 0
        if MW2_VisCache[entIdx] then
            local timeLeft = MW2_VisCache[entIdx] - CurTime()
            if timeLeft > 0 then
                visAlpha = math.Clamp(timeLeft / MAP_CFG.FADE_TIME_VIS, 0, 1) * 255
            else
                MW2_VisCache[entIdx] = nil
            end
        end

        -- Base alpha logic: Friendlies are always 255, enemies use visAlpha
        local alpha = 255
        if not isFriendly then
            alpha = visAlpha
        end

        if not isAlive then
            if isFriendly then 
                continue 
            else
                if not MW2_DeathCache[entIdx] then
                    MW2_DeathCache[entIdx] = CurTime()
                end
                
                local timeSinceDeath = CurTime() - MW2_DeathCache[entIdx]
                if timeSinceDeath > MAP_CFG.FADE_TIME then continue end
                alpha = math.min(alpha, 255 * (1 - (timeSinceDeath / MAP_CFG.FADE_TIME)))
            end
        else
            MW2_DeathCache[entIdx] = nil
        end

        if alpha <= 0 then continue end

        -- Relative Position Math
        local relPos = ent:GetPos() - ply:GetPos()
        local dist = relPos:Length() / 8 
        
        local posAngle = relPos:Angle()
        posAngle.y = posAngle.y - ply:EyeAngles().y + 90
        
        local rad = math.rad(posAngle.y)
        local offsetX = math.cos(rad) * dist
        local offsetY = -math.sin(rad) * dist

        -- Square clamp logic using the tinkering variable
        local boundsX = (w / 2) - MAP_CFG.EDGE_PADDING
        local boundsY = (h / 2) - MAP_CFG.EDGE_PADDING

        if math.abs(offsetX) > boundsX or math.abs(offsetY) > boundsY then
            local scaleX = boundsX / math.max(0.0001, math.abs(offsetX))
            local scaleY = boundsY / math.max(0.0001, math.abs(offsetY))
            local scale = math.min(scaleX, scaleY)
            offsetX = offsetX * scale
            offsetY = offsetY * scale
        end

        local targetX = centerX + offsetX
        local targetY = centerY + offsetY

        if isFriendly then
            local rotation = ent:EyeAngles().y - ply:EyeAngles().y
            surface.SetMaterial(MAT_FRIEND_HOLLOW)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRectRotated(targetX, targetY, fSize, fSize, rotation)
        else
            surface.SetMaterial(MAT_ENEMY_FIRING)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRect(targetX - (eSize / 2), targetY - (eSize / 2), eSize, eSize)
        end
    end

    -- Draw Local Player Icon (Static center)
    surface.SetMaterial(MAT_PLAYER)
    surface.SetDrawColor(255, 255, 255, MAP_CFG.ALPHA_PLAYER)
    surface.DrawTexturedRect(centerX - (pSize / 2), centerY - (pSize / 2), pSize, pSize)
end)