---@class Bullet : IEntity
---@field x number
---@field y number
---@field target Enemy 追踪的目标敌人
---@field damage number
---@field speed number
---@field radius number
---@field dead boolean
Bullet = Bullet or {}
Bullet.__index = Bullet

-- 追踪型子弹：锁定一个敌人一直飞过去
function Bullet.new(x, y, target, damage)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.target = target
    self.damage = damage
    self.speed = 420
    self.radius = 5
    self.dead = false
    return self
end

function Bullet:update(dt)
    local t = self.target
    -- 目标已经死了/漏了：子弹作废
    if not t or t.dead or t.reachedEnd then
        self.dead = true
        return
    end

    local dx, dy = t.x - self.x, t.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local step = self.speed * dt

    if step >= dist then
        t:hit(self.damage) -- 命中扣血
        self.dead = true
    else
        self.x = self.x + dx / dist * step
        self.y = self.y + dy / dist * step
    end
end

function Bullet:draw()
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1)
end

function Bullet:isBullet()
    return true
end

return Bullet
