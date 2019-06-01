require("/scripts/vec2.lua")
require("/scripts/rect.lua")
require("/playerHandler/scripts/handlers.lua")

local oldInit = init -- Starbound is doodoo and requires the calling of the original unspecified deployment script init so that all other ones don't crash. Backwards compatibility with other mods is important.

function init()
    oldInit()
    assignHandlers() -- from handlers.lua
end

function update()

end

function uninit()

end

function followerExists()
    if storage.followerID and world.entityExists(storage.followerID) then
        return true
    end
    return false
end