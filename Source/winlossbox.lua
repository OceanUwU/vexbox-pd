class("WinLossBox").extends()

local restartSound<const> = loadSound("restart")
local showTime<const> = 0.6
local restartPos<const> = 23

function WinLossBox:init()
    self.sprite = gfx.sprite.new()
    self.sprite:setSize(100, 30)
    self.sprite:setCenter(0, 1)
    self.sprite:add()
    self.sprite:setVisible(false)
    self.restartSprite = gfx.sprite.new(loadImg("restart"))
    self.restartSprite:moveTo(restartPos, restartPos)
    self.restartSprite:add()
    self.restartButtonSprite = gfx.sprite.new(loadImg("restartbutton"))
    self.restartButtonSprite:moveTo(self.restartSprite.x, self.restartSprite.y)
    self.restartButtonSprite:add()
    self.restarting = false
    self.unrestarting = false
    self.shown = false
    self.showing = false
    self.startShowProgress = 0
    self.showProgress = 0
    self.showTime = showTime
    self.tY = nil
end

function WinLossBox:show(won)
    self.sprite:setVisible(true)
    self.shown = true
    self.showing = true
    self.inverted = pyramid.inverted
    self.startShowProgress = self.showProgress
    self.showTime = 0

    local img = gfx.image.new(self.sprite.width, self.sprite.height)
    gfx.pushContext(img)

    gfx.setColor(gfx.kColorWhite)
    if self.inverted then
        gfx.fillRoundRect(-20, 0, self.sprite.width + 20, self.sprite.height + 20, 5)
    else
        gfx.fillRoundRect(-20, -20, self.sprite.width + 20, self.sprite.height + 20, 5)
    end
    gfx.setColor(gfx.kColorBlack)
    if self.inverted then
        gfx.drawRoundRect(-20, 0, self.sprite.width + 20, self.sprite.height + 20, 5)
    else
        gfx.drawRoundRect(-20, -20, self.sprite.width + 20, self.sprite.height + 20, 5)
    end
    fontLg:drawText(tr(won and "wl.win" or "wl.lose"), 5, 3)
    fontSm:drawText(tr("wl.restart"), 5, 18)

    gfx.popContext()
    self.sprite:setImage(img)
end

function WinLossBox:update()
    if self.showTime < showTime then
        self.showTime = math.min(self.showTime + delta, showTime)
        if self.showing then
            self.showProgress = self.startShowProgress + (1 - math.pow(1 - self.showTime / showTime, 2)) * (1 - self.startShowProgress)
        else 
            self.showProgress = self.startShowProgress - (1 - math.pow(1 - self.showTime / showTime, 2)) * self.startShowProgress
        end
        local y = self.showProgress * self.sprite.height
        if self.inverted then y = 240 + self.sprite.height - y end
        self.sprite:moveTo(0, y)
        self.restartSprite:moveTo(restartPos, y + (self.inverted and (-restartPos - self.sprite.height) or restartPos))
        self.restartButtonSprite:moveTo(self.restartSprite.x, self.restartSprite.y)
        if self.showTime >= showTime then
            self.shown = self.showing
            self.sprite:setVisible(self.shown)
        end
    elseif self.tY ~= nil then
        if math.abs(self.restartSprite.y - self.tY) <= 1 then
            self.restartSprite:moveTo(self.restartSprite.x, self.tY)
            self.tY = nil
        else
            self.restartSprite:moveTo(self.restartSprite.x, pd.math.lerp(self.restartSprite.y, self.tY, 1.0 - math.pow(0.00001, delta)))
        end
        self.restartButtonSprite:moveTo(self.restartSprite.x, self.restartSprite.y)
    end
    if self.restarting then
        if restartSound:isPlaying() then
            self.restartSprite:setRotation(1 - math.pow(1 - restartSound:getOffset() / restartSound:getLength(), 3) * 360)
        else
            self.restartSprite:setRotation(0)
            if not self.unrestarting then
                if pyramid.playing then
                    pyramid:destroyStreak()
                end
                pyramid:setup()
                self.showing = false
                self.showTime = 0
                self.startShowProgress = self.showProgress
            end
            self.restarting = false
            self.unrestarting = false
        end
    end
end

function WinLossBox:move()
    if pyramid.inverted then
        self.tY = 240 - restartPos
    else
        self.tY = restartPos
    end
end

function WinLossBox:onPressB()
    if not self.restarting then
        self.restarting = true
        self.unrestarting = false
        restartSound:play(1, 1)
    else
        self.unrestarting = false
        restartSound:setRate(1)
    end
end

function WinLossBox:onReleaseB()
    if self.restarting and not self.unrestarting then
        self.unrestarting = true
        restartSound:setRate(-1)
    end
end