---- [ SETTINGS FILE ] ----

-- [[ CLIENT CONVARS ]]
CreateClientConVar("codhud_quickdisable_hud", "0", true, false, "Quickly disable all HUD options.")
CreateClientConVar("codhud_quickdisable_audio", "0", true, false, "Quickly disable all Audio options.")

CreateClientConVar("codhud_enable_announcer", "1", true, false, "Enable or disable the announcer voices.")
CreateClientConVar("codhud_enable_announcer_english", "0", true, false, "Force the announcer voice to use English ones, regardless of language.")
CreateClientConVar("codhud_enable_music", "1", true, false, "Enable or disable the end-game music.")
CreateClientConVar("codhud_enable_suspense", "1", true, false, "Enable or disable the ambient music.")

CreateClientConVar("codhud_enable_medals", "1", true, false, "Enable or disable Kill Medals.")
CreateClientConVar("codhud_enable_minimap", "1", true, false, "Enable or disable the Minimap.")
CreateClientConVar("codhud_enable_medal_faster", "0", true, false, "Enable or disable Kill Medals moving by faster if there's many queued up at once.")
CreateClientConVar("codhud_enable_scorebar", "1", true, false, "Enable or disable the Scorebar.")
CreateClientConVar("codhud_enable_hitmarker", "1", true, false, "Enable or disable the Hitmarker.")
CreateClientConVar("codhud_enable_xp", "1", true, false, "Enable or disable XP text.")
CreateClientConVar("codhud_enable_killfeed", "1", true, false, "Enable or disable the Kill Feed.")
CreateClientConVar("codhud_enable_weaponinfo", "1", true, false, "Enable or disable the Weapon Info and Compass.")
CreateClientConVar("codhud_enable_prompts", "1", true, false, "Enable or disable Weapon Prompts.")
CreateClientConVar("codhud_enable_chat", "1", true, false, "Enable or disable the Chat.")
CreateClientConVar("codhud_enable_challenges", "1", true, false, "Enable or disable the Challenge prompts.")
CreateClientConVar("codhud_enable_scoreboard", "1", true, false, "Enable or disable the Scoreboard.")

CreateClientConVar("codhud_enable_iff", "1", true, false, "Enable/Disable target identification labels")
CreateClientConVar("codhud_enable_deathicon", "1", true, false, "Show death icon when a friendly dies")

CreateClientConVar("codhud_enable_outlinedtext", "0", true, false, "Enable or disable outlines on certain HUD texts.")

CreateClientConVar("codhud_fullscreen", "0", true, false, "MW2 HUD Settings open in fullscreen.")

-- [[ MENU POPULATION ]] -- Only done to present button to open proper menu
hook.Add("PopulateToolMenu", "CoDHUD_SETTINGSMenu", function()

    spawnmenu.AddToolMenuOption("Options", "CoDHUD.Title", "MW2_ClientSettings", "#CoDHUD.Title", "", "", function(panel)
        panel:ClearControls()
		panel:Button("Open CoD HUD Menu", "codhud_openmenu")
    end)

end)

local codhud_menu_frame = nil
local rs_confirm = nil

