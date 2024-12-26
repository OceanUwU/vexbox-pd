import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/math"
import "CoreLibs/animation"
import "CoreLibs/timer"

pd = playdate
gfx = playdate.graphics
sfx = playdate.sound
tr = gfx.getLocalizedText

fontSm = gfx.font.new("assets/fonts/font-Bitmore")
fontSm:setTracking(1)
fontMd = gfx.font.new("assets/fonts/Nontendo-Light")
fontMd:setTracking(1)
fontLg = gfx.font.new("assets/fonts/font-pixieval-large-black")
fontLg:setTracking(1)

import "util"
import "consts"
import "pyramid"
import "infobox"

pd.getSystemMenu():addMenuItem(tr("menuoption.restart"), function() print("new game") end)

function main()
    pd.display.setRefreshRate(50)
    lifetime = 0
    pyramid = Pyramid()
    infobox = Infobox()
    pyramid:setup()
end

main()

function pd.update()
    delta = pd.getElapsedTime()
    lifetime += delta
    pd.resetElapsedTime()

    pyramid:update()
    infobox:update()

    gfx.sprite.update()
    pd.timer.updateTimers()
end

playdate.AButtonDown = function() pyramid.cursor:onPressA() end
playdate.BButtonDown = function() pyramid.cursor:onPressB() end
playdate.leftButtonDown = function() pyramid.cursor:onPressLeft() end
playdate.rightButtonDown = function() pyramid.cursor:onPressRight() end
playdate.upButtonDown = function() pyramid.cursor:onPressUp() end
playdate.downButtonDown = function() pyramid.cursor:onPressDown() end