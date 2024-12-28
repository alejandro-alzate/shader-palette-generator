local first_line = {}
local color_list = {}
local loading_complete = false
local pixel_x = 0

function first_line.extractColorFromImageData(imageData)
	if loading_complete then return color_list end

	local width = imageData:getWidth()

	local r, g, b, a = imageData:getPixel(pixel_x, 1)
	local color = { r, g, b, a }

	local exists = false
	for _, existing_color in ipairs(color_list) do
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
		loading_complete = true
	end

	return color_list, pixel_x, 0, pixel_x
end

function first_line.getColorList() return color_list end

function first_line.reset()
	color_list = {}
	loading_complete = false
	pixel_x = 0
end

function first_line.finished() return loading_complete end

return first_line
