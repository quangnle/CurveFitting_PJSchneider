local pReduce = require("pointReduce")
local beizer = require("beizer")
local schneider = require("pjschneider")

local path = {}
path.count = 0

function onTouched(event)
	if event.phase == "began" then
		--display.getCurrentStage():setFocus(event.target)
		
		path.count = 1
		path[path.count] = {}
		path[path.count].x, path[path.count].y = event.x, event.y
		
		--display.newRect(path[path.count].x, path[path.count].y, 2, 2)
		
		display.newLine(path[path.count].x - 2, path[path.count].y, path[path.count].x + 2, path[path.count].y)
		
	elseif event.phase == "moved" then
		local dx = event.x - path[path.count].x
		local dy = event.y - path[path.count].y
		local d = dx ^ 2 + dy ^ 2
		
		local angle = math.atan2(dy, dx) * 180 / math.pi
		
		if d > 25 then
			path.count = path.count + 1
			path[path.count] = {}
			path[path.count].x, path[path.count].y = event.x, event.y
		
			local line = display.newLine(path[path.count].x - 2, path[path.count].y, 
										path[path.count].x + 2, path[path.count].y)
			
			line.rotation = angle
		end
		
	elseif event.phase == "ended" then
		local dx = event.x - path[path.count].x
		local dy = event.y - path[path.count].y
		local d = dx ^ 2 + dy ^ 2
		
		local angle = math.atan2(dy, dx) * 180 / math.pi
	
		path.count = path.count + 1
		path[path.count] = {}
		path[path.count].x, path[path.count].y = event.x, event.y
		
		local line = display.newLine(path[path.count].x - 2, path[path.count].y, 
										path[path.count].x + 2, path[path.count].y)
			
		line.rotation = angle
		
		
		
		local newPath = pReduce.dpReduction(path, 10)
		for i = 1, #newPath do
			local rec = display.newRect(newPath[i].x, newPath[i].y, 3, 3)
			rec:setFillColor(255, 0, 0)
		end
		
		local result = schneider.fitCurve(newPath, 0)
		
		for i = 1, #result do
			local rec = display.newRect(result[i].x, result[i].y, 3, 3)
			rec:setFillColor(255, 0, 255)
		end
		--display.getCurrentStage():setFocus(nil)
	end
end


Runtime:addEventListener("touch", onTouched) 