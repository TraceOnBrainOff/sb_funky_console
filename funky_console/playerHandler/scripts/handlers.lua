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
    sb.logInfo(string.format("Deployment handlers loaded: %s", table.concat(toPrint, ", ")))
end

handlers = {}

--[[
handlers.example = { -- the key of the table is the entityMesage key
    func = function(a) -- add as many as you need, the constructor works with all argument numbers

    end
}
]]

handlers.spawnFollower = {
    func = function()
        if storage.followerID then
            exists = world.entityExists(storage.followerID)
            if not exists then
                storage.followerID = nil -- continue normally
            else
                return "Entity already exists."
            end
        end
        local conf = root.assetJson("/follower/config.config")
        conf.followID = player.id()
        conf.playerID = player.id() -- a default to return to in case the bot loses the following entity
        local hoverParams = status.statusProperty("followerHoverParams", {})
        hoverParams.offset = hoverParams.offset or {-2,0}
        hoverParams.amplitude = hoverParams.amplitude or 1
        hoverParams.phaseMultiplier = hoverParams.phaseMultiplier or 1
        conf.hoverParams = hoverParams
        conf.spriteName = status.statusProperty("followerSpriteName", "example")
        storage.followerID = world.spawnMonster("snowbcritter", world.entityPosition(player.id()), conf) -- global gets saved into the memory of the deployment script
        return "Done."
    end
}

handlers.followerSay = {
    func = function(toSay)
        if followerExists() then
            world.sendEntityMessage(storage.followerID, "say", toSay)
        end
    end
}

handlers.followerSetOffset = {
    func = function(pos)
        if followerExists() then
            world.sendEntityMessage(storage.followerID, "setOffset", pos)
        end
    end
}

handlers.followerSetAmplitude = {
    func = function(a)
        if followerExists() then
            if tonumber(a)==nil then
                sb.logError("Incorrect value type")
                return
            end
            world.sendEntityMessage(storage.followerID, "setAmplitude", a)
        end
    end
}

handlers.followerSetPhaseMultiplier = {
    func = function(a)
        if followerExists() then
            if tonumber(a)==nil then
                sb.logError("Incorrect value type"..type(a))
                return
            end
            world.sendEntityMessage(storage.followerID, "setPhaseMultiplier", a)
        end
    end
}

handlers.followerSetSprite = {
    func = function(a)
        if followerExists() then
            world.sendEntityMessage(storage.followerID, "setSprite", a)
        end
    end
}

handlers.followerSetFollowID = {
    func = function(id)
        if followerExists() then
            if tonumber(id)==nil then
                return "Incorrect value type"
            end
            return world.sendEntityMessage(storage.followerID, "setFollowID", tonumber(id)):result()
        end
    end
}

handlers.test = {
    func = function(a, b)
        sb.logInfo(string.format("a = %s;   b = %s", a, b)) -- args work properly!
    end
}