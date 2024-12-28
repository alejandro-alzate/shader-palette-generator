local function split_filename(filepath)
	-- Handle both forward and backward slashes
	local pattern = "(.-)([^\\/]-)%.?([^%.\\/]*)$"
	local route, filename, ext = filepath:match(pattern)

	-- If route is empty, make it './'
	route = (route == "") and "./" or route

	return route, filename, ext
end

return split_filename
