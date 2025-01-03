class("Box").extends()

local unknownImg<const> = loadImg("box/icon-unknown")
local revealedOverlay<const> = loadImg("box/revealed")
local destroyedMask<const> = loadImg("box/destroyed")
local borderImages<const> = { closed = loadImg("box/border/closed"), revealed = loadImg("box/border/revealed"), open = loadImg("box/border/open") }
local borderSize<const> = 2
local emptyIcon<const> = gfx.image.new(consts.boxSize - borderSize * 2, consts.boxSize - borderSize * 2)

local closeSound<const> = loadSound("close")
local destroySound<const> = loadSound("destroy")
local openSound<const> = loadSound("open")
local revealSound<const> = loadSound("reveal")
local useSound<const> = loadSound("use")
local pulseGap<const> = 2.0

function Box:init(row, col)
    self.row = row
    self.col = col
    self.type = nil
    self.scale = 0
    self.sprite = gfx.sprite.new()
    self.sprite:add()
    self:reset(nil)
end

function Box:reset(newType)
    if self.type and (self.revealed or self.opened or self.destroyed) then
        self:prepDrawTransition()
    end
    self.type = newType
    self.realType = nil
    self.wasRevealed = false
    self.justTransformed = false
    self.revealed = false
    self.opened = false
    self.destroyed = false
    self.openedTime = 0
    if newType ~= nil then self:redraw() end
end

function Box:prepDrawTransition()
    self.transitionProgress = 1
    self.oldImg = self.sprite:getImage()
end

function Box:redraw()
    local img = gfx.image.new(consts.boxSize, consts.boxSize)
    gfx.pushContext(img)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, consts.boxSize, consts.boxSize)
    gfx.setColor(gfx.kColorBlack)
    --if not self.destroyed then
    local border
    if self.opened then border = borderImages.open
    elseif self.revealed then border = borderImages.revealed
    else border = borderImages.closed end
    border:draw(0, 0)
    
    local icon = self.revealed and self.type.icon or unknownImg
    icon:draw(borderSize, borderSize)
    if self.revealed and not (self.opened or self.destroyed) then revealedOverlay:draw(borderSize, borderSize) end
    if self.transitionProgress then img = self.oldImg:blendWithImage(img, self.transitionProgress, gfx.image.kDitherTypeBayer8x8) end
    --end

    gfx.popContext()
    if self.destroyed then
        img:setMaskImage(destroyedMask)
    end
    self.sprite:setImage(img)
    self.sprite:setVisible(self.row <= pyramid.numRows)
end

function Box:update()
    self.justTransformed = false
    if self.transitionProgress then
        self.transitionProgress -= 6.0 * delta
        if self.transitionProgress < 0.05 then
            self.transitionProgress = nil
            self.oldImg = nil
        end
        self:redraw()
    end
    if self.tY then
        self.y = pd.math.lerp(self.y, self.tY, 1.0 - math.pow(0.00001, delta))
        if math.abs(self.tY - self.y) < 0.5 then
            self.y = self.tY
            self.tY = nil
        end
        self.sprite:moveTo(self.sprite.x, self.y)
        pyramid.cursor:reposition()
    end
    if self.scale < 1 and self.sprite:isVisible() then
        self.scale = pd.math.lerp(self.scale, 1, 1.0 - math.pow(0.00001, delta))
        if self.scale > 0.95 then
            self.scale = 1
        end
        self.sprite:setScale(self.scale)
    end
    if self.type and self.type.onOtherBoxPressed and self.opened and not self.destroyed and pyramid.playing then
        self.openedTime += delta
        if self.openedTime >= pulseGap then
            self.openedTime -= pulseGap
            pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
        end
    end
end

function Box:open()
    if not pyramid.playing or self.opened or self.destroyed then return end
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self and not box:preOtherBoxOpened(self) then return end
    end
    if self.realType then
        self.type = self.realType
        self.realType = nil
    end
    self.wasRevealed = self.revealed
    self.opened = true
    self.revealed = true
    self.openedTime = 0
    pyramid:countStats()
    openSound:play()
    pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
    local customLog = "box."..self.type.id..".open"
    pyramid:log(self, tr(customLog) == customLog and tr("log.open"):gsub("#", self:name()) or tr(customLog))
    if self.type.onOpen then self.type.onOpen(self) end
    self:prepDrawTransition()
    self:redraw()
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then box:otherBoxOpened(self) end
    end
end

function Box:press()
    if not pyramid.playing then return false end
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
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self and not box:preOtherBoxRevealed(self) then return end
    end
    if self.type.preReveal then self.type.preReveal(self) end
    self.revealed = true
    pyramid:countStats()
    local offset = revealSound:getOffset()
    if offset > 0.05 or offset == 0 then
        revealSound:play()
    end
    pyramid.fx:addEffect(RevealEffect(self.sprite.x, self.sprite.y))
    local customLog = "box."..self.type.id..".reveal"
    pyramid:log(self, tr(customLog) == customLog and tr("log.reveal"):gsub("#", self:name()) or tr(customLog))
    if self.type.onReveal then self.type.onReveal(self) end
    self:redraw()
