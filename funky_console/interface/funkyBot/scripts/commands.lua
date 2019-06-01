commands = {}

--[[
    commands.example = { -- thing after the dot is the name
        desc = "This is what is returned when you do helpWith",
        usage = "<Name>" -- What gets returned by howToUse is: "example <Name>"
        func = function(args) -- function that gets called. args is an array of strings
            commandCanvas:addText("Hello World!")
        end
    }
]]

commands.thighs = {
    desc = "The old classic.",
    func = function(args)
        commandCanvas:addText("Thigh Fan Club!")
    end
}

commands.help = {
    desc = "Lists all commands.",
    usage = "[<page>]",
    func = function(args)
        local page = args[1] and (tonumber(args[1]) and tonumber(args[1]))
        if not page then page = 1 end
        commandCanvas:clearText()
        local availableLines = commandCanvas:maxLines() - 1 -- 140/7 - 1 = 19 with current sizes. Minus one because the first line is for page numbers and help description
        local commandCount = 0
        local names = {} -- have to dump the names into an array of strings for this to work
        for name, params in pairs(commands) do
            names[#names+1] = name
            commandCount = commandCount + 1
        end
        local pageCount = math.ceil(commandCount/availableLines)
        commandCanvas:addText(string.format("help <page>. Page %i out of %i", page, pageCount))
        for i=(availableLines*(page-1)+1), availableLines*page do
            local name = names[i]
            commandCanvas:addText(name and name or "")
        end
    end
}

commands.helpWith = {
    desc = "Returns the description of a command.",
    usage = "<Name>",
    func = function(args)
        if not args[1] then
            commandCanvas:addText("No command specified.")
            return
        end
        if not commands[args[1]] then
            commandCanvas:addText("Command doesn't exist.")
            return
        end
        commandCanvas:addText(string.format("Description for %s", args[1]))
        commandCanvas:addText(commands[args[1]].desc)
    end
}

commands.clear = {
    desc = "Clears the console.",
    usage = "[<Canvas>]",
    func = function(args)
        if not args[1] then
            commandCanvas:clearText()
            miscCanvas:clearText()
        else
            if string.lower(args[1]) == "misc" then
                miscCanvas:clearText()
            elseif string.lower(args[1]) == "commands" or string.lower(args[1]) == "command" then
                commandCanvas:clearText()
            end
        end
    end
}

commands.setColors = {
    desc = "Sets the colors.",
    usage = "<Hex Light Color (No alpha)> <Hex Dark Color (No alpha)>",
    func = function(args)
        if not args[1] or not args[2] then
            commandCanvas:addText("Invalid number of arguments.")
            return
        end
        if args[1]:len() ~= 6 or args[2]:len() ~= 6 then
            commandCanvas:addText("Hex codes have the wrong length. (Not 6).")
            return
        end
        local lightest, darkest = hexToRGB(args[1]), hexToRGB(args[2])
        local redDiff = math.abs(lightest[1]-darkest[1])
        local greenDiff = math.abs(lightest[2]-darkest[2])
        local blueDiff = math.abs(lightest[3]-darkest[3])
        local avr = (redDiff + greenDiff + blueDiff) / 3
        if avr < 75 then
            commandCanvas:addText("The contrast is too low. Current at: "..avr)
            return
        end
        status.setStatusProperty("funkyBotColor", {lightest, darkest})
        color:updateColors({lightest, darkest})
        setInterfaceColors()
    end
}

commands.resetColors = {
    desc = "Resets the colors to the default values.",
    func = function(args)
        status.setStatusProperty("funkyBotColor", {{200,200,200}, {60,60,60}})
        color:updateColors({{200,200,200}, {60,60,60}})
        setInterfaceColors()
        commandCanvas:addText("Colors reset.")
    end
}

commands.sEM = { -- Warning, this sends args as strings no matter what, so conversions need to be done on the handler side!
    desc = "Sends an entityMessage to the player.",
    usage = "<Key> [<Args(...)>]",
    func = function(args)
        if #args == 0 then
            commandCanvas:addText("No key specified.")
            return
        end
        local handlerName = args[1]
        table.remove(args, 1)
        world.sendEntityMessage(player.id(), handlerName, table.unpack(args))
        commandCanvas:addText("Sent.")
    end
}

commands.spawnFollower = {
    desc = "Spawns a follower drone.",
    func = function(args)
        local result = world.sendEntityMessage(player.id(), "spawnFollower"):result()
        if not result then
            return
        end
        commandCanvas:addText(result)
    end
}

commands.followerSay = {
    desc = "Makes the follower say things.",
    usage = "<toSay>",
    func = function(args)
        world.sendEntityMessage(player.id(), "followerSay", table.concat(args, " "))
        commandCanvas:addText("Done.")
    end
}

commands.followerSetOffset = {
    desc = "Sets the hovering offset from the anchored entity for the follower.",
    usage = "<x> <y>",
    func = function(args)
        if not (#args >= 2) then
            commandCanvas:addText("Too few arguments.")
            return
        end
        if tonumber(args[1])==nil or tonumber(args[2])==nil then
            commandCanvas:addText("Incorrect value types.")
            return
        end
        local hoverParams = status.statusProperty("followerHoverParams", {})
        hoverParams.offset = {tonumber(args[1]),tonumber(args[2])}
        status.setStatusProperty("followerHoverParams", hoverParams)
        world.sendEntityMessage(player.id(), "followerSetOffset", {tonumber(args[1]), tonumber(args[2])})
        commandCanvas:addText("Set.")
    end
}

commands.followerSetAmplitude = {
    desc = "Sets the hovering amplitude for the follower.",
    usage = "<Amplitude>",
    func = function(args)
        if not (#args >= 1) then
            commandCanvas:addText("Too few arguments.")
            return
        end
        if not tonumber(args[1]) then
            commandCanvas:addText("Incorrect value types.")
            return
        end
        local hoverParams = status.statusProperty("followerHoverParams", {})
        hoverParams.amplitude = tonumber(args[1])
        status.setStatusProperty("followerHoverParams", hoverParams)
        world.sendEntityMessage(player.id(), "followerSetAmplitude", tonumber(args[1]))
        commandCanvas:addText("Set.")
    end
}

commands.followerSetPhaseMultiplier = {
    desc = "Sets the hovering amplitude for the follower.",
    usage = "<Phase Multiplier>",
    func = function(args)
        if not (#args >= 1) then
            commandCanvas:addText("Too few arguments.")
            return
        end
        if not tonumber(args[1]) then
            commandCanvas:addText("Incorrect value types.")
            return
        end
        local hoverParams = status.statusProperty("followerHoverParams", {})
        hoverParams.phaseMultiplier = tonumber(args[1])
        status.setStatusProperty("followerHoverParams", hoverParams)
        world.sendEntityMessage(player.id(), "followerSetPhaseMultiplier", tonumber(args[1]))
        commandCanvas:addText("Set.")
    end
}

commands.followerSetSprite = {
    desc = "Resprites the follower.",
    usage = "<spriteName (folder name)>",
    func = function(args)
        if not (#args >= 1) then
            commandCanvas:addText("Too few arguments.")
            return
        end
        status.setStatusProperty("followerSpriteName", args[1])
        world.sendEntityMessage(player.id(), "followerSetSprite", args[1])
        commandCanvas:addText("Set.")
    end
}

commands.followerFollowPlayer = {
    desc = "Changes the anchored entity.",
    usage = "<Player Name>",
    func = function(args)
        if not (#args >= 1) then
            commandCanvas:addText("Too few arguments.")
            return
        end
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 100)
        local foundID
        for i, id in ipairs(plQuery) do
            if string.lower(removeHexColors(world.entityName(id))) == string.lower(args[1]) then
                foundID = id
            end
        end
        if foundID then
            commandCanvas:addText(string.format("Assigned to: %s", world.entityName(foundID)))
            world.sendEntityMessage(player.id(), "followerSetFollowID", foundID)
            return
        end
        commandCanvas:addText("Player not found.")
    end
}

commands.listPlayers = {
    desc = "Lists the nearby players.",
    func = function(args)
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 1000, {order = "nearest"})
        for i=1, miscCanvas:maxLines() do
            local toPrint = plQuery[i] and string.format("%i. %s", i, world.entityName(plQuery[i])) or ""
            miscCanvas:addText(toPrint)
        end
        miscCanvas:specialLayout("playerQuery")
    end
}

commands.followerFollowPlayer = {
    desc = "Changes the anchored entity. Do 'listPlayers' beforehand.",
    usage = "<Player Index (from listPlayers)>",
    func = function(args) 
        if miscCanvas.spcLayout ~= "playerQuery" then
            commandCanvas:addText("listPlayers wasn't called.")
            return
        end
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        if tonumber(args[1]) == nil then
            commandCanvas:addText("Argument isn't a number.")
            return
        end
        local l = tonumber(args[1])
        local query = deepCopy(miscCanvas.textStorage) -- get a copy of the stored players in misc canvas
        local line = query[l]
        if not line then
            commandCanvas:addText("Out of bounds.")
            return
        end
        if not string.find(line, "%p") then
            commandCanvas:addText("Out of bounds.")
            return
        end
        local playerName = string.sub(line, (string.find(line, "%p")+2)) -- %p gets the position of the dot, so +2 jumps over the dot and the space.
        sb.logInfo(playerName)
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 1000)
        local foundID = 0 -- players can't be ID 0, so defaulting to this is aight
        for i, id in ipairs(plQuery) do
            if world.entityName(id) == playerName then
                foundID = id
                break --jump out of the loop
            end
        end
        if foundID == 0 then
            commandCanvas:addText("Player not found.")
            return
        end
        local r = world.sendEntityMessage(player.id(), "followerSetFollowID", foundID):result()
        commandCanvas:addText("Now following: ".. world.entityName(foundID))
    end
}

commands.howToUse = {
    desc = "Displays what type of arguments a given command takes.",
    usage = "<Command Name>",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Invalid number of arguments")
            return
        end
        if not commands[args[1]] then
            commandCanvas:addText("Command doesn't exist")
            return
        end
        if not commands[args[1]].usage then
            commandCanvas:addText(string.format("%s doesn't take any arguments.", args[1]))
            return
        end
        commandCanvas:addText(string.format("%s %s", args[1], commands[args[1]].usage))
    end
}