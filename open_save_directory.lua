local function open_save_directory()
	local save_dir = love.filesystem.getSaveDirectory()
	local os_name = love.system.getOS()

	local command
	if os_name == "Windows" then
		command = string.format('explorer "%s"', save_dir)
	elseif os_name == "OS X" then
		command = string.format('open "%s"', save_dir)
	elseif os_name == "Linux" then
		-- Try different Linux file browsers
		-- xdg-open is the most standard one, but we fallback to others if it fails
		local linux_commands = {
			string.format('xdg-open "%s"', save_dir),
			string.format('gnome-open "%s"', save_dir),
			string.format('nautilus "%s"', save_dir),
			string.format('dolphin "%s"', save_dir),
			string.format('nemo "%s"', save_dir),
			string.format('thunar "%s"', save_dir)
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

return open_save_directory
