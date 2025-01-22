local planBuild = {}

local mp = minetest.get_modpath(minetest.get_current_modname())
local builder = dofile(mp.."/builder.lua")

function planBuild.buildall(nodes, ways, bounds,name)

    --clear everything
    builder.clearbounds(bounds)

    --generate lvm
    local vm = core.get_voxel_manip()
    local emin, emax = vm:read_from_map({ x = bounds.x0, y =-40, z = bounds.y0 }, { x = bounds.x1, y =40, z = bounds.y1 })

    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local data = vm:get_data()

    core.chat_send_player(name, "Building base")
    builder.buildbase(bounds, data,a)
    core.chat_send_player(name, "Building Landuse")
    planBuild.buildLanduse(ways, data, a, name)
    core.chat_send_player(name, "Building Roads")
    planBuild.buildRoads(ways,data, a, name)
    core.chat_send_player(name, "Building Buildings")
    planBuild.buildBuildings(ways,data, a, name)


    vm:set_data(data)
    vm:write_to_map(true)
end

function planBuild.buildBuildings(ways, data, a, name)
    local last_reported_percentage = 0
    for i, way in pairs(ways) do
        local percentage = math.floor((i / #ways) * 100)
        if percentage >= last_reported_percentage + 10 then
            core.chat_send_player(name, "Building Buildings [4/4]: " .. percentage .. "% complete")
            last_reported_percentage = percentage
        end
        for _, tag in pairs(way['tags']) do
            -- Residential buildings
            if tag == 'building=house' then
                builder.buildHouse(way, "default:wood", 7, data, a)
            elseif tag == 'building=residential' then
                builder.buildHouse(way, "default:wood", 7, data, a)
            elseif tag == 'building=semidetached_house' then
                builder.buildHouse(way, "default:wood", 7, data, a)
            elseif tag == 'building=apartments' then
                builder.buildHouse(way, "default:stone", 15, data, a)
            elseif tag == 'building=detached' then
                builder.buildHouse(way, "default:wood", 7, data, a)

            -- Public and commercial buildings
            elseif tag == 'building=church' then
                builder.buildHouse(way, "default:obsidian", 15, data, a)
            elseif tag == 'building=school' then
                builder.buildHouse(way, "default:brick", 10, data, a)
            elseif tag == 'building=supermarket' then
                builder.buildHouse(way, "default:steelblock", 8, data, a)
            elseif tag == 'building=office' then
                builder.buildHouse(way, "default:glass", 20, data, a)
            elseif tag == 'building=industrial' then
                builder.buildHouse(way, "default:goldblock", 15, data, a)
            elseif tag == 'building=retail' then
                builder.buildHouse(way, "default:steelblock", 15, data, a)
            elseif tag == 'building=commercial' then
                builder.buildHouse(way, "default:steelblock", 15, data, a)
            elseif tag == 'building=train_station' then
                builder.buildHouse(way, "default:brick", 8, data, a)
            elseif tag == 'building=civic' then
                builder.buildHouse(way, "default:brick", 15, data, a)

            -- Recreational and leisure buildings
            elseif tag == 'building=sports_hall' then
                builder.buildHouse(way, "default:clay", 12, data, a)
            elseif tag == 'building=stadium' then
                builder.buildHouse(way, "default:stone", 20, data, a)

            -- Other buildings
            elseif tag == 'building=warehouse' then
                builder.buildHouse(way, "default:gravel", 10, data, a)
            elseif tag == 'building=barn' then
                builder.buildHouse(way, "default:wood", 8, data, a)
            elseif tag == 'building=garage' then
                builder.buildHouse(way, "default:steelblock", 6, data, a)
            elseif tag == 'building=greenhouse' then
                builder.buildHouse(way, "default:glass", 5, data, a)
            elseif tag == 'building=shed' then
                builder.buildHouse(way, "default:wood", 3, data, a)
            elseif tag == 'building=outbuilding' then
                builder.buildHouse(way, "default:wood", 3, data, a)
            -- elseif tag == 'building=roof' then
            --     builder.buildHouse(way, "default:wood", 5, data, a)

            --nonbuildings
            elseif tag == 'railway=platform' then
                builder.buildHouse(way, "default:stone", 1, data, a)

            -- Generic fallback for any unspecified building types
            elseif tag == 'building=yes' then
                builder.buildHouse(way, "default:brick", 7, data, a)
            end
        end
    end
end


function planBuild.buildRoads(ways, data, a, name)
    local last_reported_percentage = 0
    for i, way in pairs(ways) do
        local percentage = math.floor((i / #ways) * 100)
        if percentage >= last_reported_percentage + 10 then
            core.chat_send_player(name, "Building Roads [3/4]: " .. percentage .. "% complete")
            last_reported_percentage = percentage
        end
        for _, tag in pairs(way['tags']) do
            if tag == 'highway=motorway' then
                builder.buildRoad(way, "default:diamondblock", "default:steelblock", 12, 4, 6, data, a)
            elseif tag == 'highway=motorway_link' then
                builder.buildRoad(way, "default:goldblock", "default:steelblock", 10, 3, 5, data, a)
            elseif tag == 'highway=trunk' then
                builder.buildRoad(way, "default:steelblock", "default:obsidian_glass", 10, 3, 5, data, a)
            elseif tag == 'highway=primary' then
                builder.buildRoad(way, "default:steelblock", "default:obsidian_glass", 10, 3, 5, data, a)
            elseif tag == 'highway=secondary' then
                builder.buildRoad(way, "default:goldblock", "default:wood", 8, 2, 4, data, a)
            elseif tag == 'highway=tertiary' then
                builder.buildRoad(way, "default:cobble", "default:pine_wood", 7, 2, 3, data, a)
            elseif tag == 'highway=residential' then
                builder.buildRoad(way, "default:wood", "default:leaves", 5, 1, 2, data, a)
            elseif tag == 'highway=service' then
                builder.buildRoad(way, "default:stone", "default:brick", 4, 1, 2, data, a)
            elseif tag == 'highway=unclassified' then
                builder.buildRoad(way, "default:gravel", "default:stone", 6, 2, 3, data, a)
            elseif tag == 'highway=track' then
                builder.buildRoad(way, "default:dirt", "default:gravel", 4, 1, 2, data, a)
            elseif tag == 'highway=path' then
                builder.buildRoad(way, "default:leaves", "default:wood", 3, 1, 1, data, a)
            elseif tag == 'highway=cycleway' then
                builder.buildRoad(way, "wool:blue", "default:wood", 3, 1, 1, data, a)
            elseif tag == 'highway=footway' then
                builder.buildRoad(way, "default:brick", "default:stone", 3, 1, 1, data, a)
            elseif tag == 'highway=pedestrian' then
                builder.buildRoad(way, "default:sandstone", "default:brick", 5, 2, 3, data, a)
            elseif tag == 'highway=bridleway' then
                builder.buildRoad(way, "default:dirt_with_dry_grass", "default:wood", 4, 1, 1, data, a)
            elseif tag == 'highway=living_street' then
                builder.buildRoad(way, "default:clay", "default:brick", 5, 2, 3, data, a)
            elseif tag == 'highway=construction' then
                builder.buildRoad(way, "default:desert_stone", "default:wood", 4, 1, 2, data, a)

            --railway
            elseif tag == 'railway=rail' then
                builder.buildway(way, "carts:rail", 1, data, a)
            elseif tag == 'railway=subway' then
            builder.buildway(way, "carts:rail", 1, data, a)
            end
        end
    end
end



function planBuild.buildLanduse(ways, data, a, name)
    local last_reported_percentage = 0
    for i, way in pairs(ways) do
        local percentage = math.floor((i / #ways) * 100)
        if percentage >= last_reported_percentage + 10 then
            core.chat_send_player(name, "Building Landuse [2/4]: " .. percentage .. "% complete")
            last_reported_percentage = percentage
        end

        for _, tag in pairs(way['tags']) do
            -- Landuse
            if tag == 'landuse=residential' then
                builder.buildarea(way, "default:stone",0,false, data, a)
            elseif tag == 'landuse=industrial' then
                builder.buildarea(way, "default:steelblock",0,false, data, a)
            elseif tag == 'landuse=commercial' then
                builder.buildarea(way, "default:goldblock",0,false, data, a)
            elseif tag == 'landuse=retail' then
                builder.buildarea(way, "default:bronzeblock",0,false, data, a)
            elseif tag == 'landuse=forest' then
                builder.buildarea(way, "default:dirt",0,false, data, a)
            elseif tag == 'landuse=farmland' then
                builder.buildarea(way, "default:dirt_with_dry_grass",0,false, data, a)
            elseif tag == 'landuse=recreation_ground' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)
            elseif tag == 'landuse=grass' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)
            elseif tag == 'landuse=meadow' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)
            elseif tag == 'landuse=railway' then
                builder.buildarea(way, "default:gravel",0,false, data, a)

            -- Natura
            elseif tag == 'natural=wood' then
                builder.buildarea(way, "default:dirt",0,false, data, a)
            elseif tag == 'natural=grassland' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)
            elseif tag == 'natural=meadow' then
                builder.buildarea(way, "default:dry_grass",0,false, data, a)
            elseif tag == 'natural=water' then
                builder.buildarea(way, "default:water_source",0,false, data, a)
            elseif tag == 'natural=wetland' then
                builder.buildarea(way, "default:clay",0,false, data, a)

            -- Leisure
            elseif tag == 'leisure=park' then
                builder.buildarea(way, "default:leaves",0,false, data, a)
            elseif tag == 'leisure=garden' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)
            elseif tag == 'leisure=playground' then
                builder.buildarea(way, "default:wood",0,false, data, a)
            elseif tag == 'leisure=stadium' then
                builder.buildarea(way, "default:cobble",0,false, data, a)
            elseif tag == 'leisure=pitch' then
                builder.buildarea(way, "wool:dark_green",0,false, data, a)
            elseif tag == 'leisure=sports_centre' then
                builder.buildarea(way, "default:dirt_with_grass",0,false, data, a)

            -- Amenity
            elseif tag == 'amenity=school' then
                builder.buildarea(way, "default:brick",0,false, data, a)
            elseif tag == 'amenity=graveyard' then
                builder.buildarea(way, "default:desert_stone",0,false, data, a)
            elseif tag == 'amenity=park' then
                builder.buildarea(way, "default:grass",0,false, data, a)
            elseif tag == 'amenity=parking' then
                builder.buildarea(way, "default:gravel",0,false, data, a)
            elseif tag == 'amenity=marketplace' then
                builder.buildarea(way, "default:sand",0,false, data, a)
            end
        end
    end
end


return planBuild