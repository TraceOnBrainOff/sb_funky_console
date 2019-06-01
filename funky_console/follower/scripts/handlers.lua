function assignHandlers()
    if not handlers then
        sb.logError("The handler table doesn't exist.")
        return
    end
    local toPrint = {}
    for name, params in pairs(handlers) do
        toPrint[#toPrint+1] = name
        message.setHandler(name, function(_, sameClient, ...)
            return params.func(...)
        end)
    end
    sb.logInfo(string.format("Monster handlers loaded: %s", table.concat(toPrint, ", ")))
end

handlers = {}

--[[
handlers.example = { -- the key of the table is the entityMesage key
    func = function(a) -- add as many as you need, the constructor works with all argument numbers

    end
}
]]

handlers.setFollowingPlayer = {
    func = function(id)
        --followID < param
        id = tonumber(id)
        if not id then
            return "ID not specified or is of an invalid type."
        end
        if not world.entityExists(id) then
            return "Entity doesn't exist."
        end
        followID = id
        return "Done"
    end
}

handlers.say = {
    func = function(toSay)
        if toSay ~= "" then
            monster.say(toSay)
        end
    end
}

handlers.setOffset = {
    func = function(pos)
        hoverParams.offset = pos
    end
}

handlers.setAmplitude = {
    func = function(a)
        hoverParams.amplitude = a
    end
}

handlers.setPhaseMultiplier = {
    func = function(a)
        hoverParams.phaseMultiplier = a
    end
}

handlers.setSprite = {
    func = function(spr)
        spriteName = spr
        sprite = root.assetJson(string.format("/follower/sprites/%s/sprite.json", spriteName))[1]
        animator.setGlobalTag("main", sprite)
    end
}

handlers.setFollowID = {
    func = function(id)
        followID = id
        return "Set."
    end
}

handlers.test = {
    func = function(a, b)
        sb.logInfo(string.format("a = %s;   b = %s", a, b)) -- args work properly!
    end
}