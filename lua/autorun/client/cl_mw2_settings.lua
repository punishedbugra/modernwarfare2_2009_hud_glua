-- [[ cl_mw2_settings.lua ]]
-- [[ FACTION CONFIGURATION ]]
local factionOrder = {
    "rangers", "taskforce141", "seals",
    "ussr", "arab", "militia"
}

-- [[ CLIENT CONVARS ]]
CreateClientConVar("mw2_quickdisable_hud", "0", true, false, "Quickly disable all MW2 HUD options.")
CreateClientConVar("mw2_quickdisable_audio", "0", true, false, "Quickly disable all MW2 Audio options.")

CreateClientConVar("mw2_enable_announcer", "1", true, false, "Enable or disable the MW2 announcer voices.")
CreateClientConVar("mw2_enable_music", "1", true, false, "Enable or disable the MW2 end-game music.")
CreateClientConVar("mw2_enable_medals", "1", true, false, "Enable or disable Kill Medals.")
CreateClientConVar("mw2_enable_minimap", "1", true, false, "Enable or disable the Minimap.")
CreateClientConVar("mw2_enable_medal_outlines", "0", true, false, "Enable or disable Kill Medal text outlines.")
CreateClientConVar("mw2_enable_medal_faster", "0", true, false, "Enable or disable Kill Medals moving by faster if there's many queued up at once.")
CreateClientConVar("mw2_enable_scorebar", "1", true, false, "Enable or disable the Scorebar.")
CreateClientConVar("mw2_enable_hitmarker", "1", true, false, "Enable or disable the Hitmarker.")
CreateClientConVar("mw2_enable_xp", "1", true, false, "Enable or disable XP text.")
CreateClientConVar("mw2_enable_killfeed", "1", true, false, "Enable or disable the Kill Feed.")
CreateClientConVar("mw2_enable_weaponinfo", "1", true, false, "Enable or disable the Weapon Info and Compass.")
CreateClientConVar("mw2_suspense_enabled", "1", true, false, "Enable or disable the ambient music.")
CreateClientConVar("mw2_enable_prompts", "1", true, false, "Enable or disable Weapon Prompts.")
CreateClientConVar("mw2_enable_chat", "1", true, false, "Enable or disable the Chat.")
CreateClientConVar("mw2_enable_challenges", "1", true, false, "Enable or disable the Challenge prompts.")
CreateClientConVar("mw2_enable_scoreboard", "1", true, false, "Enable or disable the Scoreboard.")

CreateClientConVar("mw2_enable_outlinedtext", "0", true, false, "Enable or disable outlines on certain HUD texts.")

CreateClientConVar("mw2hud_fullscreen", "0", true, false, "MW2 HUD Settings open in fullscreen.")

-- [[ MENU POPULATION ]] -- Only done to present button to open proper menu
hook.Add("PopulateToolMenu", "MW2_SettingsMenu", function()

    spawnmenu.AddToolMenuOption("Options", "MW2HUD.Title", "MW2_ClientSettings", "#MW2HUD.Title", "", "", function(panel)
        panel:ClearControls()
		panel:Button("Open MW2 Menu", "mw2hud_openmenu")
    end)

end)

local mw2_menu_frame = nil
local rs_confirm = nil

