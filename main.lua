function love.load()
    wf = require 'libraries/windfield/windfield'

    --WINDFIELD : 1st step, always create a World
    world = wf.newWorld(0, 800)--Gravity on X and Y

    -- WINDFIELD : Create a Collider player. Combine Body, Fixture and Shape
    -- Reminder: Physics object = Collider.
    -- Params: X, Y, W, H, Type
    player = world:newRectangleCollider(360, 100, 80, 80)
    player.speed = 240
    platform = world:newRectangleCollider(250, 400, 300, 100)
    -- Type(Dynamic (by default), Static, Kinematic )
    platform:setType("static")


end

function love.update(dt)
    --WINDFIELD: World Update
    world:update(dt)

    local px, py = player:getPosition()--Will put X and Y positions  right in the local var px and py !
    if love.keyboard.isDown("d") then
        player:setX(px + player.speed * dt)
    end
    if love.keyboard.isDown("q") then
        player:setX(px - player.speed * dt)
    end

end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == "z" then
       player:applyLinearImpulse(0, -7000)--Impulse on X, Y
    end
end
