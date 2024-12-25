class("Pyramid").extends()

import "box"
import "cursor"

local maxRows<const> = 10

function Pyramid:init()
    self.x = 10
    self.y = 10
    self.size = consts.boxSize * maxRows
    self.numRows = 1

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

function Pyramid:repositionBoxes()
    local padding<const> = (self.size - consts.boxSize * self.numRows) / 2 + consts.boxSize / 2
    for _, box in ipairs(self.boxes) do
        box.sprite:moveTo(self.x + consts.boxSize / 2 + (box.col - 1 + (maxRows - box.row) / 2) * consts.boxSize, self.y + padding + (box.row - 1) * consts.boxSize)
        box.sprite:setVisible(box.row <= self.numRows)
    end
end

function Pyramid:update()
    self.cursor:update()
end