class("Box").extends()

local boxList = { "win", "lose", "empty" }
local boxImages = { unknown = loadImg("box/icon-unknown") }
local borderImages<const> = { closed = loadImg("box/border/closed"), revealed = loadImg("box/border/revealed"), open = loadImg("box/border/open") }
local borderSize<const> = 2
local emptyImage<const> = gfx.image.new(22, 22)

function Box:init(row, col)
    self.row = row
    self.col = col
    self.type = ""
    self.sprite = gfx.sprite.new()
    self.sprite:add()
    self:reset("")
    self:redraw()
end

function Box:reset(newType)
    self.type = newType
    self.revealed = false
    self.open = false
end

function Box:redraw()
    local img = gfx.image.new(consts.boxSize, consts.boxSize)
    gfx.pushContext(img)

    local border
    if open then border = borderImages.open
    elseif revealed then border = borderImages.revealed
    else border = borderImages.closed end
    border:draw(0, 0)
    
    local icon = boxImages[revealed and self.type or "unknown"]
    icon:draw(borderSize, borderSize)

    gfx.popContext()
    self.sprite:setImage(img)
end