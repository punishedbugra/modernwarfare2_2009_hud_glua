-- [[ cl_mw2_settings.lua ]]
-- [[ FACTION CONFIGURATION ]]
local factionOrder = {
    "rangers", "taskforce141", "seals",
    "ussr", "arab", "militia"
}

-- [[ CLIENT CONVARS ]]
CreateClientConVar("mw2_enable_announcer", "1", true, false, "Enable or disable the MW2 announcer voices.")
CreateClientConVar("mw2_enable_music", "1", true, false, "Enable or disable the MW2 end-game music.")
CreateClientConVar("mw2_enable_medals", "1", true, false, "Enable or disable Kill Medals.")
CreateClientConVar("mw2_enable_minimap", "1", true, false, "Enable or disable the Minimap.")
CreateClientConVar("mw2_enable_medal_outlines", "0", true, false, "Enable or disable Kill Medal text outlines.")
CreateClientConVar("mw2_enable_scorebar", "1", true, false, "Enable or disable the Scorebar.")
CreateClientConVar("mw2_enable_hitmarker", "1", true, false, "Enable or disable the Hitmarker.")
CreateClientConVar("mw2_enable_xp", "1", true, false, "Enable or disable XP text.")
CreateClientConVar("mw2_enable_killfeed", "1", true, false, "Enable or disable the Kill Feed.")
CreateClientConVar("mw2_enable_weaponinfo", "1", true, false, "Enable or disable the Weapon Info and Compass.")

-- [[ MENU POPULATION ]]
local function AddCheckBoxWithTooltip(panel, label, convar, desc)
    local cb = panel:CheckBox(label, convar)

    if desc then
        cb:SetTooltip(language.GetPhrase(desc))
    end

    return cb
end

hook.Add("PopulateToolMenu", "MW2_SettingsMenu", function()

    spawnmenu.AddToolMenuOption("Options", "MW2", "MW2_ClientSettings", "#MW2HUD.Enable.Options", "", "", function(panel)
        panel:ClearControls()
        panel:Help("#MW2HUD.Client")
		
        panel:Help("#MW2HUD.Faction.Select")
        local grid = vgui.Create("DGrid", panel)
        grid:SetCols(3)
        grid:SetColWide(92)
        grid:SetRowHeight(92)
        
        for _, id in ipairs(factionOrder) do
            local faction = MW2Factions[id]
            if not faction then continue end

            local btn = vgui.Create("DImageButton")
            btn:SetSize(80, 80)
            btn:SetImage(faction.spawnIcon)
            btn:SetToolTip(language.GetPhrase(faction.name) or id:upper())
            btn.PaintOver = function(self, w, h)
                local current = LocalPlayer():GetNW2String("MW2_Faction", "rangers")
                if current == id then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)

                    surface.SetDrawColor(255, 255, 255, 40)
                    surface.DrawRect(0, 0, w, h)
                end
            end
            btn.DoClick = function()
                RunConsoleCommand("set_faction", id)
                surface.PlaySound("ui/buttonclick.wav")
            end
            grid:AddItem(btn)
        end

        panel:AddItem(grid)
		
		-- Audio Toggles
		panel:Help("#MW2HUD.Audio")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Audio.Announcer", "mw2_enable_announcer", "MW2HUD.Audio.Announcer.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Audio.Music", "mw2_enable_music", "MW2HUD.Audio.Music.desc")

		-- HUD Elements
		panel:Help("") -- Spacer
		
		panel:Help("#MW2HUD.Enable.Options")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Score", "mw2_enable_scorebar", "MW2HUD.Enable.Score.tip")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Weapon", "mw2_enable_weaponinfo", "MW2HUD.Enable.Weapon.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Splash", "mw2_enable_medals", "MW2HUD.Enable.Splash.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Splash.Outline", "mw2_enable_medal_outlines", "MW2HUD.Enable.Splash.Outline.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Feed", "mw2_enable_killfeed", "MW2HUD.Enable.Feed.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Map", "mw2_enable_minimap", "MW2HUD.Enable.Map.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Hitmarker", "mw2_enable_hitmarker", "MW2HUD.Enable.Hitmarker.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.XP", "mw2_enable_xp", "MW2HUD.Enable.XP.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.Target", "mw2_targetid_label", "MW2HUD.Enable.Target.desc")
		AddCheckBoxWithTooltip(panel, "#MW2HUD.Enable.DeathIcon", "mw2_targetid_death_icon", "MW2HUD.Enable.DeathIcon.desc")
		
		panel:Help("") -- Spacer
		
        -- Admin-only Score Limit Slider
        if LocalPlayer():IsAdmin() then
		
			panel:Help("#MW2HUD.Server")
			
            local scoreSlider = panel:NumSlider("#MW2HUD.Admin.Score", "mw2_score_limit", 100, 7500, 0)

            panel:ControlHelp("#MW2HUD.Admin.Score.desc")
            scoreSlider.OnValueChanged = function(self, val)
                local snapped = math.Round(val / 100) * 100
                if snapped ~= val then
                    self:SetValue(snapped)
                end
            end
        end
    end)

end)