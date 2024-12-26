class("WinLossBox").extends()

local restartSound<const> = loadSound("restart")
local showTime<const> = 0.6
local restartPos<const> = 23

function WinLossBox:init()
    self.sprite = gfx.sprite.new()
    self.sprite:setSize(100, 30)
    self.sprite:setCenter(0, 1)
    self.sprite:add()
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
end

function WinLossBox:show(won)
    self.shown = true
    self.showing = true
    self.startShowProgress = self.showProgress
    self.showTime = 0

    local img = gfx.image.new(self.sprite.width, self.sprite.height)
    gfx.pushContext(img)

    gfx.drawRoundRect(-20, -20, self.sprite.width + 20, self.sprite.height + 20, 5)
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
        self.sprite:moveTo(0, y)
        self.restartSprite:moveTo(restartPos, y + restartPos)
        self.restartButtonSprite:moveTo(self.restartSprite.x, self.restartSprite.y)
    end
    if restarting then
        if restartSound:isPlaying() then
            self.restartSprite:setRotation(1 - math.pow(1 - restartSound:getOffset() / restartSound:getLength(), 3) * 360)
        else
            self.restartSprite:setRotation(0)
            if not unrestarting then
                pyramid:setup()
                self.showing = false
                self.showTime = 0
                self.startShowProgress = self.showProgress
            end
            restarting = false
            unrestarting = false
        end
    end
end

function WinLossBox:onPressB()
    if not restarting then
        restarting = true
        restartSound:play(1, 1)
    else
        unrestarting = false
        restartSound:setRate(1)
    end
end

function WinLossBox:onReleaseB()
    if restarting and not unrestarting then
        unrestarting = true
        restartSound:setRate(-1)
    end
end