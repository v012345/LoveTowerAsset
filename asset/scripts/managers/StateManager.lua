---@class StateManager : IManager
---@field current string 当前状态
StateManager = StateManager or {}

-- 四个状态
StateManager.MENU = "menu"       -- 开始界面
StateManager.PLAYING = "playing" -- 游戏中
StateManager.WIN = "win"         -- 胜利
StateManager.LOSE = "lose"       -- 失败

function StateManager:load()
    self.current = self.MENU
end

---@param state string
function StateManager:set(state)
    self.current = state
end

---@param state string
---@return boolean
function StateManager:is(state)
    return self.current == state
end

return StateManager
