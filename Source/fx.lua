class('FX').extends()

function FX:init()
    self.effects = {}
end

function FX:addOpenEffect(x, y)
    table.insert(self.effects, OpenEffect(x, y))
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

function OpenEffect:update(x, y)
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
