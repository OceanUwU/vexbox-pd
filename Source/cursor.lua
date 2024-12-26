class("Cursor").extends()

local maxDistance<const> = 2

local selectSound<const> = loadSound("select")
selectSound:setVolume(0.4)

function Cursor:init()
    self.x = 0
    self.y = 0
    self.tX = 0
    self.tY = 0
    self.row = 1
    self.col = 1
    self.distance = 0
    self.goRight = true
    local img<const> = loadImg("cursor")
    self.sprites = {}
    for i = 1, 4 do
        self.sprites[i] = gfx.sprite.new(img)
        self.sprites[i]:setRotation((i - 1) * 90)
        self.sprites[i]:add()
    end
end

function Cursor:update()
    self.x = pd.math.lerp(self.x, self.tX, 1.0 - math.pow(0.00001, delta))
    self.y = pd.math.lerp(self.y, self.tY, 1.0 - math.pow(0.00001, delta))
    self.distance = math.sin(lifetime * 2.0) * maxDistance / 2 + maxDistance / 2 - 1
    for i, sprite in ipairs(self.sprites) do
        local xDir = ((i - 1) % 3 == 0) and -1 or 1
        local yDir = (i > 2) and 1 or -1
        sprite:moveTo(self.x + xDir * (consts.boxSize / 2 + self.distance) + ((xDir == 1) and 0 or 1), self.y + yDir * (consts.boxSize / 2 + self.distance) + ((yDir == 1) and 0 or 1))
    end
end

function Cursor:moveHoriz(dir)
    if not pyramid.playing then return end
    local row = pyramid:nonDestroyedInRow(self.row)
    if #row == 0 then return
    elseif #row == 1 then
        if self:box().destroyed then
            self.col = row[(dir == 1) and 1 or #row].col
            self:onMove()
        end
        return
    else
        if (self:box().destroyed and ((dir == 1 and row[#row].col > self:box().col) or (dir == -1 and row[1].col < self:box().col))) or row[dir == 1 and #row or 1] == self:box() then
            self.col = row[(dir == 1) and 1 or #row].col
            self:onMove()
        else
            for i = (dir == 1) and 1 or #row, (dir == 1) and #row or 1, dir do
                if (dir == 1 and row[i].col > self:box().col) or (dir == -1 and row[i].col < self:box().col) then
                    self.col = row[i].col
                    self:onMove()
                    return
                end
            end
        end
    end
end

function Cursor:moveVert(dir)
    if not pyramid.playing then return end
    local checkRow = self.row
    repeat
        checkRow += dir
        if checkRow > pyramid.numRows then checkRow = 1
        elseif checkRow < 1 then checkRow = pyramid.numRows end
        local row = pyramid:nonDestroyedInRow(checkRow)
        if #row > 0 then
            if #row == 1 then self.col = row[1].col
            else
                local relCol = self:box().relativeCol
                table.sort(row, function(a, b)
                    if a.relativeCol == comp then return true end
                    local diffA = relCol - a.relativeCol
                    local diffB = relCol - b.relativeCol
                    if self.goRight then
                        diffA *= -1
                        diffB *= -1
                    end
                    if diffA < 0 then diffA -= 0.5 end
                    if diffB < 0 then diffB -= 0.5 end
                    diffA = math.abs(diffA)
                    diffB = math.abs(diffB)
                    return diffA < diffB
                end)
                if row[1].relativeCol ~= relCol then
                    self.goRight = row[1].relativeCol < relCol
                end
                self.col = row[1].col
            end
            self.row = checkRow
            self:onMove()
            return
        end
    until checkRow == self.row
end

function Cursor:onPressA()
    if not pyramid.playing then return end
    if self:box().opened then
        self:box():press()
    else
        self:box():open()
    end
    infobox:refresh()
end
function Cursor:onPressB()
    pyramid:setup()
end
function Cursor:onPressRight() self:moveHoriz(1) end
function Cursor:onPressLeft() self:moveHoriz(-1) end
function Cursor:onPressDown() self:moveVert(1) end
function Cursor:onPressUp() self:moveVert(-1) end

function Cursor:onMove()
    self.tX = self:box().sprite.x
    self.tY = self:box().sprite.y
    selectSound:play()
    infobox:refresh()
end

function Cursor:box() return pyramid.rows[self.row][self.col] end