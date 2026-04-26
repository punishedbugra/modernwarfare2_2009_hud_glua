local files, _ = file.Find("codhud/*.lua", "LUA")

CoDHUD = CoDHUD or {}
CoDHUD.TypeRegistry = CoDHUD.TypeRegistry or {}

if CLIENT then
	function CoDHUD.RegisterHUD(codename, displayname)
		if not codename or not displayname then return end

		CoDHUD.TypeRegistry[codename] = {
			codename = codename,
			name = displayname
		}
		
		-- timer.Simple( 0.25, function() print( "CoDHUD Registered: " .. (codename or "Unknown Name") .. " - " .. (displayname or "Unknown Title") ) end )
	end

	function CoDHUD.GetHUDList()
		local mainHUDs = {}

		for _, hud in pairs(CoDHUD.TypeRegistry or {}) do
			table.insert(mainHUDs, {
				hud.name,       -- display text
				hud.codename    -- convar value
			})
		end

		table.sort(mainHUDs, function(a, b)
			return a[1] < b[1]
		end)

		return mainHUDs
	end

end

for _, f in ipairs(files) do
    local path = "codhud/" .. f

    if SERVER then
        -- Send every file to the client
        AddCSLuaFile(path)
    end

    -- Include depending on prefix (same behavior as autorun)
    if SERVER and f:StartWith("sv_") then
        include(path)
    elseif CLIENT and f:StartWith("cl_") then
        include(path)
    elseif f:StartWith("sh_") then
        include(path)
    end
end