local function CoDHUD_RS_OpenConfirm()
    if IsValid(rs_confirm) then rs_confirm:Remove() end
	
	local fs = GetConVar("codhud_fullscreen"):GetBool()
	local menusize = fs and 1 or 0.45
	
    -- hide main menu while confirm is open
    if IsValid(codhud_menu_frame) then
        codhud_menu_frame:SetVisible(false)
    end

    rs_confirm = vgui.Create("DFrame")
    rs_confirm:SetSize(ScrW() * menusize, ScrH() * menusize)
    rs_confirm:Center()
    rs_confirm:SetTitle("#CoDHUD.Title")
    rs_confirm:MakePopup()

	if fs then
		rs_confirm:SetDraggable(false)
		rs_confirm:ShowCloseButton(false)
	end

    rs_confirm.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100,100,100))
		
		surface.SetDrawColor(255, 255, 255, 125)
		surface.SetMaterial( Material(CoDHUD_GetHUDType() .. "/menu_anim") )
		surface.DrawTexturedRect(0, 0, w, h)
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial( Material(CoDHUD_GetHUDType() .. "/menu_bg") )
		surface.DrawTexturedRect(0, 0, w, h)
    end

    -- main container (keeps everything aligned)
    local root = vgui.Create("DPanel", rs_confirm)
    root:Dock(FILL)
    root:DockMargin(20, 20, 20, 20)
    root.Paint = nil

    -- title / message
    local lbl = vgui.Create("DLabel", root)
    lbl:Dock(TOP)
    lbl:SetTall(300)
    lbl:SetText("#CoDHUD.RoundStart.Notice")
    lbl:SetFont("DermaLarge")
    lbl:SetContentAlignment(7)
    lbl:SetWrap(true)
	function lbl:PerformLayout()
		self:SetFGColor(Color(255,255,255))
	end

    -- spacer pushes buttons down
    local spacer = vgui.Create("DPanel", root)
    spacer:Dock(FILL)
    spacer.Paint = nil

    -- bottom button bar
    local bottom = vgui.Create("DPanel", root)
    bottom:Dock(BOTTOM)
    bottom:SetTall(50)
    bottom.Paint = nil

    -- LEFT button (NO)
    local btn_nah = vgui.Create("DButton", bottom)
    btn_nah:Dock(LEFT)
    btn_nah:SetWide(150)
    btn_nah:SetText("#CoDHUD.RoundStart.No")

    btn_nah.DoClick = function()
        rs_confirm:Remove()

        if IsValid(codhud_menu_frame) then
            codhud_menu_frame:SetVisible(true)
            codhud_menu_frame:MakePopup()
        end
    end

    -- RIGHT button (YES)
    local btn_go = vgui.Create("DButton", bottom)
    btn_go:Dock(RIGHT)
    btn_go:SetWide(150)
    btn_go:SetText("#CoDHUD.RoundStart.Yes")

    btn_go.DoClick = function()
        rs_confirm:Remove()

        if IsValid(codhud_menu_frame) then
            codhud_menu_frame:SetVisible(false)
        end

        net.Start("CoDHUD_StartRound")
        net.SendToServer()
    end
end

