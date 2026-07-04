---@class Enemy : IEntity
Enemy = Enemy or {}
Enemy.__index = Enemy

-- path: 路径点像素坐标列表（来自 Map:getPathPixels）
-- def:  敌人属性 { hp, speed, radius, color }
function Enemy.new(path, def)
    local self = setmetatable({}, Enemy)
    self.path = path
    self.x = path[1].x
    self.y = path[1].y
    self.nextNode = 2 -- 正在前往的路径点索引

    self.speed = def.speed or 120
    self.maxHp = def.hp or 100
    self.hp = self.maxHp
    self.radius = def.radius or 14
    self.color = def.color or { 1, 0.3, 0.3 }

    self.dead = false       -- 被打死
    self.reachedEnd = false -- 走到终点（漏怪）
    return self
end

function Enemy:update(dt)
    local node = self.path[self.nextNode]
    if not node then
        self.reachedEnd = true
        return
    end

    local dx, dy = node.x - self.x, node.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local step = self.speed * dt

    if step >= dist then -- 移动大于距离, 直接吸上去
        self.x, self.y = node.x, node.y
        self.nextNode = self.nextNode + 1
        if self.nextNode > #self.path then
            self.reachedEnd = true
        end
    else
        self.x = self.x + dx / dist * step
        self.y = self.y + dy / dist * step
    end
end

-- 受击：第四步塔的子弹会调它
function Enemy:hit(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        self.dead = true
    end
end

function Enemy:draw()
    local c = self.color
    love.graphics.setColor(c[1], c[2], c[3])
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- 血条
    local w, h = self.radius * 2, 5
    local bx = self.x - self.radius
    local by = self.y - self.radius - 10
    love.graphics.setColor(0.25, 0, 0)
    love.graphics.rectangle("fill", bx, by, w, h)
    love.graphics.setColor(0.2, 0.9, 0.2)
    love.graphics.rectangle("fill", bx, by, w * (self.hp / self.maxHp), h)

    love.graphics.setColor(1, 1, 1)
end

function Enemy:isEnemy()
    return true
end

return Enemy
