print("This file will be run at load time!")
local mp = minetest.get_modpath(minetest.get_current_modname())
local wp = core.get_worldpath()

local xmlparser = dofile(mp.."/xmlparser/xmlparser.lua")
local processor = dofile(mp.."/process.lua")
local builder = dofile(mp.."/builder.lua")
local planBuild = dofile(mp.."/planBuild.lua")

core.register_chatcommand("generate", {
    func = function(name, param)
        filename = param 
        local doc, err = xmlparser.parseFile(wp.."/"..filename, nil)

        if doc~=nil then
            print("Begin Generation")
            nodes, ways, bounds = processor(doc,name)

            planBuild.buildall(nodes,ways,bounds,name)
        else
            core.chat_send_player(name, "Error File not found")
        end

        if err then
            print(err .. '\n')
        end

    end,
})