local CoDHUD_SETTINGS = {
	{ name = "#CoDHUD.Client", subtabs = {
			{ name = "#CoDHUD.Faction.Select", categories = {
				{ name = "#CoDHUD.Faction.Select", type = "factions" } }
			},

			{ name = "#CoDHUD.HUD", categories = {
					{ name = "#CoDHUD.Quick.title", controls = {
							{ type = "checkbox",	label = "#CoDHUD.Quick.DisableHUD",				convar = "codhud_quickdisable_hud",			tooltip = "CoDHUD.Quick.DisableHUD.desc" },
							{ type = "checkbox",	label = "#CoDHUD.HUD.Outline",					convar = "codhud_enable_outlinedtext",		tooltip = "CoDHUD.HUD.Outline.desc" }, -- TEMP
						}
					},
					{ name = "#CoDHUD.HUD.Scoreboard", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Scoreboard.Enable",		convar = "codhud_enable_scoreboard",		tooltip = "CoDHUD.HUD.Scoreboard.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Scorecounter", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Scorecounter.Enable",		convar = "codhud_enable_scorebar",			tooltip = "CoDHUD.HUD.Scorecounter.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Medals", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Medals.Enable",			convar = "codhud_enable_medals",			tooltip = "CoDHUD.HUD.Medals.Enable.desc" },
							{ type = "checkbox",	label = "#CoDHUD.HUD.Medals.Speedup",			convar = "codhud_enable_medal_faster",		tooltip = "CoDHUD.HUD.Medals.Speedup.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Killfeed", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Killfeed.Enable",		convar = "codhud_enable_killfeed",				tooltip = "CoDHUD.HUD.Killfeed.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Minimap", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Minimap.Enable",		convar = "codhud_enable_minimap",				tooltip = "CoDHUD.HUD.Minimap.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Hitmarker", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Hitmarker.Enable",		convar = "codhud_enable_hitmarker",				tooltip = "CoDHUD.HUD.Hitmarker.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.WeaponInfo", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.WeaponInfo.Enable",		convar = "codhud_enable_weaponinfo",		tooltip = "CoDHUD.HUD.WeaponInfo.Enable.desc" },
							{ type = "checkbox",	label = "#CoDHUD.HUD.WeaponPrompts.Enable",		convar = "codhud_enable_prompts",			tooltip = "CoDHUD.HUD.WeaponPrompts.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.XP", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.XP.Enable",		convar = "codhud_enable_xp",			tooltip = "CoDHUD.HUD.XP.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.IFF", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.IFF.Enable",		convar = "codhud_enable_iff",			tooltip = "CoDHUD.HUD.IFF.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.DeathIcon", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.DeathIcon.Enable",		convar = "codhud_enable_deathicon",			tooltip = "CoDHUD.HUD.DeathIcon.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Chat", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Chat.Enable",		convar = "codhud_enable_chat",			tooltip = "CoDHUD.HUD.Chat.Enable.desc" },
						}
					},
					{ name = "#CoDHUD.HUD.Challenges", controls = {
							{ type = "checkbox",	label = "#CoDHUD.HUD.Challenges.Enable",		convar = "codhud_enable_challenges",			tooltip = "CoDHUD.HUD.Challenges.Enable.desc" },
						}
					},
				}
			},
			
			{ name = "#CoDHUD.Audio", categories = {
					{ name = "#CoDHUD.Audio.Announcer", controls = {
							{ type = "checkbox", label = "#CoDHUD.Audio.Announcer.Enable", convar = "codhud_enable_announcer", tooltip = "#CoDHUD.Audio.Announcer.Enable.desc" },
							{ type = "checkbox", label = "#CoDHUD.Audio.Announcer.English", convar = "codhud_enable_announcer_english", tooltip = "#CoDHUD.Audio.Announcer.English.desc" },
						}
					},
					{ name = "#CoDHUD.Audio.Music", controls = {
							{ type = "checkbox", label = "#CoDHUD.Audio.Music.Enable",				convar = "codhud_enable_music", 			tooltip = "#CoDHUD.Audio.Music.Enable.desc" },
							{ type = "checkbox", label = "#CoDHUD.Audio.Music.Ambient",				convar = "codhud_enable_suspense", 			tooltip = "#CoDHUD.Audio.Music.Ambient.desc" },
						}
					},
				}
			},

			{ name = "#CoDHUD.MenuSettings", categories = {
					{ name = "#CoDHUD.MenuSettings", controls = {
							{ type = "checkbox",	label = "#CoDHUD.Menu.Fullscreen",			convar = "codhud_fullscreen",		tooltip = "CoDHUD.Menu.Fullscreen.desc" },
						}
					},
				}
			},
		}
	},

    { name = "#CoDHUD.Server", subtabs = {
            { name = "#CoDHUD.Server", categories = {
                    { name = "#CoDHUD.General", adminOnly = true, controls = {
                            { type = "checkbox", label = "#CoDHUD.Admin.EndScreen", convar = "codhud_enable_roundend", tooltip = "CoDHUD.Admin.EndScreen.desc" },
                            { type = "checkbox", label = "#CoDHUD.Admin.EndScreen.StartNext", convar = "codhud_enable_roundend_startnext", tooltip = "CoDHUD.Admin.EndScreen.StartNext.desc" },
							{ type = "checkbox", label = "#CoDHUD.Admin.FriendlyFire", convar = "codhud_friendly_fire", tooltip = "CoDHUD.Admin.FriendlyFire.desc" },
                            { type = "slider", label = "#CoDHUD.Admin.EndScreen.Scorelimit", convar = "codhud_score_limit", tooltip = "CoDHUD.Admin.EndScreen.Scorelimit.desc", min = 1, max = 150 },
                            { type = "slider", label = "#CoDHUD.RoundStart.Timer", convar = "codhud_matchstart_timer", tooltip = "CoDHUD.RoundStart.Timer.desc", min = 0, max = 15 },
                        }
                    },
					
					{ name = "#CoDHUD.RoundStart", adminOnly = true, controls = {
							
							{ type = "label", label = "#CoDHUD.RoundStart.Info" },
							{ type = "combobox", label = "#CoDHUD.RoundStart.Gamemode",
								choices = function() return CoDHUD.Gamemodes[CoDHUD_GetHUDType()] or {} end,
								getCurrent = function() return GetConVar("codhud_selected_gamemode"):GetString() end,
								onSelect = function(_, data)
									net.Start("CoDHUD_SetGamemode")
									net.WriteString(data)
									net.SendToServer()
								end
							},
							{ type = "button", label = "#CoDHUD.RoundStart.Start", 
								func = function()
									local lp = LocalPlayer()
									if not IsValid(lp) or not lp:IsAdmin() then return end

									CoDHUD_RS_OpenConfirm()

									if IsValid(codhud_menu_frame) then
										codhud_menu_frame:SetVisible(false)
									end
								end
							}
						}
					},
					
                    { name = "#CoDHUD.Admin.RestrictType", adminOnly = true, controls = {
                            { type = "combobox", label = "#CoDHUD.Admin.EndScreen.Scorelimit", choices = CoDHUD.GetHUDList(),
								getCurrent = function() return GetConVar("codhud_game"):GetString() end,

								onSelect = function(_, data)
									if IsValid(codhud_menu_frame) then
										codhud_menu_frame:Close()
									end

									net.Start("CoDHUD_SetGame")
									net.WriteString(data)
									net.SendToServer()

									timer.Simple(0, function()
										RunConsoleCommand("codhud_openmenu")
									end)
								end
							},
                            { type = "label", label = "#CoDHUD.Admin.RestrictType.desc" },
                        }
                    },
                }
            }
        }
    }
}

