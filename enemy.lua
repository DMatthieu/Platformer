enemies = {}

function spawnEnemy(x, y)
    --x, y, w, h, collision class tag
    local enemy = world:newRectangleCollider(x, y, 70, 90, {collision_class = "Danger"})
    enemy.direction = 1 --1 = Right | -1 = Left
    enemy.speed = 200

    table.insert(enemies, enemy)
end

function updateEnemies(dt)
    for i,e in ipairs(enemies) do
        local ex, ey = e:getPosition()

        --Change Direction Value
        --x, y, w, h, collision class tag
        local colliders = world:queryRectangleArea(ex + (40 * e.direction), ey + 40, 10, 10, { "Platform" })--40 = half of the width of the Enemy Collider
        --If no colliders detected then
        if #colliders == 0 then
            e.direction = e.direction * -1
        end

        --Updating X position
        e:setX(ex + e.speed * dt * e.direction)--Positive or negative depending on the "Direction" applied to the formula ( 1 or -1)
    end
end