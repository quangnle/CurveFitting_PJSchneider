module(..., package.seeall)

function new(x, y)
	
	local self = {}
	
	self.x = x
	self.y = y
	
	self.add = function(mx, my)
		local v = new(mx, my)
		v.x = v.x + self.x
		v.y = v.y + self.y
		
		return v
	end
	
	self.addVector = function(v)
		return self.add(v.x, v.y)
	end
	
	self.mul = function(d)
		local v = new(self.x, self.y)
		v.x, v.y = v.x * d, v.y * d
		return v
	end
	
	self.getSqLength = function()
		return (self.x ^ 2 + self.y ^ 2)
	end
	
	self.getLength = function()
		return math.sqrt(self.getSqLength())
	end
	
	self.negate = function()
		return self.mul(-1)
	end
	
	self.unit = function()
		local l = self.getLength()
		return self.mul(1 / l)
	end
	
	self.dot = function (v)
		return self.x * v.x + self.y * v.y	
	end
	
	self.cross = function (v)
		return self.x * v.y - self.y * v.x
	end
	
	return self
end