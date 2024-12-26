class("Infobox").extends()

function Infobox:init()
    self.sprite = gfx.sprite.new()
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(pyramid.x + pyramid.size + pyramid.x, pyramid.y)
    self.sprite:setSize(400 - self.sprite.x - pyramid.x, 240 - self.sprite.y - pyramid.y)
    self.sprite:add()
    self.icon = gfx.image.new(1, 1)
    self.title = ""
    self.description = ""
    self.opened = false
end

function Infobox:redraw()
    local img = gfx.image.new(self.sprite.width, self.sprite.height)
    gfx.pushContext(img)

    local y = 6
    local titleWidth = fontLg:getTextWidth(self.title)
    local iconX = (self.sprite.width - titleWidth) / 2 - (20 + 4) / 2 
    fontLg:drawText(self.title, iconX + 20 + 4, y + 4)
    gfx.setLineWidth(2)
    gfx.drawRect(iconX, y, 20, 20)
    if self.icon then self.icon:draw(iconX + 1, y + 1) end
    y += 20 + 5

    if not self.opened then
        fontSm:drawTextAligned(tr("info.unopened"), self.sprite.width / 2, y, kTextAlignment.center)
        y += fontSm:getHeight() + 3
    end

    local descWidth, descHeight = gfx.drawTextInRect(self.description, 4, y, self.sprite.width - 4 * 2, 200, nil, nil, nil, fontMd)
    y += descHeight + 5

    gfx.setLineWidth(1)
    gfx.drawRoundRect(0, 0, self.sprite.width, y, 5)

    gfx.popContext()
    self.sprite:setImage(img)
end

function Infobox:refresh()
    local box = pyramid.cursor:box()
    local newTitle = box:name()
    local newDesc = box:desc()
    if newTitle ~= self.title or newDesc ~= self.description then
        self.title = newTitle
        self.description = newDesc
        self.icon = box:displayIcon()
        self.opened = box.destroyed or not box.revealed or box.opened
    else
        if self.opened ~= (box.destroyed or not box.revealed or box.opened) then
            self.opened = box.destroyed or not box.revealed or box.opened
        end
    end
    self:redraw()
end

function Infobox:update()

end