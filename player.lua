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

    function playerUpdate(dt)
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

    function drawPlayer()
        local px, py = player:getPosition()
        --We multiply the x scale by player direction in order to flip or unflip the sprite orientation (moving left or right)
        player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)--In order to permit to our Animation Object to drawed during time
    end