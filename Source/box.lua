class("Box").extends()

local boxImages = { unknown = loadImg("box/icon-unknown") }
local borderImages<const> = { closed = loadImg("box/border/closed"), revealed = loadImg("box/border/revealed"), open = loadImg("box/border/open") }
local borderSize<const> = 2
local emptyImage<const> = gfx.image.new(22, 22)

function loadBoxImages()
    for _, type in ipairs(consts.boxTypes) do
        boxImages[type] = loadImg("box/icon/" .. type)
    end
end

function Box:init(row, col)
    self.row = row
    self.col = col
    self.type = ""
    self.sprite = gfx.sprite.new()
    self.sprite:add()
    self:reset("")
end

function Box:reset(newType)
    self.type = newType
    self.revealed = false
    self.opened = false
    self.destroyed = false
    self:redraw()
end

function Box:redraw()
    local img = gfx.image.new(consts.boxSize, consts.boxSize)
    gfx.pushContext(img)

    if not self.destroyed then
        local border
        if opened then border = borderImages.open
        elseif revealed then border = borderImages.revealed
        else border = borderImages.closed end
        border:draw(0, 0)
        
        local icon = boxImages[revealed and self.type or "unknown"]
        icon:draw(borderSize, borderSize)
    end

    gfx.popContext()
    self.sprite:setImage(img)
end

function Box:open()
    if self.opened or self.destroyed then return end
    self.opened = true
    self.revealed = true
    self:redraw()
end

function Box:reveal()
    self.revealed = true
    self:redraw()
end

function Box:destroy()
    self.destroyed = true
    self:redraw()
end