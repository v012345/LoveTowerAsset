InputManager = InputManager or {}

InputManager._event = {}

-- 通用派发：找到所有订阅了 (eventType, key) 的 context，逐个回调
function InputManager:dispatch(eventType, key, ...)
    for context, events in pairs(self._event) do
        local handlers = events[eventType]
        if handlers and handlers[key] then
            handlers[key](context, ...)
        end
    end
end

function InputManager:keypressed(pressedKey)
    if pressedKey == "escape" then love.event.quit() end
    self:dispatch("keypressed", pressedKey, pressedKey)
end

-- 鼠标按下：以“按键=按钮号”为 key，回调收到 (context, x, y, button)
function InputManager:mousepressed(x, y, button)
    self:dispatch("mousepressed", button, x, y, button)
end

---@generic T
---@param context T
---@param eventType string
---@param key string|number
---@param callback function
function InputManager:on(context, eventType, key, callback)
    if not self._event[context] then self._event[context] = {} end
    if not self._event[context][eventType] then self._event[context][eventType] = {} end
    self._event[context][eventType][key] = callback
end

function InputManager:off(context, eventType, key)
    if not self._event[context] then return end
    if not self._event[context][eventType] then return end
    self._event[context][eventType][key] = nil
end

return InputManager
