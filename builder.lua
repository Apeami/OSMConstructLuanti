local builder = {}

function bresenhamLine(p0, p1)
    local line = {}
    local dx = math.abs(p1.x - p0.x)
    local dy = math.abs(p1.y - p0.y)
    local sx = (p0.x < p1.x) and 1 or -1
    local sy = (p0.y < p1.y) and 1 or -1
    local err = dx - dy

    while true do
        table.insert(line, {x = p0.x, y = p0.y})
        if p0.x == p1.x and p0.y == p1.y then break end
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            p0.x = p0.x + sx
        end
        if e2 < dx then
            err = err + dx
            p0.y = p0.y + sy
        end
    end
    return line
end 


function builder.buildsegment(startcoord, endcoord, block, height, data, a)
    local block  = core.get_content_id(block)

    line = bresenhamLine(startcoord, endcoord)
    for _,coord in pairs(line) do
        for level=1, height do
            if a:contains(coord.x, level, coord.y) then
                local vi = a:index(coord.x, level, coord.y)
                data[vi] = block
            end
        end
    end
end

function builder.buildRoad(way ,block, dashblock, thickness, linedashon, linedashoff, data, a)
    local nodes = way['nodes']
    for i = 1, #nodes - 1 do
        builder.buildRoadSegment(nodes[i], nodes[i + 1], block, dashblock, thickness, linedashon, linedashoff, data, a)
    end
end

function builder.buildRoadSegment(startcoord, endcoord, block, dashblock, thickness, linedashon, linedashoff, data, a)
    local centralLine = bresenhamLine(startcoord, endcoord)

    local block  = core.get_content_id(block)
    local dashblock  = core.get_content_id(dashblock)

    local coordinates = {}
    local radius = math.floor(thickness / 2)

    for _, point in ipairs(centralLine) do
        for dx = -radius, radius do
            for dy = -radius, radius do
                -- Check if the point is within the circular radius
                if dx * dx + dy * dy <= radius * radius then
                    table.insert(coordinates, {x = point.x + dx, y = point.y + dy})
                end
            end
        end
    end

    for _,coord in pairs(coordinates) do
        if a:contains(coord.x, 0, coord.y) then
            local vi = a:index(coord.x, 0, coord.y)
            data[vi] = block
        end
    end

    local step=0
    for _, centralcoord in pairs(centralLine) do

        if (step%(linedashoff+linedashon)) < linedashon then
            if a:contains(centralcoord.x, 0, centralcoord.y) then
                local vi = a:index(centralcoord.x, 0, centralcoord.y)
                data[vi] = dashblock
            end
        end
        step =step +1
    end

end

-- Function to check if a point (px, py) is inside a polygon
function isPointInPolygon(px, py, polygon)
    local inside = false
    local n = #polygon
    local j = n

    for i = 1, n do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y

        -- Check if point lies on an edge or crosses a boundary
        if ((yi > py) ~= (yj > py)) and 
           (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end

    return inside
end

function getbounds(nodes)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    -- Find bounding box of the polygon
    for _, point in ipairs(nodes) do
        minX = math.min(minX, point.x)
        minY = math.min(minY, point.y)
        maxX = math.max(maxX, point.x)
        maxY = math.max(maxY, point.y)
    end

    return minX, minY, maxX, maxY
end


local function chooseRandomKey(probTable)
    local cumulative = {}
    local total = 0
    for key, prob in pairs(probTable) do
        total = total + prob
        cumulative[#cumulative + 1] = { key = key, cumProb = total }
    end

    assert(math.abs(total - 1.0) < 0.0001, "Probabilities must sum to 1")

    local rand = math.random()

    for _, entry in ipairs(cumulative) do
        if rand <= entry.cumProb then
            return entry.key
        end
    end
end

function builder.buildarea(wayarea, block, height,random, data, a)
    --block probdistribution format - table with key for each block and probability of occouring
    minX, minY, maxX, maxY = getbounds(wayarea['nodes'])

    -- Iterate through all points in the bounding box
    for x = math.floor(minX), math.ceil(maxX) do
        for y = math.floor(minY), math.ceil(maxY) do
            if a:contains(x, height, y) then
                if isPointInPolygon(x, y, wayarea['nodes']) then
                    local vi = a:index(x, height, y)
                    local chosenBlock
                    if random then
                        chosenBlock = chooseRandomKey(block)
                    else
                        chosenBlock = block
                    end
                    chosenBlock = core.get_content_id(chosenBlock)
                    
                    data[vi] = chosenBlock
                end
            end
        end
    end
end

local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

function builder.buildHouse(way, block, height, data, a)
    builder.buildarea(way, block, height, false, data, a)
    builder.buildway(way, block, height, data, a)
end

function builder.buildway(way, block, height, data, a)
    local nodes = way['nodes'] -- Cache the 'nodes' table for efficiency
    -- Iterate through nodes, building segments between consecutive nodes
    for i = 1, #nodes - 1 do -- Use `#nodes - 1` to avoid indexing out of bounds
        builder.buildsegment(nodes[i], nodes[i + 1], block, height, data, a)
    end
end

function builder.buildallways(ways)
    -- Iterate through each way in the list of ways
    for _, way in pairs(ways) do
        builder.buildway(way, 1)
    end
end

function builder.buildbase(bounds, data,a)
    local block = core.get_content_id("default:obsidian_block")
    for x = bounds.x0, bounds.x1 do
        for z = bounds.y0, bounds.y1 do
            local vi = a:index(x, -1, z)
            data[vi] = block
        end
    end
end

function builder.clearbounds(bounds)
    local air = core.get_content_id("air")
    pos1 = {x = bounds.x0 , y=-40, z = bounds.y0}
    pos2 = {x = bounds.x1 , y=40, z = bounds.y1}

    print("CLEAR BOUNDS")
    printTable(pos1)
    printTable(pos2)

    -- Read data into LVM
    local vm = core.get_voxel_manip()
    local emin, emax = vm:read_from_map(pos1, pos2)
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local data = vm:get_data()

    -- Modify data
    for z = pos1.z, pos2.z do
        for y = pos1.y, pos2.y do
            for x = pos1.x, pos2.x do
                local vi = a:index(x, y, z)
                data[vi] = air
            end
        end
    end

    -- Write data
    vm:set_data(data)
    vm:write_to_map(true)
end

function printTable(t)
    if type(t) ~= "table" then
        print("Not a table")
        return
    end
    for key, value in pairs(t) do
        if type(value) == "table" then
            -- Recursively print nested tables
            print(key .. ":")
            printTable(value)
        else
            print(key .. ": " .. tostring(value))
        end
    end
end

return builder