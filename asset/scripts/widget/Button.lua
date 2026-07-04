---@class Button
local Button = {}
Button.__index = Button

function Button.new(x, y, w, h, text, callback)
    local self = setmetatable({}, Button)

    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.text = text
    self.callback = callback

    self.hover = false
    self.pressed = false
    self.enabled = true

    return self
end

function Button:contains(x, y)
    return x >= self.x
        and x <= self.x + self.w
        and y >= self.y
        and y <= self.y + self.h
end

function Button:update()
    local mx, my = love.mouse.getPosition()
    self.hover = self:contains(mx, my)
end

function Button:mousepressed(x, y, button)
    if not self.enabled then
        return
    end

    if button == 1 and self:contains(x, y) then
        self.pressed = true
    end
end

function Button:mousereleased(x, y, button)
    if not self.enabled then
        return
    end

    if button == 1 then
        if self.pressed and self:contains(x, y) then
            if self.callback then
                self.callback(self)
            end
        end

        self.pressed = false
    end
end

function Button:draw()
    if not self.enabled then
        love.graphics.setColor(0.5, 0.5, 0.5)
    elseif self.pressed then
        love.graphics.setColor(0.4, 0.4, 1)
    elseif self.hover then
        love.graphics.setColor(0.6, 0.6, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(0, 0, 0)

    local font = love.graphics.getFont()
    local tw = font:getWidth(self.text)
    local th = font:getHeight()

    love.graphics.print(
        self.text,
        self.x + (self.w - tw) / 2,
        self.y + (self.h - th) / 2
    )

    love.graphics.setColor(1, 1, 1)
end

return Button
