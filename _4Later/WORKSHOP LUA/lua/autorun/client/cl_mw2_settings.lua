-- [[ cl_mw2_settings.lua ]]
-- [[ FACTION CONFIGURATION ]]
local factionIcons = {
    ["rangers"]      = "factions/faction_128_rangers.png",
    ["taskforce141"] = "factions/faction_128_taskforce141.png",
    ["seals"]        = "factions/faction_128_seals.png",
    ["ussr"]         = "factions/faction_128_ussr.png",
    ["arab"]         = "factions/faction_128_arab.png",
    ["militia"]      = "factions/faction_128_militia.png"
}
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
-- [[ MENU POPULATION ]]
hook.Add("PopulateToolMenu", "MW2_SettingsMenu", function()
    spawnmenu.AddToolMenuOption("Options", "MW2", "MW2_ClientSettings", "Client", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Select Your Faction")
        local grid = vgui.Create("DGrid", panel)
        grid:SetCols(3)
        grid:SetColWide(92)
        grid:SetRowHeight(92)
        
        for _, id in ipairs(factionOrder) do
            local iconPath = factionIcons[id]
            
            local btn = vgui.Create("DImageButton")
            btn:SetSize(80, 80)
            btn:SetImage(iconPath)
            btn:SetToolTip(id:upper())
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
        panel:Help("Client Audio Settings")
        panel:CheckBox("Enable Announcer", "mw2_enable_announcer")
        panel:CheckBox("Enable Music", "mw2_enable_music")
        -- HUD Elements
        panel:Help("HUD Elements")
        panel:CheckBox("Enable Scorebar", "mw2_enable_scorebar")
        panel:ControlHelp("Recommended to disable Announcer and Music with it")
        panel:CheckBox("Enable Kill Medals", "mw2_enable_medals")
        panel:CheckBox("Enable Kill Feed", "mw2_enable_killfeed")
        panel:CheckBox("Enable Minimap", "mw2_enable_minimap")
        panel:CheckBox("Enable Hitmarker", "mw2_enable_hitmarker")
        panel:CheckBox("Enable XP", "mw2_enable_xp")
		panel:CheckBox("Enable Target ID", "mw2_targetid_label")
		panel:CheckBox("Enable Death Icon", "mw2_targetid_death_icon")
        -- Admin-only Score Limit Slider
        if LocalPlayer():IsAdmin() then
            
            local scoreSlider = panel:NumSlider("Score Limit", "mw2_score_limit", 100, 7500, 0)
                    
            panel:ControlHelp("Admin Only: Sets the score limit for all players.")
            scoreSlider.OnValueChanged = function(self, val)
                local snapped = math.Round(val / 100) * 100
                if snapped ~= val then
                    self:SetValue(snapped)
                end
            end
        end
    end)
end)