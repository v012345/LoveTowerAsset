---@class EntityManager
---@field enemies Enemy[]
---@field towers Tower[]
---@field bullets Bullet[]
EntityManager = EntityManager or {}

function EntityManager:load()
    self.enemies = {}
    self.towers = {}  -- 所有塔
    self.bullets = {} -- 所有子弹
end

function EntityManager:update(dt)
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e:update(dt)
        if e.reachedEnd then
            Game.lives = Game.lives - 1
            table.remove(self.enemies, i)
        elseif e.dead then
            Game.money = Game.money + Game.KILL_REWARD
            table.remove(self.enemies, i)
        end
    end

    for _, tower in ipairs(self.towers) do
        tower:update(dt, self.enemies)
    end

    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt)
        if bullet.dead then
            table.remove(self.bullets, i)
        end
    end
end

function EntityManager:draw()
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    for _, tower in ipairs(self.towers) do
        tower:draw()
    end
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

function EntityManager:destroy()
end

function EntityManager:getEnemyCount()
    return #self.enemies
end

---@param entity IEntity
function EntityManager:addEntity(entity)
    if entity.isEnemy then
        self.enemies[#self.enemies + 1] = entity
    elseif entity.isTower then
        self.towers[#self.towers + 1] = entity
    elseif entity.isBullet then
        self.bullets[#self.bullets + 1] = entity
    end
end

return EntityManager