local function CreateCheckbox(parent, data)
    local cb = vgui.Create("DCheckBoxLabel", parent)
    cb:SetText(data.label)
    cb:SetConVar(data.convar)
	if data.tooltip then
        cb:SetTooltip(language.GetPhrase(data.tooltip))
    end
    cb:Dock(TOP)
    cb:DockMargin(5, 2, 5, 2)
    cb:SizeToContents()
end

local function CreateLabel(parent, data)
    local lbl = vgui.Create("DLabel", parent)
    lbl:SetText(language.GetPhrase(data.label))
    lbl:Dock(TOP)
    lbl:DockMargin(5, 2, 5, 2)
    lbl:SizeToContents()
    return lbl
end

local function CreateButton(parent, data)
    local button = vgui.Create("DButton", parent)
    button:SetText(data.label)
	button.DoClick = function(self)
		if data.func then data.func(self) end
	end
    button:Dock(TOP)
    button:DockMargin(5, 2, 5, 2)
    button:SizeToContents()
end

local function CreateSlider(parent, data)
    local slider = vgui.Create("DNumSlider", parent)
    slider:SetText(data.label)
    slider:SetMin(data.min)
    slider:SetMax(data.max)
    slider:SetDecimals(data.decimals or 0)
    slider:SetConVar(data.convar)
    slider:Dock(TOP)

    -- Snap example (optional)
    slider.OnValueChanged = function(self, val)
        -- local snapped = math.Round(val / 100) * 100
        -- if snapped ~= val then
            self:SetValue(val)
        -- end
    end
end

local function CreateComboBox(parent, data)
    local combo = vgui.Create("DComboBox", parent)
    combo:SetText(data.label)
    combo:Dock(TOP)
    combo:DockMargin(5, 2, 5, 2)

    local choices = data.choices
    if isfunction(choices) then
        choices = choices()
    end

    choices = choices or {}

    combo._choices = data.choices -- store raw (optional for refresh use)

    for _, choice in ipairs(choices) do
        combo:AddChoice(language.GetPhrase(choice[1]), choice[2])
    end

    if data.getCurrent then
        local current = data.getCurrent()
        for _, choice in ipairs(choices) do
            if choice[2] == current then
                combo:SetValue(language.GetPhrase(choice[1]))
                break
            end
        end
    end

    combo.OnSelect = function(_, _, text, dataVal)
        if data.onSelect then
            data.onSelect(text, dataVal)
        end
    end

    return combo
end

local function PopulateControls(panel, controls)
    for _, ctrl in ipairs(controls or {}) do
        if ctrl.type == "checkbox" then
            CreateCheckbox(panel, ctrl)
        elseif ctrl.type == "slider" then
            CreateSlider(panel, ctrl)
        elseif ctrl.type == "label" then
            CreateLabel(panel, ctrl)
        elseif ctrl.type == "button" then
            CreateButton(panel, ctrl)
		elseif ctrl.type == "combobox" then
			CreateComboBox(panel, ctrl)
        end
    end
end

