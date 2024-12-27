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
    onOpen = function(self) pyramid:revealRandom(self:power()) end
},

{ -- ROW 3
    id = "star",
    onOpen = function(self)
        for _, box in pairs(self:getAdjacent(1)) do
            if not box.opened and not box.destroyed then return end
        end
        pyramid:win()
    end
}, {
    id = "egg",
    onDestroy = function(self) pyramid:win() end
}, {
    id = "bomb",
    onOtherBoxOpened = function(self, box)
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
    id = "lock",
}, {
    id = "key",
    onOtherBoxOpened = function(self, box)
        if box.type.id == "lock" then
            self:log()
            pyramid:win()
        else
            self:destroy()
        end
    end
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
}, {
    id = "heartbreak",
    n = 10,
    onOtherBoxOpened = function(self, box)
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
    onOtherBoxOpened = function(self, box)
        if box.row == self.row then
            self:destroy()
            for _, b in pairs(pyramid.rows[self.row]) do b:destroy() end
        end
    end
}, {
    id = "invert",
    onOpen = function(self)
        local boxes = pyramid:getBoxes(function(b) return not b.destroyed and not b.revealed end)
        shuffle(boxes)
        for i = 1, self:n() do if boxes[i] then boxes[i]:transform(boxesById.fish) end end
    end
},

{ -- ROW 7
    id = "school",
}, {
    id = "fish",
}, {
    id = "smartbomb",
}, {
    id = "tape",
}, {
    id = "rowwin",
}, {
    id = "curse",
}, {
    id = "music",
},

{ -- ROW 8
    id = "sword",
}, {
    id = "dragon",
}, {
    id = "shadow",
}, {
    id = "bux",
}, {
    id = "mine",
}, {
    id = "slots",
}, {
    id = "waterfall",
}, {
    id = "ghost",
},

{ -- ROW 9
    id = "dna",
}, {
    id = "fairy",
}, {
    id = "xmarksthespot",
}, {
    id = "map",
}, {
    id = "sacrifice",
}, {
    id = "3d",
}, {
    id = "rowreveal",
}, {
    id = "life",
}, {
    id = "princess",
},

{ -- ROW 10
    id = "paytoclose",
}, {
    id = "checkbox",
}, {
    id = "police",
}, {
    id = "revival",
}, {
    id = "gamer",
}, {
    id = "daredevil",
}, {
    id = "cloak",
}, {
    id = "wand",
}, {
    id = "hat",
}, {
    id = "crumbling",
}

}



boxesById = {}
for _, type in ipairs(boxes) do
    type.icon = loadImg("box/icon/" .. type.id)
    boxesById[type.id] = type
end