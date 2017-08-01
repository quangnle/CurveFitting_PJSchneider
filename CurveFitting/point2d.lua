module(..., package.seeall)

function new(x, y)
	local self = {}
	
	self.x = x
	self.y = y
	
	self.sqDistance = function(p)
		return (self.x - p.x) ^ 2 + (self.y - py)
	end
	
	self.distance = function(p)
		return math.sqrt(self.sqDistance(p))
	end
	
	-- distance from this point to the line (p1, p2)
	self.dToLine = function(p1, p2)
		
		local area = math.abs(0.5 * (p1.x * p2.y + p2.x * self.y + 
		self.x * p1.y - p2.x * p1.y - self.x * p2.y - p1.x * self.y))
		
		local bottom = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
		local height = area / bottom * 2
	
		return height
	end
	
	return self
end