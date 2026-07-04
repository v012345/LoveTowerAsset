require "scripts.managers.ScenceManager"
require "scripts.entity.Tower"
require "scripts.managers.EntityManager"
require "scripts.spawner.EntitySpawner"
require "scripts.managers.StateManager"
require "scripts.managers.UIManager"

-- 经济配置（塔的属性/价格现在由 UIManager 的塔目录管理）
local START_MONEY = 150

---@class Game
Game = Game or {}

function Game:load()
    ScenceManager:loadMap("map_1")        -- 生成路
    EntitySpawner:loadConfig("config_1")  -- 波次配置

    self.font = love.graphics.newFont("resource/fonts/chinese.ttf", 18)
    self.bigFont = love.graphics.newFont("resource/fonts/chinese.ttf", 52)

    self:resetRound() -- 初始化本局数据

    -- 输入只注册一次
    InputManager:on(Game, "keypressed", "space", function() self:onSpace() end)
    InputManager:on(Game, "keypressed", "r", function() self:restart() end)
    InputManager:on(Game, "mousepressed", 1, function(_, x, y)
        if UIManager:handleClick(x, y) then return end -- 点在工具栏上
        self:tryPlaceTower(x, y)
    end)
    InputManager:on(Game, "mousepressed", 2, function() UIManager:deselect() end) -- 右键取消选中

    StateManager:set(StateManager.MENU)
end

-- 重置一局的所有游戏数据（开局 / 重开都用）
function Game:resetRound()
    Game.KILL_REWARD = 15
    self.lives = 20
    self.money = START_MONEY
    EntityManager:load()                 -- 清空所有实体
    EntitySpawner:loadConfig("config_1") -- 波次归零
    ScenceManager:clearTowers()          -- 清空塔占格
end

function Game:restart()
    self:resetRound()
    StateManager:set(StateManager.PLAYING)
end

-- 空格：菜单里开始游戏；游戏中开下一波
function Game:onSpace()
    if StateManager:is(StateManager.MENU) then
        StateManager:set(StateManager.PLAYING)
        self:startNextWave()
    elseif StateManager:is(StateManager.PLAYING) then
        self:startNextWave()
    end
end

-- 开下一波：要求场上清空 且 还有波次
function Game:startNextWave()
    if EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
        EntitySpawner:start()
    end
end

-- 尝试在鼠标位置放塔（用 UI 里当前选中的塔类型）
function Game:tryPlaceTower(px, py)
    if not StateManager:is(StateManager.PLAYING) then return end

    local sel = UIManager:getSelected()
    if not sel then return end -- 没在工具栏选塔

    local c, r = ScenceManager:pixelToCell(px, py)
    if not ScenceManager:inBounds(c, r) then return end
    if ScenceManager:isPath(c, r) then return end         -- 路上不能放
    local cellKey = c .. "," .. r
    if ScenceManager:isTowerCell(cellKey) then return end -- 已有塔
    if self.money < sel.cost then return end              -- 钱不够

    local x, y = ScenceManager:cellCenter(c, r)
    EntityManager:addEntity(EntityFactory:create(Tower, x, y, sel.def))
    ScenceManager:setTowerCell(cellKey, true)
    self.money = self.money - sel.cost
end

function Game:update(dt)
    if not StateManager:is(StateManager.PLAYING) then return end

    EntitySpawner:update(dt)
    EntityManager:update(dt)

    -- 输赢判定
    if self.lives <= 0 then
        StateManager:set(StateManager.LOSE)
    elseif EntitySpawner:allWavesDone() and EntityManager:getEnemyCount() == 0 then
        StateManager:set(StateManager.WIN)
    end
end

function Game:draw()
    ScenceManager:draw()
    EntityManager:draw()
    UIManager:drawGhost() -- 放置预览（地图之上、工具栏之下）

    -- 顶部简要信息
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        ("波次: %d/%d    敌人: %d    FPS: %d"):format(
            EntitySpawner.waveIndex, EntitySpawner:totalWaves(),
            EntityManager:getEnemyCount(), love.timer.getFPS()
        ), 10, 10)

    if StateManager:is(StateManager.PLAYING)
        and EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
        love.graphics.print("按 [空格] 开始第 " .. (EntitySpawner.waveIndex + 1) .. " 波", 10, 36)
    end

    UIManager:draw() -- 底部工具栏

    local state = StateManager.current
    if state == StateManager.MENU then
        self:drawOverlay("塔防 LoveTower", "按 [空格] 开始游戏")
    elseif state == StateManager.WIN then
        self:drawOverlay("胜  利 !", "成功守住了！按 [R] 再玩一局")
    elseif state == StateManager.LOSE then
        self:drawOverlay("失  败 ...", "防线被突破了 按 [R] 再玩一局")
    end
end

-- 居中的半透明覆盖层 + 大标题 + 副标题
function Game:drawOverlay(title, subtitle)
    local w, h = love.graphics.getDimensions() -- 窗口宽高
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.bigFont)
    love.graphics.printf(title, 0, h / 2 - 80, w, "center")
    love.graphics.setFont(self.font)
    love.graphics.printf(subtitle, 0, h / 2 + 20, w, "center")
end

return Game
