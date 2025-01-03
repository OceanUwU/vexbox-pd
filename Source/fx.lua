class('FX').extends()

function FX:init()
    self.effects = {}
end

function FX:addEffect(effect)
    table.insert(self.effects, effect)
end

function FX:update()
    for key, effect in pairs(self.effects) do
        effect:update()
        if effect.done then
            effect:dispose()
            self.effects[key] = nil
        end
    end
end


class("Effect").extends(gfx.sprite)

function Effect:init(x, y)
    Effect.super.init(self)
    self:moveTo(x, y)
    self.time = 0
    self.length = 0
    self.done = false
    self:add()
end

function Effect:update()
    self.time += delta
    self.progress = math.min(self.time / self.length, 1)
    self.done = self.time >= self.length
end

function Effect:dispose()
    self:remove()
end


class("OpenEffect").extends(Effect)

local openEffectSize<const> = 60

function OpenEffect:init(x, y)
    OpenEffect.super.init(self, x, y)
    self.length = 0.8
end

function OpenEffect:update()
    OpenEffect.super.update(self)

    local img = gfx.image.new(openEffectSize + 2, openEffectSize + 2)
    gfx.pushContext(img)

    local a = math.sin(self.progress)
    local r = (1 - math.pow(1 - self.progress, 3)) * openEffectSize / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(img.width / 2, img.height / 2, r)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(img.width / 2, img.height / 2, r)

    gfx.popContext()
    self:setImage(img)
end


class("CloseEffect").extends(Effect)

local closeEffectSize<const> = 60

function CloseEffect:init(x, y)
    CloseEffect.super.init(self, x, y)
    self.length = 0.8
end

function CloseEffect:update()
    CloseEffect.super.update(self)

    local img = gfx.image.new(closeEffectSize + 2, closeEffectSize + 2)
    gfx.pushContext(img)

    local a = math.sin(1 - self.progress)
    local r = (1 - math.pow(self.progress, 3)) * closeEffectSize / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(img.width / 2, img.height / 2, r)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(img.width / 2, img.height / 2, r)

    gfx.popContext()
    self:setImage(img)
end


class("DestroyEffect").extends(Effect)

local destroyEffectStokes<const> = 14
local destroyEffectSize<const> = 60

function DestroyEffect:init(x, y)
    DestroyEffect.super.init(self, x, y)
    self.length = 1.0 + math.random() * 0.4
    self.angle = math.random()
    self.rotVel = math.random() - 0.5
end

function DestroyEffect:update()
    DestroyEffect.super.update(self)
    self.angle += self.rotVel * delta

    local img = gfx.image.new(destroyEffectSize + 2, destroyEffectSize + 2)
    gfx.pushContext(img)

    local x = img.width / 2
    local a = math.sin(self.progress)
    local r = (1 - math.pow(1 - self.progress, 3)) * destroyEffectSize / 2
    local rIn = r * 0.6
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    local points = {}
    for i = 1, destroyEffectStokes, 2 do
        local isIn = i % 2 == 0
        local r1 = isIn and rIn or r
        local r2 = isIn and r or rIn
        local a1 = self.angle + i / destroyEffectStokes * math.pi * 2
        local a2 = self.angle + (i + 1) / destroyEffectStokes * math.pi * 2
        table.insert(points, x + math.cos(a1) * r1)
        table.insert(points, x + math.sin(a1) * r1)
        table.insert(points, x + math.cos(a2) * r2)
        table.insert(points, x + math.sin(a2) * r2)
    end
    gfx.drawPolygon(table.unpack(points))

    gfx.popContext()
    self:setImage(img)
end

class("RevealEffect").extends(Effect)

local revealEffectLines<const> = 4
local revealEffectSize<const> = 65

function RevealEffect:init(x, y)
    RevealEffect.super.init(self, x, y)
    self.length = 0.8
    self.angle = math.random()
    self.rotVel = math.random() - 0.5
end

function RevealEffect:update()
    RevealEffect.super.update(self)
    self.angle += self.rotVel * delta

    local img = gfx.image.new(revealEffectSize + 2, revealEffectSize + 2)
    gfx.pushContext(img)

    local x = img.width / 2
    local rOut = (1 - math.pow(1 - self.progress, 3)) * revealEffectSize / 2
    local rIn = math.pow(self.progress, 3) * revealEffectSize / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    self:drawSpokes(x, x, rOut, rIn)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    self:drawSpokes(x, x, rOut, rIn)

    gfx.popContext()
    self:setImage(img)
end

function RevealEffect:drawSpokes(x, y, rOut, rIn)
    for i = 1, revealEffectLines do
        local a = self.angle + i / revealEffectLines * math.pi * 2;
        gfx.drawLine(x + math.cos(a) * rIn, y + math.sin(a) * rIn, x + math.cos(a) * rOut, y + math.sin(a) * rOut)
    end
end


class("CoinEffect").extends(Effect)

local goldImg<const> = loadImg("stats/coins")

function CoinEffect:init()
    CoinEffect.super.init(self, math.random(50, 190), 250)
    self.length = 1.5 + math.random() * 1.0
    self.angle = math.random() * 360
    self.rotVel = math.random() * 180 - 90
    self.xVel = math.random() * 40 - 20
    self.jumpHeight = math.random(80, 200)
    self.realX = self.x
    self:setImage(goldImg)
    self:setScale(2)
end

function CoinEffect:update()
    CoinEffect.super.update(self)
    self.angle += self.rotVel * delta
    self.realX += self.xVel * delta
    self:moveTo(self.realX, 250 - self.jumpHeight * math.sin(self.progress * math.pi))
    self:setRotation(self.angle)
end

class("TransformEffect").extends(Effect)

local transformEffectLines<const> = 3
local transformEffectSize<const> = 70

function TransformEffect:init(x, y)
    TransformEffect.super.init(self, x, y)
    self.length = 1.0
    self.angle = math.random()
    self.rotVel = 2.0 + math.random() * 1.0
end

function TransformEffect:update()
    TransformEffect.super.update(self)
    self.angle += self.rotVel * delta

    local img = gfx.image.new(transformEffectSize + 2, transformEffectSize + 2)
    gfx.pushContext(img)

    local x = img.width / 2
    local a = math.sin(self.progress)
    local rOut = (1 - math.pow(1 - self.progress, 3)) * transformEffectSize / 2
    local rIn = math.pow(self.progress, 3) * transformEffectSize / 2
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.setDitherPattern(a, gfx.image.kDitherTypeBayer8x8)
    self:drawSpokes(x, x, rOut, rIn)

    gfx.popContext()
    self:setImage(img)
end

function TransformEffect:drawSpokes(x, y, rOut, rIn)
    for i = 1, transformEffectLines do
        local angle = self.angle + i / transformEffectLines * math.pi * 2;
        local points = {}
        for i = 0, 4 do
            local a = angle + math.abs(i - 2) / 2 * 0.9
            local r = rIn + (rOut - rIn) * i / 4
            table.insert(points, x + math.cos(a) * r)
            table.insert(points, y + math.sin(a) * r)
        end
        for i = 1, #points - 2, 2 do
            gfx.drawLine(points[i], points[i + 1], points[i + 2], points[i + 3])
        end
    end
end