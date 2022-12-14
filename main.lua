function love.load()

    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require('libraries.Simple-Tiled-Implementation/sti')
    cameraFile = require('libraries/hump/camera')

    cam = cameraFile()

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
    world:setQueryDebugDrawing(true)-- DEBUG: DRAWING QUERY ZONES

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}} ]])
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')

    

    -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    -- dangerZone:setType("static")

    platforms = {}

    loadMap()

    spawnEnemy(1260, 100)
end

function love.update(dt)
    --WINDFIELD: World Update
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)
    

    --MODE THAT MAKE CAMERA FOLLOW THE PLAYER ON X and Y VALUES
    -- local px, py = player:getPosition()
    -- cam:lookAt(px, py)
    
    --MODE THAT FOLLOW THE PLAYER BUT STAY FIXED ON MIDDLE OF THE SCREEN ON Y AXIS
    local px = player:getX()
    cam:lookAt(px, love.graphics.getHeight() / 2)
end

function love.draw()
    cam:attach()--Put things affected by the camera
        --TILED: Layer of tiled drawed to the screen
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        drawPlayer()
        world:draw()--DRAW HITBOXES. DRAW ALSO QUERY ZONES IF "setQueryDebugDrawing(true)" In fct love.load()
    cam:detach()--Everything after detach will not be affected by camera system.
    
    
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

--Load the map via Libray "Simple Tiled Implementation", iterates through the table in the level.lua file, 
-- and call SpawnPlatform function. 
function loadMap()
    gameMap = sti('maps/level1.lua')
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end

-- creates colliders at the given coordinates of the object given in params
function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        -- Type(Dynamic (by default), Static, Kinematic )
        platform:setType("static")  
        table.insert(platforms, platform)
    end
end
