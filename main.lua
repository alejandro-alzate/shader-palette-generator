love.graphics.setDefaultFilter("nearest", "nearest")
love.filesystem.setIdentity("paletteGenerator")
local glslPalette = require("generate_glsl_table")
local split_filename = require("split_filename")
local open_save_directory = require("open_save_directory")
local open_file_selected = require("open_file_selected")
local algorithms = { brute_force = require("brute_force"), first_line = require("first_line"), }
local currentalgorithm = algorithms["first_line"]
local sanitize_filename = function(name)
	local basename = name:match("([^/\\]+)$") or name
	return basename:gsub("[^%w%s-]", ""):gsub("%s+", "_")
end

local info = ""
local drawable = false
local imgdata = false
local color_list = {}
local imageFiles = {}

local lastidx = 0
local tableGenerated = false
local glslString = ""
local whereToWrite = ""

local px, py, idx

local function reset()
	lastidx = 0
	tableGenerated = false
	glslString = ""
	whereToWrite = ""
end


local function processNextImage()
	if #imageFiles > 0 then
		local file = imageFiles[1]
		local filepath = file.getFullPath and file:getFullPath() or file
		local res, msg = pcall(function()
			return love.image.newImageData(filepath)
		end)
		if not res then
			info = msg
			table.remove(imageFiles, 1)
			processNextImage()
		else
			local filename = file:getFilename()
			local route, name, ext = split_filename(filename)
			local outputPath = file.getOutputPath and file:getOutputPath() or ""
			love.filesystem.createDirectory(outputPath)
			whereToWrite = outputPath .. "/" .. name .. ".glsl"
			tableGenerated = false
			currentalgorithm.reset()
			imgdata = msg
			drawable = love.graphics.newImage(msg)
			local w = math.max(drawable:getWidth(), 500)
			local h = math.max(drawable:getHeight() + 50, 100)
			love.window.updateMode(w, h, { resizable = true, vsync = false })
		end
	end
end

function love.update(dt)
	if imgdata then
		local width = imgdata:getWidth()
		local height = imgdata:getHeight()
		local pxcount = width * height
		color_list, px, py, idx = currentalgorithm.extractColorFromImageData(imgdata)
		if idx then lastidx = idx end
		if px then
			info = string.format(
				"Processing pixel: %s/%s\nColors found: %s",
				idx or "nil", pxcount or "nil",
				#color_list or "nil"
			)
		end

		if currentalgorithm.finished() then
			info = string.format(
				"Algorithm will not check more pixels: (%s/%s)\nColors found: %s",
				lastidx or "nil", pxcount or "nil",
				#color_list or "nil"
			)
			if not tableGenerated then
				glslString = glslPalette.generate(color_list)
				love.filesystem.write(whereToWrite, glslString)
				tableGenerated = true
				table.remove(imageFiles, 1)
				processNextImage()
			end
		end
	end
end

function love.draw()
	if drawable then
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(drawable, 0, love.graphics.getHeight() - drawable:getHeight())
		love.graphics.setColor(1, 0, 1)
		love.graphics.circle("line", px or 0, (py or 0) + love.graphics.getHeight() - drawable:getHeight(), 5)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(info)
end

function love.filedropped(file)
	local filename = file:getFilename()
	local ext = filename:match("%.(%w+)$")

	if ext and ext:lower() == "zip" then
		imageFiles = {}
		local basename = filename:match("([^/\\]+)%.zip$") or filename:gsub("%.zip$", "")
		local sanitized_name = sanitize_filename(basename)
		local mount_point = "mounted_zip"

		local zip_path = file:getFilename()

		local success = love.filesystem.mount(zip_path, mount_point)
		if success then
			local outputDir = sanitized_name
			love.filesystem.createDirectory(outputDir)

			local function scanZipDirectory(path)
				local items = love.filesystem.getDirectoryItems(path)
				for _, item in ipairs(items) do
					local fullPath = path .. "/" .. item
					local fileInfo = love.filesystem.getInfo(fullPath)

					if fileInfo then
						if fileInfo.type == "file" then
							local itemExt = item:match("%.(%w+)$")
							if itemExt and (itemExt:lower() == "png" or itemExt:lower() == "jpg" or itemExt:lower() == "jpeg") then
								local fileObj = {
									getFilename = function() return item end,
									getFullPath = function() return fullPath end,
									getOutputPath = function() return outputDir end
								}
								table.insert(imageFiles, fileObj)
								print("Added image from ZIP:", item)
							end
						elseif fileInfo.type == "directory" then
							scanZipDirectory(fullPath)
						end
					end
				end
			end

			scanZipDirectory(mount_point)
			love.filesystem.unmount(mount_point)

			print("Total images found in ZIP:", #imageFiles)
			if #imageFiles > 0 then
				processNextImage()
			else
				print("No images found in ZIP file")
			end
		else
			print("Failed to mount ZIP file")
		end
	elseif ext and (ext:lower() == "png" or ext:lower() == "jpg" or ext:lower() == "jpeg") then
		table.insert(imageFiles, file)
		processNextImage()
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		love.event.quit("restart")
	end
	if key == "space" then
		open_save_directory()
	end
end
