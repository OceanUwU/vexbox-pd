boxes = {

{ -- ROW 1
    id = "win",
    onOpen = function(self) pyramid:win() end
},

{ -- ROW 2
    id = "lose",
    onOpen = function(self) pyramid:lose() end
}, {
    id = "reveal",
    n = 1,
    onOpen = function(self) pyramid:revealRandom(self:n()) end
},

{ -- ROW 3
    id = "star",
    onOpen = function(self)
        for _, box in pairs(self:getAdjacent(1)) do
            if not box.opened and not box.destroyed then return end
        end
        self:log()
        pyramid:win()
    end
}, {
    id = "egg",
    onDestroy = function(self) pyramid:win() end
}, {
    id = "bomb",
    onOtherBoxOpened = function(self, box, wasRevealed)
        self:log()
        self:destroy()
        for _, b in pairs(self:getAdjacent(1)) do b:destroy() end
    end
},

{ -- ROW 4
    id = "onegold",
    n = 1,
    onOpen = function(self) pyramid:gainGold(self:n()) end
}, {
    id = "twogold",
    n = 2,
    onOpen = function(self) pyramid:gainGold(self:n()) end
}, {
    id = "telescope",
    n = 1,
    n2 = 1,
    onPress = function(self) pyramid:spendGold(self:n(), function()
        self:useFX()
        self:log()
        pyramid:revealRandom(self:n2())
    end) end
}, {
    id = "closeadjacent",
    onOpen = function(self)
        for _, box in pairs(self:getAdjacent(1)) do box:close() end
    end
},

{ -- ROW 5
    id = "empty",
}, {
    {
        id = "lock",
    }, {
        id = "key",
        onOtherBoxOpened = function(self, box, wasRevealed)
            if box.type.id == "lock" then
                self:log()
                pyramid:win()
            else
                self:destroy()
            end
        end
}
}, {
    id = "safeguard",
    onOtherBoxPressed = function(self, box)
        if not box.revealed then
            self:destroy()
            box:reveal()
            return true
        end
        return false
    end
}, {
    id = "walkie",
    n = 2,
    onOpen = function(self)
        local boxes = self:getAdjacent(1, function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:reveal() end end
    end
},

{ -- ROW 6
    id = "mimic",
    n = 50,
    preReveal = function(self)
        self.realType = self.type
        self.type = pyramid:availableTypes()[1]
    end,
    onOpen = function(self)
        if math.random() * 100 < self:n() then
            self:log()
            pyramid:lose()
        end
    end
}, {
    id = "heartbreak",
    n = 10,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if math.random() * 100 < self:n() then
            self:log()
            pyramid:lose()
        end
    end
}, {
    id = "demo",
    onOtherBoxPressed = function(self, box)
        self:destroy()
        box:destroy()
        return true
    end
}, {
    id = "safe",
    onDestroy = function(self) pyramid:lose() end
}, {
    id = "rowbomb",
    onOtherBoxOpened = function(self, box, wasRevealed)
        if box.row == self.row then
            self:log()
            self:destroy()
            for _, b in pairs(pyramid.rows[self.row]) do b:destroy() end
        end
    end
}, {
    id = "invert",
},

{ -- ROW 7
    {
        id = "school",
        n = 3,
        onOpen = function(self)
            local boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
            shuffle(boxes)
            for i = 1, self:n() do if boxes[i] then boxes[i]:transform(boxesById.fish) end end
        end
    }, {
        id = "fish",
        n = 3,
        onOpen = function(self)
            if #pyramid:getBoxes(function(b) return not b.destroyed and b.opened and b.type.id == "fish" end) >= self:n() then
                self:log()
                pyramid:win()
            end
        end
    }
}, {
    id = "smartbomb",
    onOpen = function(self)
        for _, b in pairs(self:getAdjacent(1)) do b:reveal() end
    end,
    onOtherBoxOpened = function(self, box, wasRevealed)
        self:log()
        self:destroy()
        for _, b in pairs(self:getAdjacent(1)) do b:destroy() end
    end
}, {
    id = "tape",
    onOtherBoxPressed = function(self, box)
        if box ~= self and box.opened then
            self:destroy()
            box:close()
            return true
        end
        return false
    end
}, {
    id = "rowwin",
    onOpen = function(self, box)
        for _, b in pairs(pyramid.rows[self.row]) do if not b.opened and not b.destroyed then return end end
        self:log()
        pyramid:win()
    end
}, {
    id = "curse",
}, {
    id = "music",
    onOpen = function(self) musicPlayer:play(0) end,
    onClose = function(self) musicPlayer:stop() end,
    onDestroy = function(self) musicPlayer:stop() end,
    onTransform = function(self) musicPlayer:stop() end
},

{ -- ROW 8
    {
        id = "sword",
    }, {
        id = "dragon",
        onOpen = function(self)
            if pyramid:getBox("sword") then
                self:log()
                pyramid:win()
            else
                pyramid:lose()
            end
        end
    }
}, {
    id = "shadow",
    n = 1,
    onOpen = function(self)
        local boxes = pyramid:getBoxes(function(b) return b ~= self and not b.destroyed and b.opened end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:close() end end
    end
}, {
    id = "bux",
    n = 3,
    onOpen = function(self) pyramid:gainGold(self:n()) end
}, {
    id = "mine",
    n = 1,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if self:isAdjacent(box, 1) then
            self:log()
            pyramid:gainGold(self:n())
        end
    end
}, {
    id = "slots",
    n = 2,
    n2 = 3,
    onPress = function(self) pyramid:spendGold(self:n(), function()
        self:useFX()
        self:log()
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n2() do if boxes[i] then boxes[i]:transform(boxesById.win) end end
    end) end
}, {
    id = "waterfall",
    n = 1,
    onOpen = function(self)
        if self.row == pyramid.numRows then
            self:log()
            pyramid:win()
        end
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed and b.row == self.row + 1 end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:transform(boxesById.waterfall) end end
    end
}, {
    id = "ghost",
    n = 2,
    onOpen = function(self)
        local boxes = pyramid:getBoxes(function(b) return self ~= b and not b.destroyed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:transform(boxesById.lose) end end
    end
},

{ -- ROW 9
    id = "dna",
    onOpen = function(self)
        local type = pyramid:availableTypes()[1]
        local shouldReveal = false
        for _, b in pairs(self:getAdjacent(1)) do
            b:transform(type)
            if b.revealed and not b.destroyed then shouldReveal = true end
        end
        if shouldReveal then
            for _, b in pairs(self:getAdjacent(1)) do b:reveal() end
        end
    end,
}, {
    id = "fairy",
    n = 4,
    n2 = 1,
    onOpen = function(self)
        if #pyramid:getBoxes(function(b) return b.type.id == "fairy" and not b.destroyed and b.opened end) >= self:n() then
            self:log()
            pyramid:win()
        end
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n2() do if boxes[i] then boxes[i]:transform(boxesById.fairy) end end
    end
}, {
    {
        id = "xmarksthespot",
        onOpen = function(self)
            local seen = {}
            local stack = {self}
            while #stack > 0 do
                local cur = stack[1]
                table.remove(stack, 1)
                if table.indexOfElement(seen, cur) == nil then
                    table.insert(seen, cur)
                    for _, box in ipairs(cur:getAdjacent(1)) do
                        if not box.destroyed and box.opened then
                            if box.type.id == "map" then
                                self:log()
                                pyramid:win()
                                return
                            end
                            table.insert(stack, 1, box)
                        end
                    end
                end
            end
        end
    }, {
        id = "map",
        onOpen = function(self)
            for _, b in ipairs(pyramid:getBoxes(function(b) return b.type.id == "xmarksthespot" end)) do
                b:reveal()
            end
        end
    }
}, {
    id = "sacrifice",
    n = 1,
    n2 = 1,
    onPress = function (self)
        self:useFX()
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:destroy() end end
        boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n2() do if boxes[i] then boxes[i]:reveal() end end
    end
}, {
    id = "3d",
    n = 3,
    onOpen = function(self) pyramid:revealRandom(self:n()) end
}, {
    id = "rowreveal",
    onOpen = function(self)
        for _, b in ipairs(pyramid:getBoxes(function(b) return b.row == self.row end)) do
            b:reveal()
        end
    end
}, {
    id = "life",
}, {
    id = "princess",
    n = 3,
    onOpen = function(self)
        if #pyramid:getBoxes(function(b) return b.type.id == "dragon" and (not b.realType or b.realType.id == "dragon") and b.revealed and not b.destroyed end) > 0 then
            self:log("lose")
            pyramid:lose()
            return
        end
        pyramid:gainGold(self:n())
    end
},

{ -- ROW 10
    id = "paytoclose",
    n = 1,
    n2 = 1,
    onPress = function(self) pyramid:spendGold(self:n(), function()
        self:useFX()
        local boxes = pyramid:getBoxes(function(b) return b ~= self and b.opened and not b.destroyed end)
        shuffle(boxes)
        self:log()
        for i = 1, self:n2() do if boxes[i] then boxes[i]:close() end end
    end) end
}, {
    id = "checkbox",
    n = 1,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if not wasRevealed then pyramid:revealRandom(self:n()) end
    end
}, {
    id = "police",
    n = 15,
    onOpen = function(self)
        if #pyramid:getBoxes(function(b) return not b.destroyed and b.opened end) >= self:n() then
            self:log()
            pyramid:lose()
        end
    end
}, {
    id = "revival",
    n = 5,
    onOpen = function(self)
        local boxes = pyramid:getBoxes(function(b) return b.destroyed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then
            boxes[i]:revive()
            boxes[i]:close()
        end end
    end
}, {
    id = "gamer",
    onOpen = function(self)
        if pyramid.streak > 0 then
            self:log()
            pyramid:win()
        end
    end
}, {
    id = "daredevil",
    n = 40,
    onPress = function(self)
        self:useFX()
        if math.random() * 100 < self:n() then
            self:log("win")
            pyramid:win()
        else
            self:log("lose")
            pyramid:lose()
        end
    end
}, {
    {
        id = "cloak",
        onOpen = function(self)
            if pyramid:getBox("cloak") and pyramid:getBox("wand") and pyramid:getBox("hat") then
                self:log()
                pyramid:win()
            end
        end
    }, {
        id = "wand",
        onOpen = function(self)
            if pyramid:getBox("cloak") and pyramid:getBox("wand") and pyramid:getBox("hat") then
                self:log()
                pyramid:win()
            end
        end
    }, {
        id = "hat",
        onOpen = function(self)
            if pyramid:getBox("cloak") and pyramid:getBox("wand") and pyramid:getBox("hat") then
                self:log()
                pyramid:win()
            end
        end
    }
}, {
    id = "crumbling",
    n = 1,
    onOtherBoxOpened = function(self, box, wasRevealed)
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed end)
        if #boxes > 0 then self:log() end
        for i = 1, self:n() do if boxes[i] then boxes[i]:destroy() end end
    end
},

{ -- UNLOCK SET 1
    id = "cascade",
    onOtherBoxOpened = function (self, box, wasRevealed)
        if not self:isAdjacent(box, 1) then return end
        local boxes = self:getAdjacent(1, function(b) return not b.destroyed end)
        for _, b in ipairs(boxes) do
            if not b.destroyed and not b.opened then
                return
            end
        end
        self:destroy()
        for _, b in ipairs(boxes) do
            for __, b2 in ipairs(b:getAdjacent(1, function(b3) return not b3.destroyed end)) do
                b2:reveal()
            end
        end
    end
}, {
    id = "butterfly",
    onTransform = function(self)
        self:log()
        pyramid:win()
    end
}, {
    id = "alchemy",
    onOtherBoxPressed = function(self, box)
        if box ~= self and box.revealed then
            box:transform()
            self:destroy()
            return true
        end
        return false
    end
},
{
    {
        id = "viral",
        onOtherBoxOpened = function(self, box, wasRevealed)
            local boxes = self:getAdjacent(1, function(b) return not b.destroyed end)
            if #boxes == 0 then return end
            shuffle(boxes)
            self:transform(boxesById.decayed)
            boxes[1]:transform(boxesById.viral)
            boxes[1].opened = true
            boxes[1].revealed = true
            boxes[1]:reveal()
        end
    }, {
        id = "decayed",
        n = 5,
        onTransformInto = function(self)
            if #pyramid:getBoxes(function(b) return not b.destroyed and b.opened and b.type.id == "decayed" end) >= self:n() then
                self:log()
                pyramid:lose()
            end
        end
    }, {
        id = "antidote",
        onOpen = function(self)
            for _, b in pairs(pyramid:getBoxes(function(b) return not b.destroyed and b.opened and (b.type.id == "decayed" or b.type.id == "viral") end)) do
                b:destroy()
            end
        end
    }
}, {
    id = "trigaze",
    onOpen = function(self)
        pyramid.rows[1][1]:reveal()
        pyramid.rows[pyramid.numRows][1]:reveal()
        pyramid.rows[pyramid.numRows][#pyramid.rows[pyramid.numRows]]:reveal()
    end
}, {
    id = "copycat",
    onOtherBoxPressed = function(self, box)
        if box ~= self and box.revealed then
            self:transform(box.type)
            self:close()
            return true
        end
        return false
    end
}, {
    id = "catalogue",
    onOpen = function(self)
        if self.col > 1 then
            pyramid.rows[self.row][self.col - 1]:reveal()
        end
        if self.col < self.row then
            pyramid.rows[self.row][self.col + 1]:reveal()
        end
    end,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if self.col > 1 and not pyramid.rows[self.row][self.col - 1].destroyed and not pyramid.rows[self.row][self.col - 1].opened then
            pyramid.rows[self.row][self.col - 1]:transform()
        end
        if self.col < self.row and not pyramid.rows[self.row][self.col + 1].destroyed and not pyramid.rows[self.row][self.col + 1].opened then
            pyramid.rows[self.row][self.col + 1]:transform()
        end
    end
}, {
    id = "otherworld",
    onPress = function(self)
        self:useFX()
        for _, box in ipairs(pyramid:getBoxes(function(b) return b.revealed and not b.destroyed end)) do
            box:transform()
        end
    end
},

{ -- UNLOCK SET 2
    id = "searchlight",
    onOtherBoxOpened = function(self, box, wasRevealed)
        for _, b in pairs(box:getAdjacent(1)) do b:reveal() end
        self:destroy()
    end
}, {
    id = "lonely",
    onOtherBoxOpened = function(self, box, wasRevealed)
        if #box:getAdjacent(1, function(b) return not b.destroyed and b.opened end) == 0 then
            self:log()
            pyramid:lose()
        end
    end
}, {
    id = "sus",
    n = 2,
    n2 = 2,
    onOpen = function(self)
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:transform(boxesById.mimic) end end
        pyramid:revealRandom(self:n2())
    end
}, {
    id = "book",
    n = 15,
    onOpen = function(self)
        if #pyramid:getBoxes(function(b) return not b.destroyed and b.opened end) >= self:n() then
            self:log()
            pyramid:win()
        end
    end
}, {
    id = "crown",
    n = 6,
    onPress = function(self) pyramid:spendGold(self:n(), function()
        self:useFX()
        self:log()
        pyramid:win()
    end) end
}, {
    id = "stocks",
    n = 33,
    n2 = 1,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if math.random() * 100 < self:n() then
            self:log()
            pyramid.fx:addEffect(OpenEffect(self.sprite.x, self.sprite.y))
            pyramid:gainGold(self:n2())
        end
    end
}, {
    id = "shy",
    n = 33,
    onOtherBoxOpened = function(self, box, wasRevealed)
        if math.random() * 100 < self:n() then
            self:close()
        end
    end
}, {
    id = "moth",
    onOpen = function(self)
        if pyramid.gold <= 0 then
            self:log()
            pyramid:lose()
        end
    end
}, {
    id = "tool",
    onOpen = function(self)
        if self.row > 1 then
            if self.col > 1 then
                pyramid.rows[self.row - 1][self.col - 1]:transform(boxesById.demo)
                pyramid.rows[self.row - 1][self.col - 1]:reveal()
            end
            if self.col < self.row then
                pyramid.rows[self.row - 1][self.col]:transform(boxesById.demo)
                pyramid.rows[self.row - 1][self.col]:reveal()
            end
        end
        if self.row < pyramid.numRows then
            pyramid.rows[self.row + 1][self.col]:transform(boxesById.tape)
            pyramid.rows[self.row + 1][self.col]:reveal()
            pyramid.rows[self.row + 1][self.col + 1]:transform(boxesById.tape)
            pyramid.rows[self.row + 1][self.col + 1]:reveal()
        end
    end
}, {
    id = "rowgold",
    onOpen = function(self)
        local g = 0
        for _, box in ipairs(pyramid.rows[self.row]) do
            if box ~= self and box.opened and not box.destroyed then
                g += 1
            end
        end
        if g > 0 then
            pyramid:gainGold(g)
        end
    end
},

{ -- UNLOCK SET 3
    id = "soup",
}, {
    id = "brain",
}, {
    id = "deserted",
    n = 10,
}, {
    id = "firework",
    n = 4,
}, {
    id = "hammer",
    n = 50,
}, {
    id = "friendly",
}, {
    id = "armageddon",
    n = 2,
}, {
    id = "omniscient",
    n = 50,
}, {
    id = "ritual",
    n = 2,
}, {
    id = "puzzle",
    n = 30,
},

{ -- UNLOCK SET 4
    id = "espionage",
    n = 18,
}, {
    id = "vortex",
    n = 2,
}, {
    id = "lunar",
    n = 4,
}, {
    id = "flower",
}, {
    id = "speedrun",
}, {
    id = "two",
    n = 2,
}, {
    id = "stamp",
    n = 2,
}, {
    id = "button",
    n = 95,
}, {
    id = "ink",
}, {
    id = "unstable",
    n = 20,
},

{ -- UNLOCK SET 5
    id = "static",
}, {
    id = "blind",
},
{
    {
        id = "gift",
        n = 3,
        n2 = 2,
    }, {
        id = "jolly",
    }
}, {
    id = "glitched",
    n = 3,
}

}


boxesNoGroups = {}
boxesById = {}
function initType(type)
    type.icon = loadImg("box/icon/" .. type.id)
    boxesById[type.id] = type
    table.insert(boxesNoGroups, type)
end

for _, type in ipairs(boxes) do
    if type.id then
        initType(type)
    else
        for __, innertype in ipairs(type) do
            initType(innertype)
        end
    end
end