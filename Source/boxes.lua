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
    power = 1,
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
    power = 1,
    onOpen = function(self) pyramid:gainGold(self:power()) end
}, {
    id = "twogold",
    power = 2,
    onOpen = function(self) pyramid:gainGold(self:power()) end
}, {
    id = "telescope",
    power = 1,
    onPress = function(self) pyramid:spendGold(self:power(), function()
        self:log()
        pyramid:revealRandom(1)    
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
}, {
    id = "trigaze",
}, {
    id = "walkie",
},

{ -- ROW 6
    id = "mimic",
}, {
    id = "heartbreak",
}, {
    id = "demo",
}, {
    id = "safe",
}, {
    id = "rowbomb",
}, {
    id = "invert",
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
    id = "safeguard",
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



for _, type in ipairs(boxes) do
    type.icon = loadImg("box/icon/" .. type.id)
end