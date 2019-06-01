require("/scripts/vec2.lua")
require("/scripts/rect.lua")
require("/scripts/util.lua")
require("/follower/scripts/handlers.lua")
-- main script for the monster

function init()
    assignHandlers()
    followID = config.getParameter("followID")
    hoverParams = config.getParameter("hoverParams") --offset, amplitude, phase multiplier
    spriteName = config.getParameter("spriteName", "example") -- defaults to the evil snowb
    if not followID then
        sb.logError("No followID specified!")
        shouldDieB = true -- kill it as soon as possible
        return
    end
    sprite = root.assetJson(string.format("/follower/sprites/%s/sprite.json", spriteName))[1]
    animator.setGlobalTag("main", sprite)
    currentFacingDir = 1
    lastFacingDir = 1
    shouldDieB = false
    message.setHandler("despawn", function(_,_,_) -- despawns the follower if called
        shouldDieB = true
    end)
end

function update(dt) -- might be unoptimised as shit but it gets the job done (i think)
    if (followID and hoverParams) and not shouldDieB then -- assumes hoverParams has all the parameters inside of it, so make it so
        if not world.entityExists(followID) then -- should failsafe against the entity exiting the render distance
            followID = config.getParameter("playerID") -- grabs the default value
        end
        mcontroller.setVelocity({0,0}) -- removes jittering
        mcontroller.controlParameters({gravityEnabled = false}) -- removes jittering
        local anchoredPos = world.entityPosition(followID) -- gets the position of the anchored entity
        if not anchoredPos then -- if it doesn't exist, end update()
            return
        end
        lastAnchoredPos = lastAnchoredPos or anchoredPos -- creates lastAnchored pos if it doesn't exist already. Essential for checking facing directions
        if not (anchoredPos[1]-lastAnchoredPos[1] == 0) then
            currentFacingDir = util.toDirection(anchoredPos[1]-lastAnchoredPos[1]) -- calculates the current facing direction
        end
        if currentFacingDir ~= lastFacingDir then
            local toFlip = currentFacingDir==1 and "?flipx" or ""
            animator.setGlobalTag("main", sprite..toFlip) -- flips the sprite if necessary
        end
        mcontroller.setPosition(vec2.add( -- set the position finally
            anchoredPos,
            {
                hoverParams.offset[1]*currentFacingDir,
                hoverParams.offset[2] + hoverParams.amplitude*math.sin(os.clock() * hoverParams.phaseMultiplier)
            }
        ))
        lastAnchoredPos = anchoredPos -- updates this at the very end of all calculations
        lastFacingDir = currentFacingDir -- same
    end
end

function uninit()

end

function shouldDie()
    return shouldDieB
end