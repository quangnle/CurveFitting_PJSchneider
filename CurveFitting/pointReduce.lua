module(..., package.seeall)

function dPointLine(point1, point2, point3)
	local area = math.abs(0.5 * (point2.x * point3.y + point3.x * 
    point1.y + point1.x * point2.y - point3.x * point2.y - point1.x * 
    point3.y - point2.x * point1.y))
    
    print ("p1 " .. point1.x .. " ," .. point1.y)
    print ("p2 " .. point2.x .. " ," .. point2.y)
    print ("p3 " .. point3.x .. " ," .. point3.y)
    
    print("S= " .. area)
    
    local bottom = math.sqrt((point2.x - point3.x) ^ 2 + (point2.y - point3.y) ^ 2)
    local height = area / bottom * 2

    return height
end

function douglaspeucker(points, firstpoint, lastpoint, tolerance, pointIndices)
	local maxD = 0
	local indexFurthest = 0
	
	for i = firstpoint, lastpoint do
		local distance = dPointLine(points[i], points[firstpoint], points[lastpoint])
		print ("d= " .. distance)
		if distance > maxD then
			maxD = distance
			indexFurthest = i
		end
	end
	
	if maxD > tolerance and indexFurthest ~= 1 then
		table.insert(pointIndices, indexFurthest)
		print ("n = " .. #pointIndices)
		douglaspeucker(points, firstpoint, indexFurthest, tolerance, pointIndices)
		douglaspeucker(points, indexFurthest, lastpoint, tolerance, pointIndices)
	end
end

function dpReduction(points, tolerance)
	if points == nil or #points < 3 then
		return points
	end
	
	local fPoint = 1
	local lPoint = #points
	
	local indices = {}
	table.insert(indices, fPoint)
	table.insert(indices, lPoint)
	
	while points[fPoint].x == points[lPoint].x and points[fPoint].y == points[lPoint].y do
		lPoint = lPoint - 1
	end
	
	douglaspeucker(points, fPoint, lPoint, tolerance, indices)
	
	for i = 1, #indices - 1 do
		for j = #indices, i + 1, -1 do
			if indices[i] > indices[j] then
				indices[i], indices[j] = indices[j], indices[i]
			end
		end
	end
	
	local newSet = {}
	
	for i = 1, #indices do 
		table.insert(newSet, points[indices[i]])
	end
	
	return newSet
end