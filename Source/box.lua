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
local useSound<const> = loadSound("use")

function Box:init(row, col)
    self.row = row
    self.col = col
    self.type = nil
    self.sprite = gfx.sprite.new()
    self.sprite:add()
    self:reset(nil)
end

function Box:reset(newType)
    self.type = newType
    self.realType = nil
    self.revealed = false
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
    if self.realType then
        self.type = self.realType
        self.realType = nil
    end
    local wasRevealed = self.revealed
    self.opened = true
    self.revealed = true
    openSound:play()
    pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
    local customLog = "box."..self.type.id..".open"
    pyramid:log(self, tr(customLog) == customLog and tr("log.open"):gsub("#", self:name()) or tr(customLog))
    if self.type.onOpen then self.type.onOpen(self) end
    self:redraw()
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then box:otherBoxOpened(self, wasRevealed) end
    end
    pyramid:countStats()
end

function Box:press()
    if not pyramid.playing or self.destroyed then return false end
    for _, box in pairs(pyramid:getBoxes()) do
        if box:otherBoxPressed(self) then return true end
    end
    if not self.opened then return false end
    if self.type.onPress then
        self.type.onPress(self)
        return true
    end
    return false
end

function Box:reveal()
    if not pyramid.playing or self.destroyed or self.revealed then return end
    if self.type.preReveal then self.type.preReveal(self) end
    self.revealed = true
    revealSound:play()
    pyramid.fx:addEffect(RevealEffect(self.sprite.x, self.sprite.y))
    local customLog = "box."..self.type.id..".reveal"
    pyramid:log(self, tr(customLog) == customLog and tr("log.reveal"):gsub("#", self:name()) or tr(customLog))
    if self.type.onReveal then self.type.onReveal(self) end
    self:redraw()
    pyramid:countStats()
end

function Box:destroy()
    if not pyramid.playing or self.destroyed then return end
    local customLog = self.revealed and ("box."..self.type.id..".destroy") or ""
    pyramid:log(self, tr(customLog) == customLog and tr("log.destroy"):gsub("#", self:name()) or tr(customLog))
    self.destroyed = true
    destroySound:play()
    pyramid.fx:addEffect(DestroyEffect(self.sprite.x, self.sprite.y))
    if self.opened and self.type.onDestroy then self.type.onDestroy(self) end
    if pyramid.cursor:box() == self then infobox:refresh() end
    self:redraw()
    pyramid:countStats()
end

function Box:close()
    if not pyramid.playing or self.destroyed or not self.opened then return end
    self.opened = false
    local customLog = "box."..self.type.id..".close"
    pyramid:log(self, tr(customLog) == customLog and tr("log.close"):gsub("#", self:name()) or tr(customLog))
    closeSound:play()
    pyramid.fx:addEffect(CloseEffect(self.sprite.x, self.sprite.y))
    if self.type.onClose then self.type.onClose(self) end
    self:redraw()
    pyramid:countStats()
end

function Box:transform(type)
    if not pyramid.playing or self.destroyed then return end
    local oldName = self:name()
    if self.opened and self.type.onTransform then self.type.onTransform(self, type) end
    self.type = type
    if self.realType then self.realType = nil end
    if self.opened and not self.destroyed then
        pyramid:log(self, tr("log.transform"):gsub("##", oldName):gsub("#", self:name()))
    end
    self:redraw()
end

function Box:revive()
    if not pyramid.playing or not self.destroyed then return end
    self.destroyed = false
    self.opened = false
    pyramid:log(self, tr("log.revive"):gsub("#", self:name()))
    self:redraw()
    pyramid:countStats()
end

function Box:useFX()
    useSound:play()
    pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
end

function Box:otherBoxOpened(box, wasRevealed)
    if not pyramid.playing or not self.opened or self.destroyed then return end
    if self.type.onOtherBoxOpened then self.type.onOtherBoxOpened(self, box, wasRevealed) end
end

function Box:otherBoxPressed(box)
    if not self.type.onOtherBoxPressed or not self.opened or self.destroyed or not pyramid.playing then return false end
    return self.type.onOtherBoxPressed(self, box)
end

function Box:isAdjacent(box, distance)
    return (box.row == self.row and math.abs(box.col - self.col) <= distance
        or math.abs(box.row - self.row) <= distance and math.abs(box.relativeCol - self.relativeCol) <= distance)
end

function Box:getAdjacent(distance, predicate)
    return pyramid:getBoxes(function(box)
        if box == self then return false end
        return self:isAdjacent(box, distance) and (not predicate or predicate(box))
    end)
end

function Box:n()
    if self.type.n then return self.type.n end
    return 0
end

function Box:n2()
    if self.type.n2 then return self.type.n2 end
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
    return tr("box."..self.type.id..".d"):gsub("##", self:n2()):gsub("#", self:n())
end

function Box:displayIcon()
    if self.destroyed then return emptyIcon end
    if not self.revealed then return unknownImg end
    return self.type.icon
end

function Box:log(key)
    pyramid:log(self, tr("box." .. self.type.id .. "." .. (key or "log")))
end

import "boxes"