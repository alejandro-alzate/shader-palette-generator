local glslPalette = {}

function glslPalette.generate(color_list)
	local colorCount = #color_list
	local output = string.format("const int maxColorCount = %d;\n", colorCount)
	output = output .. "const vec3 palette[maxColorCount] = vec3[maxColorCount](\n"


	for i, color in ipairs(color_list) do
		local r = math.floor(color[1] * 255 + 0.5)
		local g = math.floor(color[2] * 255 + 0.5)
		local b = math.floor(color[3] * 255 + 0.5)
		local comma = i < colorCount and "," or ""
		output = output .. string.format("\t\tvec3(%d, %d, %d)%s\n", r, g, b, comma)
	end

	output = output .. "    );"

	return output
end

return glslPalette
