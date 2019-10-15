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

function idFromList(ind)
    if miscCanvas.spcLayout ~= "playerQuery" then
        commandCanvas:addText("listPlayers wasn't called.")
        return
    end
    if tonumber(ind) == nil then
        commandCanvas:addText("Argument isn't a number.")
        return
    end
    local l = tonumber(ind)
    local query = deepCopy(miscCanvas.tempStorage) -- get a copy of the stored player ids
    local id = query[l]
    if not id then
        commandCanvas:addText("Out of bounds.")
        return
    end
    if not world.entityExists(id) then
        commandCanvas:addText("Player not found.")
        return
    end
    return id
end

function pageConverter(canvas, array) -- snips an array of strings into an array of arrays of strings dependant on the canvas line size
    local availableLines = canvas:maxLines()
    local pageCount = math.ceil(#array/availableLines)
    local pageStorage = {}
    for page = 1, pageCount do
        pageStorage[#pageStorage+1] = {}
        for i=1, availableLines do
            pageStorage[page][i] = array[i+availableLines*(page-1)] or ""
        end
    end
    return pageStorage
end

commands.thighs = {
    desc = "The old classic.",
    func = function(args)
        commandCanvas:addText("Thigh Fan Club!")
    end
}

--[[
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
]]

commands.help = {
    desc = "Lists all commands.",
    func = function(args)
        commandCanvas:clearText()
        local commandCount = 0
        local names = {} -- have to dump the names into an array of strings for this to work
        for name, params in pairs(commands) do
            names[#names+1] = name
            commandCount = commandCount + 1
        end
        commandCanvas:specialLayout("help", {}, "Help", pageConverter(commandCanvas, names))
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

commands.ls = {
    desc = "Lists nearby players.",
    func = function(args)
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 1000, {order = "nearest"})
        local toStore = {}
        for i=1, miscCanvas:maxLines() do
            local toPrint = plQuery[i] and string.format("%i. %s", i, world.entityName(plQuery[i])) or ""
            miscCanvas:addText(toPrint)
            toStore[#toStore+1] = plQuery[i]
        end
        miscCanvas:specialLayout("playerQuery", toStore, "Player Listing")
    end
}

commands.followerFollowPlayer = {
    desc = "Changes the anchored entity. Do 'listPlayers' beforehand.",
    usage = "<Player Index (from listPlayers)>",
    func = function(args) 
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if target then
            local r = world.sendEntityMessage(player.id(), "followerSetFollowID", target):result()
            commandCanvas:addText("Now following: ".. world.entityName(target))
        end
    end
}

commands.nuke = {
    desc = "Nuke a fucker.",
    usage = "<Player Index (from listPlayers)",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if not target then
            return
        end
        world.sendEntityMessage(player.id(), "nuke", target)
        commandCanvas:addText("Nuked.")
    end
}

commands.warp = {
    desc = "Nuke a fucker.",
    usage = "<Player Index (from listPlayers)",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if not target then
            return
        end
        world.sendEntityMessage(target, "warp", "instanceworld:outpost")
        commandCanvas:addText("Warped to outpost.")
    end
}

commands.nukeMisc = {
    desc = "Let's do the limbo",
    func = function(args)
        local vehiQuery = world.entityQuery(world.entityPosition(player.id()), 1000, {includedTypes={"vehicle", "monster", "npc", "stagehand", "itemDrop"}})
        for i, id in pairs(vehiQuery) do
            world.sendEntityMessage(player.id(), "limbo", id)
        end
    end
}

commands.nukeProj = {
    desc = "Let's do the limbo",
    func = function(args)
        local vehiQuery = world.entityQuery(world.entityPosition(player.id()), 1000, {includedTypes={"projectile"}})
        for i, id in pairs(vehiQuery) do
            world.sendEntityMessage(player.id(), "limbo", id)
        end
    end
}

commands.cameraFocus = {
    desc = "Drop a fucker.",
    usage = "<Player Index (from listPlayers)",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if not target then
            commandCanvas:addText("Not found.")
            return
        end
        world.sendEntityMessage(player.id(), "setCameraFocusEntity", {target})
        commandCanvas:addText("Done.")
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

commands.savePerson = {
    desc = "Saves the name and UUID of a given character.",
    usage = "<Player Index (from listPlayers)",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if not target then
            return
        end
        local tgUuid = world.entityUniqueId(target)
        local savedDatabase = status.statusProperty("fB_personsDatabase", {})
        if not savedDatabase[tgUuid] then
            savedDatabase[tgUuid] = world.entityName(target) -- key: uuid, value: name. UUID is more unique than the name of an entity so im using it as keys
        else
            commandCanvas:addText(string.format("Player last known as: %s^reset;. Updated.", savedDatabase[tgUuid]))
            savedDatabase[tgUuid] = world.entityName(target)
        end
        status.setStatusProperty("fB_personsDatabase", savedDatabase)
        commandCanvas:addText("Saved.")
    end
}

commands.lsdb = {
    desc = "Lists saved players.",
    func = function(args)
        local savedDatabase = status.statusProperty("fB_personsDatabase", {})
        local nameArray = {}
        local uuidArray = {}
        for uuid, name in pairs(savedDatabase) do
            local currentEntry = nameArray[#nameArray+1]
            currentEntry = string.format("%i. %s", #nameArray, name)
            uuidArray[#uuidArray+1] = uuid
        end
        miscCanvas:specialLayout("savedPlayerList", uuidArray, "Saved Player List", pageConverter(miscCanvas, nameArray))
    end
}

commands.test1 = {
    desc = "Lists saved players.",
    func = function(args)

    end
}

commands.test2 = {
    desc = "Lists saved players.",
    func = function(args)

    end
}

commands.page = { -- note: errors misalign the page again, removing the special layout.
    desc = "Page desc",
    usage = "<page (int)> <canvas>",
    func = function(args)
        if #args > 2 then
            commandCanvas:addText("Incorrect number of arguments.")
            return
        end
        local page = tonumber(args[1])
        if not page then
            commandCanvas:addText("The second argument isn't a number")
            return
        end
        local canvas
        local specialLayoutCount = {} -- fuck you
        for i, canvasName in ipairs(canvases) do
            if _ENV[canvasName.."Canvas"].pages then
                specialLayoutCount[#specialLayoutCount+1] = canvasName.."Canvas"
            end
        end
        if #specialLayoutCount > 1 then
            if args[2]:lower() == "command" or args[2]:lower() == "commands" then
                canvas = commandCanvas
            elseif args[2]:lower() == "misc" then
                canvas = miscCanvas
            else
                commandCanvas:addText("Canvas doesn't exist. Try 'commands' or 'misc'.")
                return
            end
        else
            canvas = _ENV[specialLayoutCount[1]]
        end
        if not canvas.pages then
            commandCanvas:addText("This special layout doesn't contain more pages.")
            return
        end
        if not canvas.pages[page] then
            commandCanvas:addText("Page doesn't exist.")
            return
        end
        canvas:setPage(page)
    end
}

commands.hidePlayer = {
    desc = "Hides the player character (dll)",
    usage = "<Hide (0/1)>",
    func = function(args)
        if not #args == 1 then
            commandCanvas:addText("Invalid number of args.")
            return
        end
        if tonumber(args[1]) == nil then
            commandCanvas:addText("Not a number.")
            return
        end
        world.sendEntityMessage(player.id(), "hide", tonumber(args[1]))
    end
}

commands.limbo = {
    desc = "Hides the player character (dll)",
    usage = "<Hide (0/1)>",
    func = function(args)
        if #args ~= 1 then
            commandCanvas:addText("Number of arguments is invalid. #args = "..#args)
            return
        end
        local target = idFromList(args[1])
        if not target then
            return
        end
        world.sendEntityMessage(player.id(), "limbo", target)
        commandCanvas:addText("Limbo'd.")
    end
}

commands.radioMsg = {
    desc = "Radio messages the person",
    usage = "<Player Index (from listPlayers)",
    func = function(args)
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 1000)
        local message = {
            messageId = sb.makeUuid(),
            unique = false,
            important = true,
            type = "generic",
            senderName = "",
            textSpeed = 30,
            persistTime = 4,
            text = table.concat(args, " ")
        }
        for i, id in ipairs(plQuery) do
            world.sendEntityMessage(id, "queueRadioMessage", message)
        end
        commandCanvas:addText("Sent.")
    end
}

commands.grabUUIDs = {
    desc = "Stores UUIDs into logs.",
    func = function(args)
        local plQuery = world.playerQuery(world.entityPosition(player.id()), 1000)
        for i, id in ipairs(plQuery) do
            sb.logInfo(string.format("Player: %s; UUID: %s", removeHexColors(world.entityName(id)), world.entityUniqueId(id)))
        end
        commandCanvas:addText("Grabbed.")
    end
}

commands.corruptPlace = {
    desc = "Spawns monsters in bulk.",
    func = function(args)
        local bodypart = {
            properties = {
                image = "/assetmissing.png",
                fullbright = true
            }
        }
        -- for a poptop
        local parameters = {
            persistent = true,
            keepAlive = true,
            scripts = jarray(),
            initialScriptDelta = 0,
            scale = 1,
            renderLayer = "FrontParticle+100",
            movementSettings = {
                gravityMultiplier = 0,
                mass = math.huge,
                airFriction = math.huge,
                speedLimit = 0,
                gravityEnabled = false,
                restDuration = math.huge,
                maxMovementPerStep = 0
            },
            statusSettings = {
                primaryScriptSources = jarray()
            },
            animationCustom = {
                animatedParts = {
                    parts = {
                        body = {
                            properties = {
                                transformationGroups = jarray(),
                            },
                            partStates = {
                                body= {
                                    idle = bodypart,
                                    walk = bodypart,
                                    run = bodypart,
                                    stroll = bodypart,
                                    jump = bodypart,
                                    fall = bodypart,
                                    chargewindup = bodypart,
                                    chargewinddown = bodypart,
                                    charge = bodypart,
                                    },
                                    damage= {
                                    stunned=bodypart,
                                }
                            }
                        }
                    }
                }
            }
        }
        for i = 1, 1250, 1 do
			world.spawnMonster("symbiotecritter", world.entityPosition(player.id()),
                {level = world.threatLevel(), keepAlive = true, aggressive = true, persistent = false, uniqueId = sb.makeUuid(), scale = 0.01}
            ) --(32)
			world.spawnMonster("adultpoptop", world.entityPosition(player.id()),
                {level = world.threatLevel(), keepAlive = true, aggressive = true, persistent = false, uniqueId = sb.makeUuid(), scale = 0.01}
            ) --(32)
        end
        commandCanvas:addText("Placed fuckers.")
    end
}