local function CreateCategory(parent, data)
    if data.adminOnly and not LocalPlayer():IsAdmin() then return end

    local cat = vgui.Create("DCollapsibleCategory", parent)

    cat:SetLabel(data.name)
	
    cat:Dock(TOP)
    cat:DockMargin(5, 5, 5, 0)
	cat.Paint = nil
	
	cat.Header.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, (w * 0.33), h, Color(0, 0, 0))
	end
	
	-- cat.Paint = function(self, w, h)
		-- draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
	-- end

    local inner = vgui.Create("DPanel", cat)
    inner:Dock(TOP)
    inner:DockPadding(5, 5, 5, 5)		
	inner.Paint = nil
	
	-- inner.Paint = function(self, w, h)
		-- draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
	-- end

    cat:SetContents(inner)

    -- Special case: Factions
    if data.type == "factions" then
        local grid = vgui.Create("DGrid", inner)
        grid:SetCols(3)
        grid:SetColWide(64)
        grid:SetRowHeight(64)
        grid:Dock(TOP)

		local sorted = {}
		local factions = CoDHUD.Factions[CoDHUD_GetHUDType()] or {}

		for id, factionData in pairs(factions) do
			table.insert(sorted, {id = id, data = factionData})
		end

		table.sort(sorted, function(a, b)
			return (a.data.order or 0) < (b.data.order or 0)
		end)

		for _, entry in ipairs(sorted) do
			local id = entry.id
			local faction = entry.data

			local btn = vgui.Create("DImageButton")
			btn:SetSize(64, 64)
			if faction.scoreIcon then
				btn:SetImage(faction.scoreIcon)
			else
				print("[CoDHUD] Missing scoreIcon for faction:", id)
			end
            btn:SetToolTip(language.GetPhrase(faction.name) or id:upper())

            btn.DoClick = function()
                RunConsoleCommand("set_faction", id)
                surface.PlaySound("ui/buttonclick.wav")
            end

			btn.PaintOver = function(self, w, h)
				local current = LocalPlayer():GetNW2String("CoDHUD_Faction", "rangers")

				if current == id then
					-- Outer faint border
					surface.SetDrawColor(255, 255, 255, 60)
					surface.DrawOutlinedRect(0, 0, w, h, 4)

					-- Inner sharp border
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 2)
				end
			end

            grid:AddItem(btn)
        end
				
		local helper = vgui.Create("DLabel", inner)
		helper:SetText("#CoDHUD.Faction.Select.desc")
		helper:SetWrap(true)
		helper:SetAutoStretchVertical(true)
		helper:Dock(TOP)
		helper:DockMargin(5, 5, 5, 0)
		helper:SetContentAlignment(7) -- top-left

    end

    -- Controls
    PopulateControls(inner, data.controls)

    -- Children (nested categories)
    for _, child in ipairs(data.children or {}) do
        CreateCategory(inner, child)
    end
end

if CLIENT then
    list.Set("DesktopWindows", "CoDHUDMenu", {
        title = "#CoDHUD.Title",
        icon  = "factions/faction_128_taskforce141.png",
        init = function(icon, window)
			RunConsoleCommand("codhud_openmenu")
        end
    })
end

concommand.Add("codhud_openmenu", function()
	local fs = GetConVar("codhud_fullscreen"):GetBool()
	local menusize = fs and 1 or 0.45
	
	codhud_menu_frame = vgui.Create("DFrame")
	local frame = codhud_menu_frame
	frame:SetSize(ScrW() * menusize, ScrH() * menusize)
	frame:Center()
	frame:SetTitle("#CoDHUD.Title")
	frame:MakePopup()
	
	local closebtn
	
	if fs then
		frame:SetDraggable(false)
		frame:ShowCloseButton(false)
		
		-- Close Button (Fullscreen only)
		closebtn = vgui.Create("DButton", frame)
		closebtn:Dock(BOTTOM)
		closebtn:SetWide(150)
		closebtn:SetText("#close")

		closebtn.DoClick = function()
			if IsValid(codhud_menu_frame) then
				codhud_menu_frame:Close()
			end
		end
	end

	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(100,100,100))
		
		surface.SetDrawColor(255, 255, 255, 125)
		surface.SetMaterial( Material(CoDHUD_GetHUDType() .. "/menu_anim") )
		surface.DrawTexturedRect(0, 0, w, h)
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial( Material(CoDHUD_GetHUDType() .. "/menu_bg") )
		surface.DrawTexturedRect(0, 0, w, h)

    end

	local sheet = vgui.Create("DPropertySheet", frame)
	sheet:Dock(FILL)
	sheet.Paint = nil

	for _, tab in ipairs(CoDHUD_SETTINGS) do
		local tabPanel = vgui.Create("DPanel", sheet)
		tabPanel:Dock(FILL)
		tabPanel.Paint = nil

		local subSheet = vgui.Create("DPropertySheet", tabPanel)
		subSheet:Dock(FILL)
		subSheet.Paint = nil

		for _, subtab in ipairs(tab.subtabs or {}) do
			local subPanel = vgui.Create("DScrollPanel", subSheet)
			subPanel.Paint = nil

			for _, catData in ipairs(subtab.categories or {}) do
				CreateCategory(subPanel, catData)
			end

			subSheet:AddSheet(language.GetPhrase(subtab.name), subPanel)
		end

		sheet:AddSheet(language.GetPhrase(tab.name), tabPanel)
	end
end)