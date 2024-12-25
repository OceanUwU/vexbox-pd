class("Cursor").extends()

local maxDistance<const> = 2

function Cursor:init()
    self.x = 0
    self.y = 0
    self.tX = 0
    self.tY = 0
    self.distance = 0
    local img<const> = loadImg("cursor")
    self.sprites = {}
    for i = 1, 4 do
        self.sprites[i] = gfx.sprite.new(img)
        self.sprites[i]:setRotation((i - 1) * 90)
        self.sprites[i]:add()
    end
end

function Cursor:update()
    self.distance = math.sin(lifetime * 2.0) * maxDistance / 2 + maxDistance / 2 - 1
    for i, sprite in ipairs(self.sprites) do
        local xDir = ((i - 1) % 3 == 0) and -1 or 1
        local yDir = (i > 2) and 1 or -1
        sprite:moveTo(self.x + xDir * (consts.boxSize / 2 + self.distance) + ((xDir == 1) and 0 or 1), self.y + yDir * (consts.boxSize / 2 + self.distance) + ((yDir == 1) and 0 or 1))
    end
end