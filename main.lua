function love.load()
    wf = require 'libraries/windfield/windfield'

    --WINDFIELD : 1st step, always create a World
    world = wf.newWorld(0, 800, false)--Gravity on X and Y, Bodies allowed to sleep (cf love.physics.newWorld on wiki LOVE2D)
    world:setQueryDebugDrawing(true)-- DEBUG DRAWING QUERY ZONES

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}} ]])
    world:addCollisionClass('Danger')

    -- WINDFIELD : Create a Collider player. Combine Body, Fixture and Shape
    -- Reminder: Physics object = Collider.
    -- Params: X, Y, W, H, Type
    player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "Player"})
    player:setFixedRotation(true)--Collider cannot rotate when falling
    player.speed = 240

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    -- Type(Dynamic (by default), Static, Kinematic )
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType("static")
end

function love.update(dt)
    --WINDFIELD: World Update
    world:update(dt)

    if player.body then --IF IS SET PLAYER
        local px, py = player:getPosition()--Will put X and Y positions  right in the local var px and py !
        if love.keyboard.isDown("d") then --MOVE RIGHT
            player:setX(px + player.speed * dt)
        end
        if love.keyboard.isDown("q") then --MOVE LEFT
            player:setX(px - player.speed * dt)
        end

        --IF PLAYER COLLIDE WITH A "DANGER" TAGGED COLLIDABLE THEN...
        if player:enter("Danger") then
            player:destroy()
        end
    end

end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == "z" then
        --QUERY SEARCHING FOR A PLATFORM UNDER THE PLAYER FOR AUTHORIZATION TO JUMP ONLY FROM THE GROUND, AND NOT IN THE AIR
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'Platform'})
        if #colliders > 0 then
            player:applyLinearImpulse(0, -7000)--Impulse on X, Y
        end
        
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})--X, Y, Radius, {Collection of collision_class to be queryed}

        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end
