class("Pyramid").extends()

import "box"
import "cursor"

local maxRows<const> = 10

function Pyramid:init()
    self.x = 10
    self.y = 10
    self.size = consts.boxSize * maxRows
    self.numRows = 3

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
end

function Pyramid:setup()
    local newTypes = {table.unpack(boxes, 1, self.numRows * (self.numRows + 1) / 2)}
    shuffle(newTypes)
    for i, box in ipairs(self.boxes) do
        box:reset(newTypes[i])
    end
    infobox:refresh()
end

function Pyramid:repositionBoxes()
    local padding<const> = (self.size - consts.boxSize * self.numRows) / 2 + consts.boxSize / 2
    for _, box in ipairs(self.boxes) do
        box.sprite:moveTo(self.x + consts.boxSize / 2 + (box.col - 1 + (maxRows - box.row) / 2) * consts.boxSize, self.y + padding + (box.row - 1) * consts.boxSize)
        box.sprite:setVisible(box.row <= self.numRows)
        box.relativeCol = box.col * 2 + self.numRows - box.row
    end
end

function Pyramid:update()
    self.cursor:update()
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