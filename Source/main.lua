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

import "util"
import "consts"
import "pyramid"

pd.getSystemMenu():addMenuItem(tr("menuoption.restart"), function() print("new game") end)

function main()
    lifetime = 0
    pyramid = Pyramid()
end

main()

function pd.update()
    delta = pd.getElapsedTime()
    lifetime += delta
    pd.resetElapsedTime()
    pyramid:update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end