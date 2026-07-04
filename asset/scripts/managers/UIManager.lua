require "scripts.managers.ScenceManager"
require "scripts.managers.StateManager"

---@class UIManager : IManager
---@field barY number 工具栏顶部 y
---@field barW number 工具栏宽度
---@field selected number|nil 当前选中的塔类型索引
---@field buttons table[] 按钮矩形缓存
UIManager = UIManager or {}

local BAR_H = 80 -- 底部工具栏高度

-- 可造的塔目录（数据驱动：加新塔只往这里加一项）
UIManager.TOWER_TYPES = {
    { name = "箭塔", cost = 50,  def = { range = 150, damage = 25, fireRate = 1.5, color = { 0.4, 0.8, 1.0 } } },
    { name = "重炮", cost = 100, def = { range = 120, damage = 70, fireRate = 0.6, color = { 1.0, 0.6, 0.3 } } },
}

function UIManager:load()
    local w, h = love.graphics.getDimensions()
    self.barW = w
    self.barY = h - BAR_H
    self.selected = nil
    self.buttons = {}

    local bw, bh = 140, BAR_H - 20
    local startX = 220
    for i, t in ipairs(self.TOWER_TYPES) do
        self.buttons[i] = {
            x = startX + (i - 1) * (bw + 10),
            y = self.barY + 10,
            w = bw,
            h = bh,
            type = t,
        }
    end
end

-- 返回当前选中的塔类型（{name, cost, def}），没选则 nil
function UIManager:getSelected()
    if not self.selected then return nil end
    return self.TOWER_TYPES[self.selected]
end

function UIManager:deselect()
    self.selected = nil
end

-- 处理左键点击：命中按钮就切换选中并返回 true（表示点在 UI 上，别再放塔）
---@return boolean consumed 点击是否被 UI 消费掉
function UIManager:handleClick(x, y)
    for i, b in ipairs(self.buttons) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            self.selected = (self.selected == i) and nil or i -- 再点一次取消
            return true
        end
    end
    -- 点在工具栏空白处也算消费，避免透传到地图
    return y >= self.barY
end

-- 放置预览：跟随鼠标画一个格子高亮 + 射程圈（绿=可放，红=不可）
function UIManager:drawGhost()
    if not StateManager:is(StateManager.PLAYING) then return end
    local sel = self:getSelected()
    if not sel then return end

    local mx, my = love.mouse.getPosition() -- 鼠标像素坐标
    if my >= self.barY then return end      -- 鼠标在工具栏上，不画

    local c, r = ScenceManager:pixelToCell(mx, my)
    if not ScenceManager:inBounds(c, r) then return end

    local ts = ScenceManager.tileSize
    local x, y = ScenceManager:cellCenter(c, r)
    local valid = not ScenceManager:isPath(c, r)
        and not ScenceManager:isTowerCell(c .. "," .. r)
        and Game.money >= sel.cost

    if valid then
        love.graphics.setColor(0.4, 1.0, 0.4, 0.35)
    else
        love.graphics.setColor(1.0, 0.3, 0.3, 0.35)
    end
    love.graphics.rectangle("fill", c * ts, r * ts, ts, ts)

    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.circle("line", x, y, sel.def.range)
    love.graphics.setColor(1, 1, 1)
end

function UIManager:draw()
    -- 工具栏背景
    love.graphics.setColor(0.08, 0.08, 0.1, 0.95)
    love.graphics.rectangle("fill", 0, self.barY, self.barW, BAR_H)
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("line", 0, self.barY, self.barW, BAR_H)

    -- 生命 / 金币
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.print("生命 " .. Game.lives, 15, self.barY + 16)
    love.graphics.setColor(1, 0.9, 0.4)
    love.graphics.print("金币 " .. Game.money, 15, self.barY + 46)

    -- 塔按钮
    for i, b in ipairs(self.buttons) do
        local t = b.type
        local c = t.def.color
        local affordable = Game.money >= t.cost

        if affordable then
            love.graphics.setColor(c[1] * 0.5, c[2] * 0.5, c[3] * 0.5)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)

        if self.selected == i then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.4, 0.4, 0.45)
        end
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h)

        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", b.x + 10, b.y + 15, 30, 30)

        if affordable then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.6, 0.6, 0.6)
        end
        love.graphics.print(t.name, b.x + 50, b.y + 8)
        love.graphics.print("$" .. t.cost, b.x + 50, b.y + 32)
    end
    love.graphics.setColor(1, 1, 1)
end

return UIManager
