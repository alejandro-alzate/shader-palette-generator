local function open_save_directory_with_file(filename)
	local save_dir = love.filesystem.getSaveDirectory()
	local filepath = save_dir .. "/" .. filename
	local os_name = love.system.getOS()

	local command
	if os_name == "Windows" then
		-- /select, switches to highlight the file in Explorer
		command = string.format('explorer /select,"%s"', filepath:gsub("/", "\\"))
	elseif os_name == "OS X" then
		-- -R reveals the file in Finder
		command = string.format('open -R "%s"', filepath)
	elseif os_name == "Linux" then
		-- Different file managers have different approaches
		local linux_commands = {
			-- If specific selection isn't supported, at least open the directory
			string.format('xdg-open "%s"', save_dir),
			-- Nautilus (GNOME)
			string.format('nautilus --select "%s"', filepath),
			-- Dolphin (KDE)
			string.format('dolphin --select "%s"', filepath),
			-- Nemo (Cinnamon)
			string.format('nemo "%s"', filepath),
		}

		for _, cmd in ipairs(linux_commands) do
			if os.execute(cmd) then
				return true
			end
		end
		return false
	else
		return false
	end

	return os.execute(command)
end

return open_save_directory_with_file