local function MW2_RS_OpenConfirm()
    if IsValid(rs_confirm) then rs_confirm:Remove() end
	
	local fs = GetConVar("mw2hud_fullscreen"):GetBool()
	local menusize = fs and 1 or 0.45
	
    -- hide main menu while confirm is open
    if IsValid(mw2_menu_frame) then
        mw2_menu_frame:SetVisible(false)
    end

    rs_confirm = vgui.Create("DFrame")
    rs_confirm:SetSize(ScrW() * menusize, ScrH() * menusize)
    rs_confirm:Center()
    rs_confirm:SetTitle("#MW2HUD.Title")
    rs_confirm:MakePopup()

	if fs then
		rs_confirm:SetDraggable(false)
		rs_confirm:ShowCloseButton(false)
	end

    rs_confirm.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100,100,100))

        surface.SetDrawColor(255, 255, 255, 125)
        surface.SetMaterial(Material("mw2menu/menu_anim"))
        surface.DrawTexturedRect(0, 0, w, h)
		
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Material("mw2menu/menu_bg"))
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
    lbl:SetText("#MW2HUD.RoundStart.Notice")
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
    btn_nah:SetText("#MW2HUD.RoundStart.No")

    btn_nah.DoClick = function()
        rs_confirm:Remove()

        if IsValid(mw2_menu_frame) then
            mw2_menu_frame:SetVisible(true)
            mw2_menu_frame:MakePopup()
        end
    end

    -- RIGHT button (YES)
    local btn_go = vgui.Create("DButton", bottom)
    btn_go:Dock(RIGHT)
    btn_go:SetWide(150)
    btn_go:SetText("#MW2HUD.RoundStart.Yes")

    btn_go.DoClick = function()
        rs_confirm:Remove()

        if IsValid(mw2_menu_frame) then
            mw2_menu_frame:SetVisible(false)
        end

        net.Start("MW2_StartRound")
        net.SendToServer()
    end
end

