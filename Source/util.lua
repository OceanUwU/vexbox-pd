function loadImg(path)
    return gfx.image.new("assets/img/" .. path .. ".png")
end

function loadSound(path)
    return sfx.sampleplayer.new("assets/sfx/" .. path .. ".wav")
end

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end