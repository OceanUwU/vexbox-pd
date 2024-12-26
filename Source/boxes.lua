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
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
},

{ -- ROW 6
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
},

{ -- ROW 7
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
},

{ -- ROW 8
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
},

{ -- ROW 9
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
},

{ -- ROW 10
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}, {
    id = "",
}

}



for _, type in ipairs(boxes) do
    type.icon = loadImg("box/icon/" .. type.id)
end