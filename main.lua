function love.load()
    wf = require 'libraries/windfield/windfield'

    --WINDFIELD : 1st step, always create a World
    world = wf.newWorld(0, 800)--Gravity on X and Y

    -- WINDFIELD : Create a Collider player. Combine Body, Fixture and Shape
    -- Reminder: Physics object = Collider.
    -- Params: X, Y, W, H, Type
    player = world:newRectangleCollider(360, 100, 80, 80)
    platform = world:newRectangleCollider(250, 400, 300, 100)
    -- Type(Dynamic (by default), Static, Kinematic )
    platform:setType("static")


end

function love.update(dt)
    --WINDFIELD: World Update
    world:update(dt)

end

function love.draw()
    world:draw()
end
