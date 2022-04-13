local file = fileOpen("data/objects.json")
local data = fileRead(file, fileGetSize(file))
fileClose(file)
local objects = fromJSON(data)

function getPositionFromElementOffset(m,offX,offY,offZ)
    local x = offX * m["1"][1] + offY * m["2"][1] + offZ * m["3"][1] + m["4"][1]
    local y = offX * m["1"][2] + offY * m["2"][2] + offZ * m["3"][2] + m["4"][2]
    local z = offX * m["1"][3] + offY * m["2"][3] + offZ * m["3"][3] + m["4"][3]
    return x, y, z
end

for d,c in pairs(data2dfx) do
    local e = objects[tostring(d)]
    if not e then e = objects[d] end
    if e then
        for k,v in pairs(e) do
            for e,c in pairs(c) do
                local x, y, z = getPositionFromElementOffset(v, c[5], c[6], c[7])
                createCorona(x, y, z, c[8]*3, {c[1], c[2], c[3]}, c[9])
            end
        end
    end
end

addEventHandler("onClientRender", root, function()
    for k,v in pairs(getElementsByType("vehicle")) do
        local model = getElementModel(v)
        if data2dfx[model] then
            local matrix = getElementMatrix(v)
            for e,c in pairs(data2dfx[model]) do
                local x, y, z = getPositionFromElementOffset2(matrix, c[5], c[6], c[7])
                drawCorona(x, y, z, c[8]*2, {c[1], c[2], c[3]}, 2)--c[9])
            end
        end
    end
end)
