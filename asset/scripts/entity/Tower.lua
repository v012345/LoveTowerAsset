require "scripts.entity.Bullet"

---@class Tower : IEntity
---@field x number
---@field y number
---@field range number 射程（像素）
---@field damage number
---@field fireRate number 每秒射速x
---@field cooldown number 距离下次开火的倒计时
---@field radius number
---@field color number[]
---@field target Enemy|nil 当前锁定目标
Tower = Tower or {}
Tower.__index = Tower

-- x, y: 塔所在格子的像素中心
-- def:  塔属性 { range 射程, damage 伤害, fireRate 每秒射速, radius, color }
function Tower.new(x, y, def)
    local self = setmetatable({}, Tower)
    self.x = x
    self.y = y
    self.range = def.range or 150
    self.damage = def.damage or 25
    self.fireRate = def.fireRate or 1.5
    self.cooldown = 0 -- 距离下次开火的倒计时
    self.radius = def.radius or 18
    self.color = def.color or { 0.4, 0.8, 1.0 }
    self.target = nil
    return self
end

-- 选射程内“走得最靠前”的敌人（nextNode 越大越接近终点，优先打）
function Tower:findTarget(enemies)
    local best, bestProgress
    local r2 = self.range * self.range
    for _, e in ipairs(enemies) do
        local dx, dy = e.x - self.x, e.y - self.y
        if dx * dx + dy * dy <= r2 then
            if not best or e.nextNode > bestProgress then
                best, bestProgress = e, e.nextNode
            end
        end
    end
    return best
end


function Tower:update(dt, enemies)
    self.cooldown = self.cooldown - dt
    self.target = self:findTarget(enemies)

    if self.target and self.cooldown <= 0 then
        self.cooldown = 1 / self.fireRate
        EntityManager:addEntity(EntityFactory:create(Bullet, self.x, self.y, self.target, self.damage))
    end
end

function Tower:draw()
    -- 射程圈（淡淡的）
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.circle("line", self.x, self.y, self.range)

    local c = self.color
    love.graphics.setColor(c[1], c[2], c[3])
    love.graphics.rectangle("fill", self.x - self.radius, self.y - self.radius,
        self.radius * 2, self.radius * 2)

    -- 炮口朝向当前目标
    if self.target then
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(self.x, self.y, self.target.x, self.target.y)
    end

    love.graphics.setColor(1, 1, 1)
end

function Tower:isTower()
    return true
end

return Tower
