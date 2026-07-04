local Hotfix = {}



local progress = 0

-- ===== Shader：动态背景 =====
local bgShader = love.graphics.newShader([[
extern float time;
extern vec2 screenSize;

// ---- 伪随机 ----
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

// ---- 星空 ----
float stars(vec2 uv, float density) {
    vec2 gv = fract(uv * density) - 0.5;
    vec2 id = floor(uv * density);
    float star = hash21(id);
    float brightness = smoothstep(0.7, 1.0, star) * 0.8;
    float d = length(gv);
    float twinkle = sin(time * (star * 3.0 + 2.0) + id.x) * 0.5 + 0.5;
    return brightness * (1.0 - smoothstep(0.0, 0.08, d)) * (0.5 + twinkle * 0.5);
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_uv)
{
    vec2 pos = screen_uv / screenSize;

    // ---- 极光层 ----
    float wave1 = sin(pos.x * 4.5 + time * 0.6) * 0.3;
    float wave2 = sin(pos.x * 7.0 - time * 0.9 + 2.1) * 0.2;
    float wave3 = cos(pos.x * 3.0 + time * 0.4 + 5.0) * 0.25;
    float auroraMask = wave1 + wave2 + wave3;

    // ---- 底部暖光脉冲 ----
    float pulse = sin(time * 1.2) * 0.15 + 0.85;
    float glow = exp(-abs(pos.y - 0.85) * 12.0) * 0.5 * pulse;

    // ---- 主色调 ----
    vec3 deepDark = vec3(0.04, 0.04, 0.10);
    vec3 midDark  = vec3(0.10, 0.12, 0.25);

    vec3 bg = mix(deepDark, midDark, pos.y);

    // ---- 极光颜色 ----
    vec3 auroraCol1 = vec3(0.00, 0.60, 0.85);
    vec3 auroraCol2 = vec3(0.50, 0.10, 0.80);
    vec3 auroraCol3 = vec3(0.00, 0.80, 0.50);
    float mixAurora = sin(pos.x * 2.0 + time * 0.2) * 0.5 + 0.5;
    vec3 auroraColor = mix(auroraCol1, auroraCol2, mixAurora);
    auroraColor = mix(auroraColor, auroraCol3, sin(pos.x * 3.0 + time * 0.3) * 0.5 + 0.5);

    float auroraAlpha = max(0.0, auroraMask) * (1.0 - abs(pos.y - 0.4) * 2.0) * 0.35;
    bg += auroraColor * auroraAlpha;

    // ---- 底部暖光 ----
    vec3 warm = vec3(1.00, 0.55, 0.15);
    bg += warm * glow;

    // ---- 星空 ----
    float s = stars(pos, 25.0) + stars(pos, 50.0) * 0.5;
    bg += vec3(s * 0.9, s * 0.85, s);

    return vec4(bg, 1.0);
}
]])

local time = 0


-- 更新进度
function Hotfix:setProgress(p)
    progress = math.max(0, math.min(1, p))
end

function Hotfix:load()
    print("hotfix load")
end

function Hotfix:update(dt)
    -- print("hotfix update")
    time = time + dt
    bgShader:send("time", time)
end

function Hotfix:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- ===== 背景 Shader =====
    bgShader:send("screenSize", {w, h})
    love.graphics.setShader(bgShader)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setShader()

    -- ===== 进度条背景 =====
    local barW = w * 0.6
    local barH = 20
    local x = (w - barW) / 2
    local y = h * 0.7

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, barW, barH)

    -- ===== 进度条 =====
    love.graphics.setColor(0.2, 0.8, 0.3, 1)
    love.graphics.rectangle("fill", x, y, barW * progress, barH)

    -- ===== 外框 =====
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("line", x, y, barW, barH)

    -- ===== 文字（默认字体，不加载资源）=====
    love.graphics.setColor(1, 1, 1, 1)
    local text = string.format("Downloading... %d%%", math.floor(progress * 100))

    local font = love.graphics.getFont() -- 默认字体
    local tw = font:getWidth(text)

    love.graphics.print(text, (w - tw) / 2, y - 30)
end

return Hotfix
