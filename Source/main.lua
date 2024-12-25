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

pd.getSystemMenu():addMenuItem(tr("menuoption.restart"), function() print("new game") end)

function main()
    gfx.drawText("hi", 5, 5)
end

main()

function pd.update()
    delta = pd.getElapsedTime()
    pd.resetElapsedTime()

    gfx.sprite.update()
    pd.timer.updateTimers()
end