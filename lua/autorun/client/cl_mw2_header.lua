MW2_Header = {}
MW2_Header.__index = MW2_Header

MW2_HeaderQueue = MW2_HeaderQueue or {}
MW2_HeaderQueue.Active = MW2_HeaderQueue.Active or {}
MW2_HeaderQueue.Queue = {}

local GLITCH = { "a", "¶", "Ð", "ق", "§", "ð", "œ", "ش", "Ф" }

-- [[ RESOLUTION SCALING ]]
local BASE_W, BASE_H = 1920, 1080

local function GetUIScale()
    local scaleX = ScrW() / BASE_W
    local scaleY = ScrH() / BASE_H
    return math.max(math.min(scaleX, scaleY), 0.5)
end

local function S(x)  return math.Round(x * GetUIScale()) end
local function SX(x) return math.Round(x * GetUIScale()) end
local function SY(y) return math.Round(y * GetUIScale()) end

-- =========================
-- Constructor
-- =========================
function MW2_Header:New(cfg)
    local o = setmetatable({}, self)

    o.text       = cfg.text or ""
    o.subtext    = cfg.subtext or nil
    o.icon       = cfg.icon or nil

    o.color      = cfg.color or Color(255,255,255)
    o.subcolor   = cfg.subcolor or Color(255,255,255)
	
	o.subAlpha     = 255

    o.x          = cfg.x or 960
    o.y          = cfg.y or 205

    o.fonts      = cfg.fonts

    o.writeSpeed = cfg.writeSpeed or 16
    o.holdTime   = cfg.holdTime or 2
    o.eraseTime  = cfg.eraseTime or 0.7

    o.phase      = "write"
    o.startTime  = CurTime()

    o.written    = 0
    o.nextWrite  = CurTime()

    o.eraseBlanks = {}
    o.nextErase   = 0
	o.eraseSoundPlayed = nil
	o.fadeOutStart = nil
	o.skipErase = cfg.skipErase or false
	o.multiple = cfg.multiple or false
	o.persist = cfg.persist or false

	if cfg.endTime then
		o.endTime = CurTime() + cfg.endTime
	else
		o.endTime = nil
	end

	o.iconPos   = cfg.iconPos or "below" -- "above" | "below"
	
	o.iconX		= cfg.iconX or cfg.x
	o.iconY		= cfg.iconY or cfg.y
	o.iconSize  = cfg.iconSize or 128
	o.iconGap   = cfg.iconGap or 16
    o.iconAlpha   = 0
	o.iconFadeInSpeed = cfg.iconFadeInSpeed or 400
	o.iconFadeOutSpeed = cfg.iconFadeOutSpeed or 400
	
	o.teams = cfg.teams or nil
	o.scoreY = cfg.scoreY or (cfg.y + 100)

	o.scoreFonts = cfg.scoreFonts or {
		pri = "MW2_RE_Sc_Pri",
		sec = "MW2_RE_Sc_Sec",
		shd = "MW2_RE_Sc_Shd"
	}
	
    return o
end

function MW2_HeaderQueue.Push(cfg)
    table.insert(MW2_HeaderQueue.Queue, cfg)
end

