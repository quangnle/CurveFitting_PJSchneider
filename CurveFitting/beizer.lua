module(..., package.seeall)

local Point = require("point2d")

function new(p1, p2, p3, p4, granularity)
	local self = {}

	self.granularity = granularity
	self.p1 = p1
	self.p2 = p2
	self.p3 = p3
	self.p4 = p4
	
	self.computeSegments = function()
		local inc = 1.0 / self.granularity
		local t = 0
		local t1 = 0
		
		local bSegments = {}
		
		for i = 1, self.granularity do
			t1 = 1 - t
			
			local t1_3 = t1 ^ 3
			local t1_3a = (3 * t) * t1 ^ 2
			local t1_3b = (3 * t ^ 2) * t1
			local t1_3c = t ^ 3
			
			local x = t1_3 * self.p1.x
			x = x + t1_3a * self.p2.x;
            x = x + t1_3b * self.p3.x;
            x = x + t1_3c * self.p4.x

            local y = t1_3  * self.p1.y;
            y = y + t1_3a * self.p2.y;
            y = y + t1_3b * self.p3.y;
            y = y + t1_3c * self.p4.y;

			bSegments[i] = {}
			bSegments[i].x, bSegments[i].y = x, y
            t = t + inc;
		end
		
		return bSegments
	end
	
	self.draw = function()
		bSegments = self.computeSegments()
		
		for i = 1, self.granularity - 1 do
			display.newLine(bSegments[i].x, bSegments[i].y, bSegments[i + 1].x, bSegments[i + 1].y)
		end
		
	end
	
	return self
end

function computeParam(degree, points, t)
	
		local result = nil
		local tmp = {}
		
		-- clone the points
		for i = 1, degree + 1 do
			tmp[i] = Point.new(points[i].x, points[i].y)			
		end
		
		-- triangle computation 
		for i = 2, degree + 1 do
			for j = 1, degree do
				tmp[j].x = (1 - t) * tmp[j].x + t * tmp[j + 1].x
				tmp[j].y = (1 - t) * tmp[j].y + t * tmp[j + 1].y
			end
		end
		
		result = tmp[1]
		return result
	end