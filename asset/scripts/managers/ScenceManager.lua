---@class ScenceManager : IManager
---@field tileSize number
---@field cols number
---@field rows number
---@field waypoints table
---@field pathCells table<string, boolean>
---@field images table<string, Image>
ScenceManager = ScenceManager or {}

local function sign(n)
    if n > 0 then return 1 elseif n < 0 then return -1 else return 0 end
end

local function key(c, r)
    return c .. "," .. r
end


function ScenceManager:load()
    self.tileSize = 60
    self.cols = 20
    self.rows = 12

    -- 敌人行走路线：每个点是网格坐标 {列, 行}，相邻两点必须同行或同列（直角折线）
    self.waypoints = {
        { 0, 1 }, { 4, 1 }, { 4, 5 }, { 9, 5 }, { 9, 2 }, { 14, 2 }, { 14, 9 }, { 19, 9 },
    }
    self.towerCells = {}
end

function ScenceManager:isTowerCell(cellKey)
    return self.towerCells[cellKey]
end

function ScenceManager:setTowerCell(cellKey, value)
    self.towerCells[cellKey] = value
end

-- 重开时清空所有塔占用的格子
function ScenceManager:clearTowers()
    self.towerCells = {}
end

---@param mapId string 地图ID
function ScenceManager:loadMap(mapId)
    self.images = {
        ground = love.graphics.newImage("resource/image/terrain_1_cell_1.png"),
        path   = love.graphics.newImage("resource/image/terrain_1_cell_3.png"),
    }

    -- 沿 waypoints 把途经的格子标记成“路”
    self.pathCells = {}
    for i = 1, #self.waypoints - 1 do
        local a, b = self.waypoints[i], self.waypoints[i + 1]
        local dc, dr = sign(b[1] - a[1]), sign(b[2] - a[2]) -- 必是一个是 0 , 一个是 +/-1
        local c, r = a[1], a[2]
        self.pathCells[key(c, r)] = true
        while c ~= b[1] or r ~= b[2] do
            c, r = c + dc, r + dr
            self.pathCells[key(c, r)] = true
        end
    end
end

-- 网格坐标 -> 该格中心的像素坐标
function ScenceManager:cellCenter(c, r)
    local ts = self.tileSize
    return (c + 0.5) * ts, (r + 0.5) * ts
end

-- 给路径系统用：返回 waypoints 对应的像素坐标列表 ( cell 的中心点坐标 )
function ScenceManager:getPathPixels()
    local pts = {}
    for _, wp in ipairs(self.waypoints) do
        local x, y = self:cellCenter(wp[1], wp[2])
        pts[#pts + 1] = { x = x, y = y }
    end
    return pts
end

-- 判断某格是不是路（放塔时要用：路上不能放塔）
function ScenceManager:isPath(c, r)
    return self.pathCells[key(c, r)] == true
end

-- 像素坐标 -> 网格坐标
function ScenceManager:pixelToCell(px, py)
    return math.floor(px / self.tileSize), math.floor(py / self.tileSize)
end

-- 网格坐标是否在地图范围内
function ScenceManager:inBounds(c, r)
    return c >= 0 and c < self.cols and r >= 0 and r < self.rows
end

function ScenceManager:draw()
    local ts = self.tileSize
    love.graphics.setColor(1, 1, 1)
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            local img = self:isPath(c, r) and self.images.path or self.images.ground
            local iw, ih = img:getDimensions()
            love.graphics.draw(img, c * ts, r * ts, 0, ts / iw, ts / ih)
        end
    end

    -- 给路径格压一层暗色，让路线一眼可见
    love.graphics.setColor(0, 0, 0, 0.28)
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            if self:isPath(c, r) then
                love.graphics.rectangle("fill", c * ts, r * ts, ts, ts)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

-- 调试用：把路径折线和路径点画出来
function ScenceManager:drawDebug()
    local pts = self:getPathPixels()
    love.graphics.setColor(0.3, 0.8, 1.0)
    for i = 1, #pts - 1 do
        love.graphics.line(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y)
    end
    for _, p in ipairs(pts) do
        love.graphics.circle("line", p.x, p.y, 8)
    end
    love.graphics.setColor(1, 1, 1)
end

return ScenceManager