-- =========================
-- Helpers
-- =========================
local function utf8_sub(str, startChar, endChar)
    local chars = {}
    local i = 1
    for _, c in utf8.codes(str) do
        chars[i] = utf8.char(c)
        i = i + 1
    end

    endChar = endChar or #chars

    local out = {}
    for i = startChar, math.min(endChar, #chars) do
        out[#out+1] = chars[i]
    end

    return table.concat(out)
end

local function BlankStep(blanks, text, n)
    local avail = {}
    for i = 1, utf8.len(text) do
        local used = false
        for _, b in ipairs(blanks) do
            if b == i then used = true break end
        end
        if not used then table.insert(avail, i) end
    end

    for i = 1, math.min(n, #avail) do
        local idx = math.random(#avail)
        table.insert(blanks, avail[idx])
        table.remove(avail, idx)
    end
end

local function ApplyBlanks(text, blanks)
    local chars = {}
    for i = 1, utf8.len(text) do
        chars[i] = utf8.sub(text, i, i)
    end

    for _, b in ipairs(blanks) do
        if chars[b] then chars[b] = " " end
    end

    return table.concat(chars)
end

local function DrawCODText(text, fullText, pri, sec, shd, x, y, glow)
    surface.SetFont(pri)
    local fullW = surface.GetTextSize(fullText)

    local startX = x - fullW / 2

    draw.SimpleText(text, sec, startX + 4, y + 0, glow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, sec, startX - 4, y - 0, glow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, shd, startX + 2, y + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, pri, startX,     y,     Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local RE_MATS = {}
local function GetSpawnMat(id)
    if RE_MATS[id] then return RE_MATS[id] end
    if not MW2Factions or not MW2Factions[id] then return nil end
    RE_MATS[id] = Material(MW2Factions[id].spawnIcon, "smooth")
    return RE_MATS[id]
end

local function GetSafeColor(col)
    if not col then return Color(255, 255, 255, 255) end
    return Color(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
end

-- =========================
-- Update
-- =========================
function MW2_Header:Update()
    local now = CurTime()

    local speed = self.iconFadeInSpeed or 400


    -- WRITE
    if self.phase == "write" then
        local interval = 1 / self.writeSpeed
		
		self.iconAlpha = math.min(255, self.iconAlpha + FrameTime() * speed)
		self.subAlpha  = math.min(255, self.subAlpha  + FrameTime() * speed)

        if now >= self.nextWrite and self.written < utf8.len(self.text) then
            self.written = self.written + 1
            self.nextWrite = now + interval
            surface.PlaySound("hud/cod_write.mp3")
        end

        if self.written >= utf8.len(self.text) then
            self.phase = "hold"
            self.holdStart = now
        end
    end

    -- HOLD
	if self.phase == "hold" then
	
		self.iconAlpha = math.min(255, self.iconAlpha + FrameTime() * speed)
		self.subAlpha  = math.min(255, self.subAlpha  + FrameTime() * speed)
		
		if self.persist then
			if self.endTime and CurTime() >= self.endTime then
				self.phase = "done"
				self.iconAlpha = 0
				self.subAlpha = 0
				return
			end
			return
		end

		if now >= self.holdStart + self.holdTime then
			self.phase = "erase"
			self.nextErase = now
		end
	end

    -- ERASE
	if self.phase == "erase" then
		self.iconAlpha = math.max(0, self.iconAlpha - FrameTime() * self.iconFadeOutSpeed)
		self.subAlpha  = math.max(0, self.subAlpha  - FrameTime() * self.iconFadeOutSpeed)
		
		if self.skipErase then
			-- Skip erase entirely
			self.phase = "done"
			return
		end

		local step = self.eraseTime / math.max(1, math.ceil(utf8.len(self.text) / 1))

		if now >= self.nextErase then
			self.nextErase = now + step
			BlankStep(self.eraseBlanks, self.text, 2)

			if not self.eraseSoundPlayed then
				surface.PlaySound("hud/cod_dissapear.mp3")
				self.eraseSoundPlayed = true
			end
		end

		if (#self.eraseBlanks >= utf8.len(self.text)) and (self.iconAlpha == 0) and (self.subAlpha == 0) then
			self.phase = "done"
		end

		if not self.fadeOutStart then
			self.fadeOutStart = now
		end
	end
end

-- =========================
-- Draw
-- =========================
function MW2_Header:Draw()
    if self.phase == "done" then return end
	
	local outlined = GetConVar("mw2_enable_outlinedtext"):GetBool()

    local display

    if self.phase == "write" then
        display = utf8_sub(self.text, 0, self.written)

        if self.written < utf8.len(self.text) then
            display = display .. GLITCH[math.random(#GLITCH)]
        end

    elseif self.phase == "erase" then
        display = ApplyBlanks(self.text, self.eraseBlanks)
    else
        display = self.text
    end

    if display ~= "" then
        DrawCODText( display, self.text, self.fonts.pri, self.fonts.sec, self.fonts.shd, self.x, self.y, self.color )
    end

    -- SUBTEXT
	if self.subtext ~= "" and self.subAlpha > 0 then
		local col = Color(self.subcolor.r, self.subcolor.g, self.subcolor.b, self.subAlpha)
		local lines = string.Split(self.subtext, "\n")

		for i, line in ipairs(lines) do
			draw.SimpleTextOutlined( line, self.fonts.sub, self.x, self.y + S(25) + (i - 1) * S(24), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outlined and 1 or 0, Color(0,0,0,col.a) )
		end
	end

    -- ICON
	if self.icon then
		local size = self.iconSize
		local yOffset = 999

		surface.SetFont(self.fonts.pri)
		local _, textH = surface.GetTextSize(self.text)

		local padding = 10
		local size = self.iconSize

		local yOffset

		if self.iconPos == "above" then
			yOffset = -(textH * 0.5) - size - self.iconGap - padding
		else
			yOffset = (textH * 0.5) + self.iconGap + padding
		end

		surface.SetMaterial(self.icon)
		surface.SetDrawColor(255,255,255,self.iconAlpha)
		surface.DrawTexturedRect(self.iconX - (size/2), self.iconY, size, size)
	end
	
	-- TEAMS
	if self.teams then
		local count = #self.teams
		if count <= 0 then return end

		local lp = LocalPlayer()
		local localFac = lp:GetNW2String("MW2_Faction", "rangers")

		local size = self.iconSize or 128
		local gap  = self.iconGap or 80

		-- =========================================================
		-- 1. DO NOT trust upstream ordering → normalize safely
		-- =========================================================
		local ordered = {}

		for _, t in ipairs(self.teams) do
			table.insert(ordered, t)
		end

		-- local faction always first (stable, non-destructive)
		table.sort(ordered, function(a, b)
			if a.fac == localFac then return true end
			if b.fac == localFac then return false end

			-- fallback: preserve score ordering if present
			return (a.score or 0) > (b.score or 0)
		end)

		-- =========================================================
		-- 2. Stable spacing model (no runaway gaps)
		-- =========================================================
		local step = size + gap

		-- slight compression only when needed (prevents overlap in 3+ teams)
		local compression = 1
		if count == 3 then
			compression = 0.9
		elseif count >= 4 then
			compression = 0.78
		end

		step = step * compression

		local totalW = (count - 1) * step

		-- =========================================================
		-- 3. Render (strict horizontal chain, no drift)
		-- =========================================================
		for i, t in ipairs(ordered) do
			local x = self.x + ((i - 1) * step - totalW / 2)
			local y = self.iconY or self.y

			local mat = GetSpawnMat(t.fac)
			if mat then
				surface.SetMaterial(mat)
				surface.SetDrawColor(255, 255, 255, self.iconAlpha or 255)
				surface.DrawTexturedRect(x - size/2, y, size, size)
			end

			local fd = MW2Factions and MW2Factions[t.fac]

			local score = t.score or 0

			if fd then
				DrawCODText(
					tostring(score),
					tostring(score),
					self.scoreFonts.pri,
					self.scoreFonts.sec,
					self.scoreFonts.shd,
					x,
					self.scoreY,
					GetSafeColor(fd.glow)
				)
			end
		end
	end

end

function MW2_Header:IsDone()
    return self.phase == "done"
end

function MW2_HeaderQueue.IsBusy()
    if not MW2_HeaderQueue.Active then return false end

    for _, h in ipairs(MW2_HeaderQueue.Active) do
        if not h:IsDone() then
            return true
        end
    end

    return false
end

function MW2_HeaderQueue.Think()

    -- spawn next queued header if allowed
	if #MW2_HeaderQueue.Queue > 0 then
		local cfg = table.remove(MW2_HeaderQueue.Queue, 1)
		local new = MW2_Header:New(cfg)

		if cfg.multiple then
			table.insert(MW2_HeaderQueue.Active, new)
		else
			-- non-multiple blocks until done
			if #MW2_HeaderQueue.Active == 0 then
				table.insert(MW2_HeaderQueue.Active, new)
			else
				-- requeue if blocked
				table.insert(MW2_HeaderQueue.Queue, 1, cfg)
			end
		end
	end

    -- update all active headers
    for i = #MW2_HeaderQueue.Active, 1, -1 do
        local h = MW2_HeaderQueue.Active[i]

        h:Update()

        if h:IsDone() then
            table.remove(MW2_HeaderQueue.Active, i)
        end
    end
end

hook.Add("Think", "MW2_HeaderQueueThink", function()
    MW2_HeaderQueue.Think()
end)

-- hook.Add("HUDPaint", "MW2_Header_Draw", function()
    -- if not GetConVar("cl_drawhud"):GetBool() then return end
    -- if _G.MW2_MedalsActive then return end

    -- if not MW2_HeaderQueue.Active then return end

    -- for _, h in ipairs(MW2_HeaderQueue.Active) do
        -- h:Draw()
    -- end
-- end)

local function MW2_ShouldHideHUD()
    if gui.IsGameUIVisible() then return true end
    if gui.IsConsoleVisible() then return true end
    if vgui.CursorVisible() then return true end
    if IsValid(ScoreBoard) then return true end -- fallback safety
    if MW2_ScoreboardOpened then return true end -- fallback safety
    return false
end

hook.Add("DrawOverlay", "MW2_Header_Draw", function()
    if not GetConVar("cl_drawhud"):GetBool() then return end
    if _G.MW2_MedalSystem and _G.MW2_MedalSystem.IsBusy() then return end
    if MW2_ShouldHideHUD() then return end

    if not MW2_HeaderQueue.Active then return end

    for _, h in ipairs(MW2_HeaderQueue.Active) do
        h:Draw()
    end
	
end)