class("Pyramid").extends()

import "box"
import "cursor"
import "winlossbox"

local winSound<const> = loadSound("win")
local loseSound<const> = loadSound("lose")
local goldSound<const> = loadSound("gold")

function Pyramid:init()
    self.x = 10
    self.y = 10
    self.size = consts.boxSize * consts.maxRows
    self.numRows = 0
    self.winsNeeded = -1
    self.totalWins = 0
    self.streak = 0
    local gameData = pd.datastore.read()
    if gameData then
        self.totalWins = gameData.wins
        self.streak = gameData.streak
    end

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

function Pyramid:setup()
    self.numRows = 0
    self.winsNeeded = -1
    self.gold = 0
    self.opened = 0
    for i, needed in ipairs(consts.winsNeeded) do
        if self.totalWins >= needed then self.numRows = i
        else
            self.winsNeeded = needed
            break
        end
    end
    print(self.numRows)
    self.playing = true
    local newTypes = {table.unpack(boxes, 1, self.numRows * (self.numRows + 1) / 2)}
    shuffle(newTypes)
    for i, box in ipairs(self.boxes) do
        box:reset(newTypes[i])
    end
    self:countStats()
    self:repositionBoxes()
    self.cursor:reposition()
    infobox:refresh()
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
        box.sprite:moveTo(self.x + consts.boxSize / 2 + (box.col - 1 + (consts.maxRows - box.row) / 2) * consts.boxSize, self.y + padding + (box.row - 1) * consts.boxSize)
        box.sprite:setVisible(box.row <= self.numRows)
        box.relativeCol = box.col * 2 + self.numRows - box.row
    end
end

function Pyramid:update()
    self.cursor:update()
    self.winLossBox:update()
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

function Pyramid:win()
    self:internalWin()
end

function Pyramid:lose()
    self:internalLose()
end

function Pyramid:internalWin()
    self.playing = false
    self.fsfxTable = self.winFrames
    self.fsfxframe = 0
    winSound:play()
    self.winLossBox:show(true)
    self.totalWins += 1
    if self.numRows >= consts.maxRows then self.streak += 1 end
    pd.datastore.write({ wins = self.totalWins, streak = self.streak })
end

function Pyramid:internalLose()
    self.playing = false
    self.fsfxTable = self.loseFrames
    self.fsfxframe = 0
    loseSound:play()
    self.winLossBox:show(false)
    self.streak = 0
    pd.datastore.write({ wins = self.totalWins, streak = self.streak })
end

function Pyramid:gainGold(amount)
    self.gold += amount
    goldSound:play()
end

function Pyramid:spendGold(cost, action)
    if self.gold >= cost then
        self.gold -= cost
        action()
    end
end