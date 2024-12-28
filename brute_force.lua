local brute_force = {}
local color_list = {}
local pixel_x = 0
local pixel_y = 0
local loading_complete = false

function brute_force.extractColorFromImageData(imageData)
	if loading_complete then return color_list end

	local width = imageData:getWidth()
	local height = imageData:getHeight()

	local r, g, b, a = imageData:getPixel(pixel_x, pixel_y)
	local color = { r, g, b, a }

	local exists = false
	for i, existing_color in ipairs(color_list) do
		if existing_color[1] == r and
			existing_color[2] == g and
			existing_color[3] == b and
			existing_color[4] == a then
			exists = true
			break
		end
	end

	if not exists then
		table.insert(color_list, color)
	end

	pixel_x = pixel_x + 1
	if pixel_x >= width then
		pixel_x = 0
		pixel_y = pixel_y + 1
		if pixel_y >= height then
			loading_complete = true
		end
	end

	return color_list, pixel_x, pixel_y, pixel_x + (pixel_y * imageData:getWidth())
end

function brute_force.isColorInTable(color, colorTable)
	for _, c in ipairs(colorTable) do
		if c[1] == color[1] and
			c[2] == color[2] and
			c[3] == color[3] and
			c[4] == color[4] then
			return true
		end
	end
	return false
end

function brute_force.getColorList() return color_list end

function brute_force.reset()
	color_list = {}
	pixel_x = 0
	pixel_y = 0
end

function brute_force.finished() return loading_complete end

return brute_force
