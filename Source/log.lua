class("Log").extends()

local entryHeight<const> = consts.boxSize - 4 + 1

function Log:init(x, y, width, height)
    self.sprite = gfx.sprite.new()
    self.sprite:setSize(width, height)
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(x, y)
    self.sprite:add()
    self:reset()
end

function Log:redraw()
    local img = gfx.image.new(self.sprite.width, self.sprite.height)
    gfx.pushContext(img)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, img.width, img.height)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 0, img.width, img.height)

    local y = math.floor(self.y + 0.5) - 1
    for i, entry in ipairs(self.entries) do
        if y > img.height then break end
        if y - entryHeight > 0 then
            if entry.i then entry.i:draw(1, y + 1) end
            gfx.drawLine(0, y, img.width, y)
            gfx.drawLine(entryHeight, y, entryHeight, y + entryHeight)
            if i == #self.entries then gfx.drawLine(0, y + entryHeight, img.width, y + entryHeight) end
            if entry.t then fontSm:drawText(entry.t, entryHeight + 5, y + 6) end
        end
        y += entryHeight
    end

    gfx.popContext()
    self.sprite:setImage(img)
end

function Log:reset()
    self.tY = self.sprite.height
    self.y = self.tY
    if self.entries and #self.entries > 0 then print("") end
    self.entries = {}
    self:redraw()
end

function Log:add(icon, text)
    print(text)
    table.insert(self.entries, {t=text, i=icon})
    self.tY = self.sprite.height - entryHeight * #self.entries
end

function Log:update()
    if self.y ~= self.tY then
        self.y = pd.math.lerp(self.y, self.tY, 1.0 - math.pow(0.00001, delta))
        if math.abs(self.y - self.tY) < 0.25 then self.y = self.tY end
        self:redraw()
    end
end

function Log:onCrank(change, acceleratedChange)
    if #self.entries == 0 then return end
    local move = change * 0.6
    self.tY += move
    self.y += move + 0.01
    self.tY = math.min(math.max(self.tY, self.sprite.height - entryHeight * #self.entries), self.sprite.height - entryHeight)
end