module(..., package.seeall)

local Vector = require("vector2d")
local Beizer = require("beizer")

function computeLeftTangent(points, endIndex)
	local tHat1 = Vector.new(points[endIndex + 1].x, points[endIndex + 1].y)
	local tmp = (Vector.new(points[endIndex].x, points[endIndex].y)).negate()
	tHat1 = tHat1.addVector(tmp)
	tHat1 = tHat1.unit()
	
	return tHat1
end

function computeRightTangent(points, endIndex)
	local tHat2 = Vector.new(points[endIndex - 1].x, points[endIndex - 1].y)
	local tmp = (Vector.new(points[endIndex].x, points[endIndex].y)).negate()
	tHat2 = tHat2.addVector(tmp)
	tHat2 = tHat2.unit()
	
	return tHat2
end

function computeCenterTangent(points, centerIndex)
	local v1 = Vector.new(points[centerIndex - 1].x, points[centerIndex - 1].y)
	v1 = v1.addVector((Vector.new(points[centerIndex].x, points[centerIndex].y)).negate())
	
	local v2 = Vector.new(points[centerIndex].x, points[centerIndex].y)
	v2 = v2.addVector((Vector.new(points[centerIndex + 1].x, points[centerIndex + 1].y)).negate())
	
	local vCenter = Vector.new((v1.x + v2.x) / 2, (v1.y + v2.y) / 2)
	vCenter = vCenter.unit()
	
	return vCenter
end

function chordLengthParam(points, first, last)
	local result = {}
		
	result[1] = 0
	
	for i = first + 1, last do
		local v = Vector.new(points[i - 1].x, points[i - 1].y)
		v = v.addVector((Vector.new(points[i].x, points[i].y)).negate())
		result[i - first + 1] = result[i - first] + v.getLength()
	end
	
	for i = first + 1, last do
		result[i - first] = result[i - first] / result[last - first]
	end
	
	return result
end

function computeMaxError(points, first, last, curve, u, splitPoint)
	local maxDist = 0
	local dist = 0
	local p = nil
	local v = nil
	
	splitPoint.val = ((last - first + 1) - ((last - first + 1) % 2)) / 2
	
	for i = first + 1, last - 1 do
		p = Beizer.computeParam(3, curve, u[i - first])
		v = Vector.new(p.x - points[i].x, p.y - points[i].y)
		dist = v.getSqLength()
		
		if (dist >= maxDist) then
			maxDist = dist
			splitPoint.val = i
		end
	end
	
	return maxDist
end

function rootFind(points, p, u)
	local numerator, denominator
	local q1 = {}
	local q2 = {}
	-- Q, Q' and Q''
	local qu, qu1, qu2 = nil, nil, nil
	
	qu = Beizer.computeParam(3, points, u)
	
	-- generate control points for Q'
	for i = 1, 3 do
		q1[i].x = (points[i + 1].x - points[i].x) * 3
		q1[i].y = (points[i + 1].y - points[i].y) * 3
	end
	
	-- generate control points for Q''
	for i = 1, 2 do
		q2[i].x = (q1[i + 1].x - q1[i].x) * 2.0;
        q2[i].y = (q1[i + 1].y - q1[i].y) * 2.0;
	end
	
	-- compute Q'(u) and Q''(u)
	qu1 = Beizer.computeParam(2, q1, u)
	qu2 = Beizer.computeParam(1, q2, u)
	
	-- compute f(u) / f'(u)
	numerator = (qu.x - p.x) * qu1.x + (qu.y - p.y) * qu1.y
	denominator = qu1.x ^ 2 + qu1.y ^ 2 + (qu.x - p.x) * qu2.x + (qu.y - p.y) * qu2.y
	
	if denominator == 0 then -- root found already
		return u
	end
	
	-- Newton: t <- t - f(x) / f'(x)
	local result = u - (numerator / denominator)
	return result
end

function reParam(points, first, last, u, curve)
	local nPts = last - first + 1
	local result = {}
	
	for i = first, last do
		result[i - first + 1] = rootFind(curve, points, u[i - first + 1])
	end
	
	return result
end

