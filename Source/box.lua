class("Box").extends()

local unknownImg<const> = loadImg("box/icon-unknown")
local revealedOverlay<const> = loadImg("box/revealed")
local borderImages<const> = { closed = loadImg("box/border/closed"), revealed = loadImg("box/border/revealed"), open = loadImg("box/border/open") }
local borderSize<const> = 2
local emptyIcon<const> = gfx.image.new(consts.boxSize - borderSize * 2, consts.boxSize - borderSize * 2)

local closeSound<const> = loadSound("close")
local destroySound<const> = loadSound("destroy")
local openSound<const> = loadSound("open")
local revealSound<const> = loadSound("reveal")

function Box:init(row, col)
    self.row = row
    self.col = col
    self.type = ""
    self.sprite = gfx.sprite.new()
    self.sprite:add()
    self:reset(nil)
end

function Box:reset(newType)
    self.type = newType
    self.revealed = math.random() > 0.5
    self.opened = false
    self.destroyed = false
    if newType ~= nil then self:redraw() end
end

function Box:redraw()
    local img = gfx.image.new(consts.boxSize, consts.boxSize)
    gfx.pushContext(img)

    if not self.destroyed then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, consts.boxSize, consts.boxSize)
        gfx.setColor(gfx.kColorBlack)
        local border
        if self.opened then border = borderImages.open
        elseif self.revealed then border = borderImages.revealed
        else border = borderImages.closed end
        border:draw(0, 0)
        
        local icon = self.revealed and self.type.icon or unknownImg
        icon:draw(borderSize, borderSize)
        if self.revealed and not self.opened then revealedOverlay:draw(borderSize, borderSize) end
    end

    gfx.popContext()
    self.sprite:setImage(img)
end

function Box:open()
    if not pyramid.playing or self.opened or self.destroyed then return end
    self.opened = true
    self.revealed = true
    openSound:play()
    pyramid:log(self, tr("log.open"):gsub("#", self:name()))
    if self.type.onOpen then self.type.onOpen(self) end
    self:redraw()
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then box:otherBoxOpened(self) end
    end
    pyramid:countStats()
end

function Box:press()
    if not pyramid.playing or self.destroyed or not self.opened then return end
    if self.type.onPress then self.type.onPress(self) end
end

function Box:reveal()
    if not pyramid.playing or self.destroyed or self.revealed then return end
    self.revealed = true
    revealSound:play()
    if self.type.onReveal then self.type.onReveal(self) end
    self:redraw()
    pyramid:countStats()
end

function Box:destroy()
    if not pyramid.playing or self.destroyed then return end
    self.destroyed = true
    destroySound:play()
    if self.opened and self.type.onDestroy then self.type.onDestroy(self) end
    if pyramid.cursor:box() == self then infobox:refresh() end
    self:redraw()
    pyramid:countStats()
end

function Box:close()
    if not pyramid.playing or self.destroyed or not self.opened then return end
    self.opened = false
    closeSound:play()
    self:redraw()
    pyramid:countStats()
end

function Box:otherBoxOpened(box)
    if not pyramid.playing or not self.opened or self.destroyed then return end
    if self.type.onOtherBoxOpened then self.type.onOtherBoxOpened(self, box) end
end

function Box:getAdjacent(distance)
    return pyramid:getBoxes(function(box)
        if box == self then return false end
        return box.row == self.row and math.abs(box.col - self.col) <= distance
            or math.abs(box.row - self.row) <= distance and math.abs(box.relativeCol - self.relativeCol) <= distance
    end)
end

function Box:power()
    if self.type.getPower then return self.type.getPower(self)
    elseif self.type.power then return self.type.power end
    return 0
end

function Box:name()
    if self.destroyed then return tr("box.destroyed.n") end
    if not self.revealed then return tr("box..n") end
    return tr("box."..self.type.id..".n")
end

function Box:desc()
    if self.destroyed then return tr("box.destroyed.d") end
    if not self.revealed then return tr("box..d") end
    return tr("box."..self.type.id..".d"):gsub("#", self:power())
end

function Box:displayIcon()
    if self.destroyed then return emptyIcon end
    if not self.revealed then return unknownImg end
    return self.type.icon
end

import "boxes"