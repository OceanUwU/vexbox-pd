class("Pyramid").extends()

import "box"
import "cursor"
import "winlossbox"
import "fx"

local winSound<const> = loadSound("win")
local loseSound<const> = loadSound("lose")
local goldSound<const> = loadSound("gold")
musicPlayer = sfx.fileplayer.new("assets/sfx/boiler")

function Pyramid:init()
    self.x = 10
    self.y = 10
    self.size = consts.boxSize * consts.maxRows
    self.numRows = 0
    self.winsNeeded = -1
    self.totalWins = 0
    self.streak = 0
    local gameData = pd.datastore.read()
    local inverted = false
    if gameData then
        self.totalWins = gameData.w
        self.streak = gameData.s
        inverted = gameData.i
    end
    pd.display.setInverted(inverted)
    pd.getSystemMenu():addCheckmarkMenuItem(tr("menuitem.invert"), inverted, function(nowInverted)
        pd.display.setInverted(nowInverted)
        self:save()
    end)

    self.bg = gfx.sprite.new()
    self.bg:setSize(400, 240)
    self.bg:setCenter(0, 0)
    self.bg:add()
    self.bgOpacity = 0
    self.targetBg = 0

    self.rows = {}
    self.boxes = {}
    for i = 1, 10 do
        local row = {}
        for j = 1, i do
            table.insert(row, Box(i, j))
            table.insert(self.boxes, row[j])
        end
        self.rows[i] = row
    end
    self:repositionBoxes()

    self.fx = FX()

    self.cursor = Cursor()
    self.cursor.tX = self.boxes[1].sprite.x
    self.cursor.x = self.cursor.tX
    self.cursor.tY = self.boxes[1].sprite.y
    self.cursor.y = self.cursor.tY

    self.fsfxsprite = gfx.sprite.new()
    self.fsfxsprite:setCenter(0, 0)
    self.fsfxsprite:add()
    self.fsfxframe = 0
    self.fsfxTable = nil
    self.winFrames = gfx.imagetable.new("assets/img/win-fx")
    self.loseFrames = gfx.imagetable.new("assets/img/lose-fx")

    self.winLossBox = WinLossBox()
end

function Pyramid:availableTypes()
    local newTypes = { table.unpack(boxesNoGroups, 1, self.availableBoxes) }
    shuffle(newTypes)
    return newTypes
end

function Pyramid:setup()
    musicPlayer:stop()
    self.numRows = 0
    self.winsNeeded = -1
    self.gold = 0
    self.opened = 0
    self.targetBg = 0
    self.availableBoxes = 0
    self.numBoxes = 0
    for i, needed in ipairs(consts.winsNeeded) do
        if self.totalWins >= needed then
            if i <= consts.maxRows then
                self.numRows = i
                self.availableBoxes += i
                self.numBoxes = self.availableBoxes
            else
                self.availableBoxes += consts.boxesToUnlock[i - consts.maxRows]
            end
        else
            self.winsNeeded = needed
            break
        end
    end
    self.playing = true
    local newTypes = { }
    local n = 0
    for _, type in ipairs(boxes) do
        table.insert(newTypes, type)
        if type.id then
            n += 1
        else
            n += #type
        end
        if n >= self.availableBoxes then
            break
        end
    end
    local newTypes2 = { }
    shuffle(newTypes)
    local skipped = 0
    for i, type in ipairs(newTypes) do
        if not type.id then
            if #newTypes2 + #type <= self.numBoxes then
                for _, innerType in ipairs(type) do
                    table.insert(newTypes2, innerType)
                end
            end
        else
            table.insert(newTypes2, type)
        end
        if #newTypes2 >= self.numBoxes then break end
    end
    shuffle(newTypes2)
    --[[
    for i, t in ipairs({ --test boxes
        "music",
        "music",
        "demo",
        "demo"
    }) do
        newTypes2[i] = boxesById[t]
    end
    --]]
    for i, box in ipairs(self.boxes) do
        box:reset(newTypes2[i + skipped])
    end
    self:countStats()
    self:repositionBoxes()
    self.cursor:reposition()
    infobox:refresh()
    infobox.log:reset()
end

function Pyramid:countStats()
    self.opened = 0
    self.revealed = 0
    self.destroyed = 0
    for _, box in ipairs(self.boxes) do
        if box.row > self.numRows then return end
        if box.destroyed then self.destroyed += 1
        elseif box.revealed then
            self.revealed += 1
            if box.opened then self.opened += 1 end
        end
    end
end