-- to solve to matrix equation
-- | C11 C12 | |A1| = |X1|
-- | C21 C22 | |A2|   |X2|
-- A1, A2 are alpha1, alpha2
function generateBeizer(points, first, last, uPrime, tHat1, tHat2)
	local A = {}
	local C = {}
	local X = {}
	
	local bzCurve = {}
	local nPts = last - first + 1
	
	-- compute A's (alpha1 and alpha2)
	for i = 1, nPts do
		local v1 = Vector.new(tHat1.x, tHat1.y)
		local v2 = Vector.new(tHat2.x, tHat2.y)

		v1 = v1.mul(3 * uPrime[i] * (1 - uPrime[i]) ^ 2)
		v2 = v2.mul(3 * uPrime[i] ^ 2 * (1 - uPrime[i]))
		
		A[i] = {}
		A[i][1] = v1
		A[i][2] = v2
	end
	
	-- create C and X matrices
	C[1] = {}
	C[1][1] = 0
	C[1][2] = 0
	C[2] = {}
	C[2][1] = 0
	C[2][2] = 0
	
	X[1] = 0
	X[2] = 0
	
	for i = 1, nPts  do
		local va1 = Vector.new(A[i][1].x, A[i][1].y)
		local va2 = Vector.new(A[i][2].x, A[i][2].y)
		
		C[1][1] = C[1][1] + va1.dot(va1)
		C[1][2] = C[1][2] + va1.dot(va2)
		C[2][1] = C[1][2]
		C[2][2] = C[2][2] + va2.dot(va2)		
		
		local vfi = Vector.new(points[first + i - 1].x, points[first + i - 1].y)
		local vf = Vector.new(points[first].x, points[first].y)
		local vl = Vector.new(points[last].x, points[last].y)
		
		local op1 = vf.mul((1 - uPrime[i]) ^ 3)
		local op2 = vf.mul(3 * uPrime[i] * (1 - uPrime[i]) ^ 2)
		local op3 = vl.mul(3 * uPrime[i] ^ 2 * (1 - uPrime[i]))
		local op4 = vl.mul(uPrime[i] ^ 3)
		
		local vsum = op1.addVector(op2)
		vsum = vsum.addVector(op3)
		vsum = vsum.addVector(op4)
		vsum = vfi.addVector(vsum.negate())
		
		X[1] = X[1] + A[i][1].dot(vsum)
		X[2] = X[2] + A[i][2].dot(vsum)
	end
	
	-- compute determinant
	local detc1c2 = C[1][1] * C[2][2] - C[2][1] * C[1][2]
	local detc1x = C[1][1] * X[2] - C[2][1] * X[1]
	local detxc2 = X[1] * C[2][2] - X[2] * C[1][2]
	
	local alpha_l, alpha_r = 0, 0
	
	if detc1c2 ~= 0 then
		alpha_l = detxc2 / detc1c2
		alpha_r = detc1x / detc1c2
	end
	
	local segLength = math.sqrt((points[first].x - points[last].x) ^ 2 + (points[first].y - points[last].y) ^ 2)
	local epsilon = (10 ^ (-6) ) * segLength
	
	if alpha_l < epsilon or alpha_r < epsilon then
		local dist = segLength / 3
		bzCurve[1] = points[first]
		bzCurve[4] = points[last]
		bzCurve[2] = (tHat1.mul(dist)).addVector(Vector.new(bzCurve[1].x, bzCurve[1].y))
		bzCurve[3] = (tHat2.mul(dist)).addVector(Vector.new(bzCurve[4].x, bzCurve[4].y))
		
		return bzCurve
	end
	
	local dist = segLength / 3
	bzCurve[1] = points[first]
	bzCurve[4] = points[last]
	bzCurve[2] = (tHat1.mul(alpha_l)).addVector(Vector.new(bzCurve[1].x, bzCurve[1].y))
	bzCurve[3] = (tHat2.mul(alpha_r)).addVector(Vector.new(bzCurve[4].x, bzCurve[4].y))
	
	return bzCurve
end

function fitCubic(points, first, last, tHat1, tHat2, err, result)
	local bzCurve = {}
	local iterationError = err ^ 2
	local nPts = last - first + 1
	
	if nPts == 2 then
		local segLength = math.sqrt((points[first].x - points[last].x) ^ 2 + (points[first].y - points[last].y) ^ 2)
		local dist = segLength / 3
		
		bzCurve[1] = points[first]
		bzCurve[4] = points[last]
		bzCurve[2] = (tHat1.mul(dist)).addVector(Vector.new(bzCurve[1].x, bzCurve[1].y))
		bzCurve[3] = (tHat2.mul(dist)).addVector(Vector.new(bzCurve[4].x, bzCurve[4].y))		
		
		local bz = Beizer.new(bzCurve[1], bzCurve[2], bzCurve[3], bzCurve[4], 20)
		bz.draw()
		
		table.insert(result, bzCurve[2])
		table.insert(result, bzCurve[3])
		table.insert(result, bzCurve[4])
		
		return
	end
	
	local u = chordLengthParam(points, first, last)
	bzCurve = generateBeizer(points, first, last, u, tHat1, tHat2)
	
	-- find max deviation of points to fit curve
	local splitPoint = {}
	--computeMaxError(points, first, last, curve, u, splitPoint)
	local maxError = computeMaxError(points, first, last, bzCurve, u, splitPoint)
	
	if maxError < err then
		
		table.insert(result, bzCurve[2])
		table.insert(result, bzCurve[3])
		table.insert(result, bzCurve[4])
		
		local bz = Beizer.new(bzCurve[1], bzCurve[2], bzCurve[3], bzCurve[4], 20)
		bz.draw()
		return
	end
	
	-- if error not too large, try some re-parameterizations and iterations
	if maxError < iterationError then
		for i = 1, 4 do
			uPrime = reParam(points, first, last, u, bzCurve)
			bzCurve = generateBeizer(points, first, last, uPrime, tHat1, tHat2)
			maxError = computeMaxError(points, first, last, bzCurve, uPrime, splitPoint)
			
			if maxError < err then
			
				table.insert(result, bzCurve[2])
				table.insert(result, bzCurve[3])
				table.insert(result, bzCurve[4])
				
				local bz = Beizer.new(bzCurve[1], bzCurve[2], bzCurve[3], bzCurve[4], 20)
				bz.draw()
				return 
			end
			
			u = uPrime
		end
	end 	
	
	-- fitting failed -> split, and recursion	
	local tHatCenter = computeCenterTangent(points, splitPoint.val)
	--(points, first, last, tHat1, tHat2, err, result)
	fitCubic(points, first, splitPoint.val, tHat1, tHatCenter, err, result)
	tHatCenter = tHatCenter.negate()
	fitCubic(points, splitPoint.val, last, tHatCenter, tHat2, err, result)
	
end

function fitCurve(points, err)
	local tHat1, tHat2
	tHat1 = computeLeftTangent(points, 1)
	tHat2 = computeRightTangent(points, #points)
	
	local result = {}
	
	fitCubic(points, 1, #points, tHat1, tHat2, err, result)
	return result
end