end

function Box:destroy()
    if not pyramid.playing or self.destroyed then return end
    local customLog = self.revealed and ("box."..self.type.id..".destroy") or ""
    pyramid:log(self, tr(customLog) == customLog and tr("log.destroy"):gsub("#", self:name()) or tr(customLog))
    local wasOpen = self.opened
    self.destroyed = true
    self.opened = false
    pyramid:countStats()
    local offset = destroySound:getOffset()
    if offset > 0.05 or offset == 0 then
        destroySound:play()
    end
    pyramid.fx:addEffect(DestroyEffect(self.sprite.x, self.sprite.y))
    if wasOpen and self.type.onDestroy then self.type.onDestroy(self) end
    if pyramid.cursor:box() == self then infobox:refresh() end
    self:prepDrawTransition()
    self:redraw()
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then box:otherBoxDestroyed(self) end
    end
end

function Box:close()
    if not pyramid.playing or self.destroyed or not self.opened then return end
    self.opened = false
    pyramid:countStats()
    local customLog = "box."..self.type.id..".close"
    pyramid:log(self, tr(customLog) == customLog and tr("log.close"):gsub("#", self:name()) or tr(customLog))
    closeSound:play()
    pyramid.fx:addEffect(CloseEffect(self.sprite.x, self.sprite.y))
    if self.type.onClose then self.type.onClose(self) end
    self:prepDrawTransition()
    self:redraw()
end

function Box:transform(type)
    if not pyramid.playing then return end
    if type == nil then
        local types = pyramid:availableTypes()
        type = types[types[1] == self.type and 2 or 1]
    end
    local oldName = self:name()
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then
            local result = box:preOtherBoxTransformed(self, type)
            if result ~= nil then
                type = result
            end
        end
    end
    self.justTransformed = true
    if self.opened and self.type.onTransform then self.type.onTransform(self, type) end
    self.type = type
    if self.opened and self.type.onTransformInto then self.type.onTransformInto(self) end
    if self.realType then self.realType = nil end
    if self.revealed and not self.destroyed then
        pyramid:log(self, tr("log.transform"):gsub("##", oldName):gsub("#", self:name()))
    end
    if self.revealed then
        pyramid.fx:addEffect(TransformEffect(self.sprite.x, self.sprite.y))
        self:prepDrawTransition()
    end
    for _, box in pairs(pyramid:getBoxes()) do
        if box ~= self then
            box:otherBoxTransformed(self)
        end
    end
    self:redraw()
end

function Box:revive()
    if not pyramid.playing or not self.destroyed then return end
    self.destroyed = false
    self.opened = false
    pyramid.fx:addEffect(RevealEffect(self.sprite.x, self.sprite.y))
    pyramid:log(self, tr("log.revive"):gsub("#", self:name()))
    self:prepDrawTransition()
    self:redraw()
end

function Box:useFX()
    useSound:play()
    pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
end

function Box:preOtherBoxOpened(box)
    if not self.type.preOtherBoxOpened or not pyramid.playing or not self.opened or self.destroyed then return true end
    return self.type.preOtherBoxOpened(self, box)
end

function Box:otherBoxOpened(box)
    if not self.type.onOtherBoxOpened or self.justTransformed or not pyramid.playing or not self.opened or self.destroyed then return end
    self.type.onOtherBoxOpened(self, box)
end

function Box:otherBoxPressed(box)
    if not self.type.onOtherBoxPressed or not self.opened or self.destroyed or not pyramid.playing then return false end
    return self.type.onOtherBoxPressed(self, box)
end

function Box:preOtherBoxRevealed(box)
    if not self.type.preOtherBoxRevealed or not pyramid.playing or not self.opened or self.destroyed then return true end
    return self.type.preOtherBoxRevealed(self, box)
end

function Box:preOtherBoxTransformed(box, type)
    if not self.type.preOtherBoxTransformed or not pyramid.playing or not self.opened or self.destroyed then return nil end
    return self.type.preOtherBoxTransformed(self, box, type)
end

function Box:otherBoxTransformed(box)
    if not self.type.onOtherBoxTransformed or self.justTransformed or not pyramid.playing or not self.opened or self.destroyed then return end
    self.type.onOtherBoxTransformed(self, box, oldType)
end

function Box:otherBoxDestroyed(box)
    if not self.type.onOtherBoxDestroyed or self.justTransformed or not pyramid.playing or not self.opened or self.destroyed then return end
    self.type.onOtherBoxDestroyed(self, box)
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
    if not self.revealed then return tr("box..n") end
    return tr("box."..self.type.id..".n")
end

function Box:desc()
    if not self.revealed then return tr("box..d") end
    return tr("box."..self.type.id..".d"):gsub("##", self:n2()):gsub("#", self:n())
end

function Box:displayIcon()
    if not self.revealed then return unknownImg end
    return self.type.icon
end

function Box:log(key)
    pyramid:log(self, tr("box." .. self.type.id .. "." .. (key or "log")))
end

import "boxes"