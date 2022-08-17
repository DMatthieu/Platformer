function love.load()

    anim8 = require 'libraries/anim8/anim8'

    sprites = {}
    sprites.playerSheet = love.graphics.newImage("sprites/playerSheet.png")

    --PARAMS: Dimensions of each cell on the grid (x, y), width and height of spritesheet.png
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)--1-15 = Cellule 1 à 15 de la spritesheet. ",1" = sur la ligne 1 de la Spritesheet, 
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.05)--1-15 = Cellule 1 à 15 de la spritesheet. ",1" = sur la ligne 1 de la Spritesheet, 
    animations.run = anim8.newAnimation(grid('1-15',3), 0.05)--1-15 = Cellule 1 à 15 de la spritesheet. ",1" = sur la ligne 1 de la Spritesheet, 

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
    player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
    player:setFixedRotation(true)--Collider cannot rotate when falling
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.direction = 1--"1" facing right. "-1" facing left
    player.grounded = true

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
        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
        if #colliders > 0 then
            player.grounded = true
        else 
            player.grounded = false
        end

        player.isMoving = false
        local px, py = player:getPosition()--Will put X and Y positions  right in the local var px and py !
        if love.keyboard.isDown("d") then --MOVE RIGHT
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown("q") then --MOVE LEFT
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end

        --IF PLAYER COLLIDE WITH A "DANGER" TAGGED COLLIDABLE THEN...
        if player:enter("Danger") then
            player:destroy()
        end
    end

    if player.grounded then
        if player.isMoving then 
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump    
    end
    player.animation:update(dt)--In order to permit to our Animation Object to updated during time

end

function love.draw()
    world:draw()

    local px, py = player:getPosition()

    --We multiply the x scale by player direction in order to flip or unflip the sprite orientation (moving left or right)
    player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)--In order to permit to our Animation Object to drawed during time
end

function love.keypressed(key)
    if key == "z" then
        --QUERY SEARCHING FOR A PLATFORM UNDER THE PLAYER FOR AUTHORIZATION TO JUMP ONLY FROM THE GROUND, AND NOT IN THE AIR
        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
        if player.grounded then
            player:applyLinearImpulse(0, -4000)--Impulse on X, Y
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