function Pyramid:repositionBoxes()
    local padding<const> = (self.size - consts.boxSize * self.numRows) / 2 + consts.boxSize / 2
    for _, box in ipairs(self.boxes) do
        if box.row > self.numRows then break end
        box.sprite:moveTo(self.x + consts.boxSize / 2 + (box.col - 1 + (consts.maxRows - box.row) / 2) * consts.boxSize, box.sprite.y)
        box.tY = self.y + padding + (box.row - 1) * consts.boxSize
        box.sprite.tScale = box.row <= self.numRows and 1 or 0
        local shouldShow = box.row <= self.numRows
        local shows = box.sprite:isVisible()
        if box.y == nil then
            box.y = box.tY
            shows = false
        end
        if not shows then
            box.y = box.tY
            box.sprite:moveTo(box.sprite.x, box.y)
            box.scale = 0
        end
        box.sprite:setVisible(shouldShow)
        box.relativeCol = box.col * 2 + self.numRows - box.row
    end
end

function Pyramid:update()
    self.fx:update()
    self.cursor:update()
    self.winLossBox:update()
    for _, box in ipairs(self.boxes) do box:update() end
    if self.fsfxTable then
        self.fsfxframe += 1
        if self.fsfxframe > self.fsfxTable:getLength() then
            self.fsfxsprite:setVisible(false)
            self.fsfxTable = nil
        else
            self.fsfxsprite:setVisible(true)
            self.fsfxsprite:setImage(self.fsfxTable:getImage(self.fsfxframe))
        end
    end
    if self.targetBg ~= self.bgOpacity then
        self.bgOpacity = pd.math.lerp(self.bgOpacity, self.targetBg, 1.0 - math.pow(0.00001, delta))
        if math.abs(self.bgOpacity - self.targetBg) < 0.001 then self.bgOpacity = self.targetBg end

        local img = gfx.image.new(self.bg.width, self.bg.height)
        gfx.pushContext(img)
        gfx.setDitherPattern(1 - self.bgOpacity, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0, 0, self.bg.width, self.bg.height)
        gfx.popContext()
        self.bg:setImage(img)
    end
end

function Pyramid:nonDestroyedInRow(rowNum)
    local row = {}
    for i, box in ipairs(self.rows[rowNum]) do
        if not box.destroyed then table.insert(row, box) end
    end
    return row
end

function Pyramid:getBoxes(predicate)
    local boxes = {}
    for _, box in ipairs(self.boxes) do
        if box.row > self.numRows then break end
        if not predicate or predicate(box) then
            table.insert(boxes, box)
        end
    end
    return boxes
end

function Pyramid:revealRandom(amount)
    local revealed = {}
    for i = 1, amount do
        local boxes = self:getBoxes(function(box) return not box.revealed and not box.destroyed and not box.opened end)
        if #boxes == 0 then break end
        local box = boxes[math.random(#boxes)]
        box:reveal()
        table.insert(revealed, box)
    end
    if #revealed == 0 then return nil end
    return revealed
end

function Pyramid:getBox(type)
    for _, box in ipairs(self.boxes) do
        if box.row > self.numRows then break end
        if box.type.id == type and box.opened and not box.destroyed then
            return box
        end
    end
end

function Pyramid:winOrLose(win)
    for _, box in ipairs(self:getBoxes(function(b) return b.type.id == "invert" and b.opened and not b.destroyed end)) do
        box:log(win and "win" or "lose")
        win = not win
    end
    if win then self:internalWin() else self:internalLose() end
end

function Pyramid:win()
    self:winOrLose(true)
end

function Pyramid:lose()
    self:winOrLose(false)
end

function Pyramid:internalWin()
    if not self.playing then return end
    local curse = self:getBox("curse")
    if curse then
        curse:log()
        curse:destroy()
        return
    end
    self.playing = false
    self.targetBg = 0.1
    self.fsfxTable = self.winFrames
    self.fsfxframe = 0
    winSound:play()
    self.winLossBox:show(true)
    self.totalWins += 1
    if self.numRows >= consts.maxRows then self.streak += 1 end
    self:save()
end

function Pyramid:internalLose()
    if not self.playing then return end
    local life = self:getBox("life")
    if life then
        life:log()
        life:destroy()
        return
    end
    self.targetBg = 0.5
    self.playing = false
    self.fsfxTable = self.loseFrames
    self.fsfxframe = 0
    loseSound:play()
    self.winLossBox:show(false)
    self:destroyStreak()
end

function Pyramid:destroyStreak()
    self.streak = 0
end

function Pyramid:save()
    pd.datastore.write({ w = self.totalWins, s = self.streak, i = pd.display.getInverted() })
end

function Pyramid:gainGold(amount)
    self.gold += amount
    goldSound:play()
    for i = 1, amount do
        self.fx:addEffect(CoinEffect())
    end
end

function Pyramid:spendGold(cost, action)
    if self.gold >= cost then
        self.gold -= cost
        action()
    end
end

function Pyramid:log(box, text)
    infobox.log:add(box:displayIcon(), text)
end