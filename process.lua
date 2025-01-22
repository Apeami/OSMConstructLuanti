function process(doc, name)
    core.chat_send_player(name, "Processing Data")
    if doc.children[1].tag == 'osm' then
        elements = doc.children[1].children
    else
        print("error")
        core.chat_send_player(name, "Error: File Invalid format")
        return
    end

    local bounds = {}
    local nodeswithtag = {}
    local ways = {}


    for i, element in pairs(elements) do
        if element.tag == 'bounds' then
            for _,attr in ipairs(element.orderedattrs) do
                table.insert(bounds, attr.value)
            end
            break
        end
    end
    
    core.chat_send_player(name, "Number of elements: ".. #elements)
    local last_reported_percentage = 0
    for i, element in pairs(elements) do

        local percentage = math.floor((i / #elements) * 100)
        if percentage >= last_reported_percentage + 5 then
            core.chat_send_player(name, "Processing Data [1/4]: " .. percentage .. "% complete")
            last_reported_percentage = percentage
        end

        if element.tag == 'node' then
            local nodeinfo = {}
            local coord = {}
            local tags = {}
            local found = false
            for _, nodeelement in pairs(element.children) do
                if nodeelement.tag =='tag' then
                    table.insert(tags, orderedattrstotag(nodeelement.orderedattrs))
                    found = true
                end
            end
            if found==true then
                
                for _, elementattrs in pairs(element.orderedattrs) do
                    if elementattrs.name == 'lat' then
                        coord['x'] = elementattrs.value
                    end
                    if elementattrs.name == 'lon' then
                        coord['y'] = elementattrs.value
                    end
                end
                x,y = distance_to_offset(bounds[1], bounds[2],coord['x'], coord['y'] )
                coord['x'] = x
                coord['y'] = y

                nodeinfo['coord'] = coord
                nodeinfo['tags'] = tags
                table.insert(nodeswithtag,nodeinfo)
            end
        end

        if element.tag == 'way' then
            local wayinfo = {}
            local waynodes = {}
            local tags = {}

            for _, wayelement in pairs(element.children) do
                if wayelement.tag =='tag' then
                    table.insert(tags, orderedattrstotag(wayelement.orderedattrs))
                end
                if wayelement.tag =='nd' then
                    local noderef = wayelement.orderedattrs[1].value
                    table.insert(waynodes, nodereftocoord(noderef, elements, bounds))
                end
            end
            
            wayinfo['nodes'] = waynodes
            wayinfo['tags'] = tags
            table.insert(ways, wayinfo)
        end
    end

    x,y = distance_to_offset(bounds[1], bounds[2],bounds[3], bounds[4])
    bounds = {x0= 0,y0=0,x1=x,y1=y}

    return nodeswithtag,ways, bounds


end

function nodereftocoord(ref, elements, bounds)
    local coord = { x = nil, y = nil }
    local usenode = false
    for i, element in pairs(elements) do
        if element.tag == 'node' then
            usenode = false
            coord = { x = nil, y = nil }
            for _, attr in pairs(element.orderedattrs) do
                if attr.name == 'id' and attr.value ==ref then 
                    usenode = true
                end
                if attr.name == 'lat' then
                    coord.x = attr.value
                end
                if attr.name == 'lon' then
                    coord.y = attr.value
                end

                if coord.x ~= nil and coord.y ~= nil and usenode then
                    local x, y = distance_to_offset(bounds[1], bounds[2], coord.x, coord.y)
                    coord.x = x
                    coord.y = y
                    return coord
                end
                
            end
        end
    end
end

function distance_to_offset(lat1, lon1, lat2, lon2)
    local R = 6371000

    local lat1_rad = math.rad(lat1)
    local lon1_rad = math.rad(lon1)
    local lat2_rad = math.rad(lat2)
    local lon2_rad = math.rad(lon2)

    local dlat = lat2_rad - lat1_rad
    local dlon = lon2_rad - lon1_rad

    local x = R * dlon * math.cos((lat1_rad + lat2_rad) / 2)
    local y = R * dlat
 
    return math.round(x), math.round(y)
end

function orderedattrstotag(orderedattrs)
    local k_value = ""
    local v_value = ""

    for _, attr in ipairs(orderedattrs) do
        if attr.name == 'k' then
            k_value = attr.value
        elseif attr.name == 'v' then
            v_value = attr.value
        end
    end

    if k_value ~= "" and v_value ~= "" then
        return k_value .. "=" .. v_value
    else
        return ""  
    end
end

return process