local MW2_SETTINGS = {
	{ name = "#MW2HUD.Client", subtabs = {
			{ name = "#MW2HUD.Faction.Select", categories = {
				{ name = "#MW2HUD.Faction.Select", type = "factions" } }
			},

			{ name = "#MW2HUD.Audio", categories = {
					{ name = "#MW2HUD.Audio", controls = {
							{ type = "checkbox", label = "#MW2HUD.Audio.Announcer", convar = "mw2_enable_announcer", tooltip = "#MW2HUD.Audio.Announcer.desc" },
							{ type = "checkbox", label = "#MW2HUD.Audio.Music", convar = "mw2_enable_music", tooltip = "#MW2HUD.Audio.Music.desc" },
							{ type = "checkbox", label = "#MW2HUD.Audio.Ambient", convar = "mw2_suspense_enabled", tooltip = "#MW2HUD.Audio.Ambient.desc" },
						}
					}
				}
			},

			{ name = "#MW2HUD.Enable.Options", categories = {
					-- { name = "#MW2HUD.Enable.Options", children = {
							-- { name = "#MW2HUD.Enable.Score", controls = {
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Outline",		convar = "mw2_enable_outlinedtext",		tooltip = "MW2HUD.Enable.Outline.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Score",			convar = "mw2_enable_scorebar",			tooltip = "MW2HUD.Enable.Score.tip" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Weapon",		convar = "mw2_enable_weaponinfo",		tooltip = "MW2HUD.Enable.Weapon.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Splash",		convar = "mw2_enable_medals",			tooltip = "MW2HUD.Enable.Splash.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Splash",		convar = "mw2_enable_medal_outlines",	tooltip = "MW2HUD.Enable.Splash.Outline.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Feed",			convar = "mw2_enable_killfeed",			tooltip = "MW2HUD.Enable.Feed.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Map",			convar = "mw2_enable_minimap",			tooltip = "MW2HUD.Enable.Map.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Hitmarker",		convar = "mw2_enable_hitmarker",		tooltip = "MW2HUD.Enable.Hitmarker.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.XP",			convar = "mw2_enable_xp",				tooltip = "MW2HUD.Enable.XP.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Target",		convar = "mw2_targetid_label",			tooltip = "MW2HUD.Enable.Target.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.DeathIcon",		convar = "mw2_targetid_death_icon",		tooltip = "MW2HUD.Enable.DeathIcon.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Prompt",		convar = "mw2_enable_prompts",			tooltip = "MW2HUD.Enable.Prompt.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Chat",			convar = "mw2_enable_chat",				tooltip = "MW2HUD.Enable.Chat.desc" },
									-- { type = "checkbox",	label = "#MW2HUD.Enable.Challenges",	convar = "mw2_enable_challenges",		tooltip = "MW2HUD.Enable.Challenges.desc" },
								-- }
							-- }
						-- },
					-- },
					{ name = "#MW2HUD.DisableAll.Title", controls = {
							{ type = "checkbox",	label = "#MW2HUD.DisableAll.HUD",			convar = "mw2_quickdisable_hud",		tooltip = "MW2HUD.DisableAll.HUD.desc" },
						}
					},
					{ name = "#MW2HUD.Enable.Options", controls = {
							{ type = "checkbox",	label = "#MW2HUD.Enable.Outline",			convar = "mw2_enable_outlinedtext",		tooltip = "MW2HUD.Enable.Outline.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Score",				convar = "mw2_enable_scorebar",			tooltip = "MW2HUD.Enable.Score.tip" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Weapon",			convar = "mw2_enable_weaponinfo",		tooltip = "MW2HUD.Enable.Weapon.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Splash",			convar = "mw2_enable_medals",			tooltip = "MW2HUD.Enable.Splash.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Splash.Outline",	convar = "mw2_enable_medal_outlines",	tooltip = "MW2HUD.Enable.Splash.Outline.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Splash.Speedup",	convar = "mw2_enable_medal_faster",		tooltip = "MW2HUD.Enable.Splash.Speedup.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Feed",				convar = "mw2_enable_killfeed",			tooltip = "MW2HUD.Enable.Feed.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Map",				convar = "mw2_enable_minimap",			tooltip = "MW2HUD.Enable.Map.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Hitmarker",			convar = "mw2_enable_hitmarker",		tooltip = "MW2HUD.Enable.Hitmarker.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.XP",				convar = "mw2_enable_xp",				tooltip = "MW2HUD.Enable.XP.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Target",			convar = "mw2_targetid_label",			tooltip = "MW2HUD.Enable.Target.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.DeathIcon",			convar = "mw2_targetid_death_icon",		tooltip = "MW2HUD.Enable.DeathIcon.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Prompt",			convar = "mw2_enable_prompts",			tooltip = "MW2HUD.Enable.Prompt.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Chat",				convar = "mw2_enable_chat",				tooltip = "MW2HUD.Enable.Chat.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Challenges",		convar = "mw2_enable_challenges",		tooltip = "MW2HUD.Enable.Challenges.desc" },
							{ type = "checkbox",	label = "#MW2HUD.Enable.Scoreboard",		convar = "mw2_enable_scoreboard",		tooltip = "MW2HUD.Enable.Scoreboard.desc" },
						}
					},
				}
			},
			{ name = "#MW2HUD.Menu", categories = {
					{ name = "#MW2HUD.Menu", controls = {
							{ type = "checkbox",	label = "#MW2HUD.Menu.Fullscreen",			convar = "mw2hud_fullscreen",		tooltip = "MW2HUD.Menu.Fullscreen.desc" },
						}
					},
				}
			},
		}
	},

    { name = "#MW2HUD.Server", subtabs = {
            { name = "#MW2HUD.Admin", categories = {
                    { name = "#MW2HUD.Admin", adminOnly = true, controls = {
                            { type = "checkbox", label = "#MW2HUD.Admin.EndScreen", convar = "mw2_enable_roundend", tooltip = "MW2HUD.Admin.EndScreen.desc" },
                            { type = "checkbox", label = "#MW2HUD.Admin.EndScreen.StartNext", convar = "mw2_enable_roundend_startnext", tooltip = "MW2HUD.Admin.EndScreen.StartNext.desc" },
							{ type = "checkbox", label = "#MW2HUD.Admin.FriendlyFire", convar = "mw2_friendly_fire", tooltip = "MW2HUD.Admin.FriendlyFire.desc" },
                            { type = "slider", label = "#MW2HUD.Admin.Score", convar = "mw2_score_limit", min = 100, max = 7500 }
                        }
                    }
                }
            },
			{ name = "#MW2HUD.RoundStart", categories = {
				{ name = "#MW2HUD.RoundStart", adminOnly = true, controls = {
						{ type = "combobox", label = "#MW2HUD.RoundStart.Gamemode", choices = {
								{ "#MW2_MPUI_WAR", "war" },
								{ "#MW2_MPUI_DEATHMATCH", "dm" },
								{ "#MW2_MPUI_DOMINATION", "dom" },
								{ "#MW2_MPUI_SEARCH_AND_DESTROY", "sd" },
								{ "#MW2_MPUI_SABOTAGE", "sab" },
								{ "#MW2_MPUI_CAPTURE_THE_FLAG", "ctf" },
								{ "#MW2_MPUI_HEADQUARTERS", "hq" },
								{ "#MW2_MPUI_ONE_FLAG", "oneflag" },
								{ "#MW2_MPUI_ARENA", "arena" },
								{ "#MW2_MPUI_DD", "dd" },
								{ "#MW2_MPUI_GTNW", "gtnw" },
							},
							getCurrent = function() return GetConVar("mw2_selected_gamemode"):GetString() end,

							onSelect = function(_, data)
								net.Start("MW2_SetGamemode")
								net.WriteString(data)
								net.SendToServer()
							end
						},
							{ type = "button", label = "#MW2HUD.RoundStart.Start", func = function()
								local lp = LocalPlayer()
								if not IsValid(lp) or not lp:IsAdmin() then return end

								MW2_RS_OpenConfirm()

								if IsValid(mw2_menu_frame) then
									mw2_menu_frame:SetVisible(false)
								end
								
								-- local gm = GetConVar("mw2_selected_gamemode"):GetString()

								-- net.Start("MW2_StartRound")
								-- net.SendToServer()
							end}
					}
				}
			}}
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
        local snapped = math.Round(val / 100) * 100
        if snapped ~= val then
            self:SetValue(snapped)
        end
    end
end

local function CreateComboBox(parent, data)
    local combo = vgui.Create("DComboBox", parent)
    combo:SetText(data.label)
    combo:Dock(TOP)
    combo:DockMargin(5, 2, 5, 2)
    combo:SetValue(language.GetPhrase(data.label))

    for _, choice in ipairs(data.choices or {}) do
        combo:AddChoice(language.GetPhrase(choice[1]), choice[2])
    end

    -- Set default
    if data.getCurrent then
        local current = data.getCurrent()
        for _, choice in ipairs(data.choices or {}) do
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

        for _, id in ipairs(factionOrder) do
            local faction = MW2Factions[id]
            if not faction then continue end

            local btn = vgui.Create("DImageButton")
            btn:SetSize(64, 64)
            btn:SetImage(faction.scoreIcon)
            btn:SetToolTip(language.GetPhrase(faction.name) or id:upper())

            btn.DoClick = function()
                RunConsoleCommand("set_faction", id)
                surface.PlaySound("ui/buttonclick.wav")
            end

			btn.PaintOver = function(self, w, h)
				local current = LocalPlayer():GetNW2String("MW2_Faction", "rangers")

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
		helper:SetText("#MW2HUD.Faction.Select.desc")
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
        title = "#MW2HUD.Title",
        icon  = "factions/faction_128_taskforce141.png",
        init = function(icon, window)
			RunConsoleCommand("mw2hud_openmenu")
        end
    })
end

concommand.Add("mw2hud_openmenu", function()
	local fs = GetConVar("mw2hud_fullscreen"):GetBool()
	local menusize = fs and 1 or 0.45
	
	mw2_menu_frame = vgui.Create("DFrame")
	local frame = mw2_menu_frame
	frame:SetSize(ScrW() * menusize, ScrH() * menusize)
	frame:Center()
	frame:SetTitle("#MW2HUD.Title")
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
			if IsValid(mw2_menu_frame) then
				mw2_menu_frame:Close()
			end
		end
	end

	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(100,100,100))
		
		surface.SetDrawColor(255, 255, 255, 125)
		surface.SetMaterial( Material("mw2menu/menu_anim") )
		surface.DrawTexturedRect(0, 0, w, h)
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial( Material("mw2menu/menu_bg") )
		surface.DrawTexturedRect(0, 0, w, h)

    end

	local sheet = vgui.Create("DPropertySheet", frame)
	sheet:Dock(FILL)
	sheet.Paint = nil

	for _, tab in ipairs(MW2_SETTINGS) do
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