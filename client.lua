local file = fileOpen("data/objects.lua")
local data = fileRead(file, fileGetSize(file))
fileClose(file)

function getPositionFromElementOffset(m,offX,offY,offZ)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

local startTick = getTickCount()
local objects = loadstring(data)()
local startTick = getTickCount()
for d,c in pairs(data2dfx) do
    local e = objects[d]
    if e then
        for k,v in pairs(e) do
			for i=1,#c do
				local corona = c[i]
                local x, y, z = getPositionFromElementOffset(v, corona[5], corona[6], corona[7])
                createCorona(x, y, z, corona[8]*3, {corona[1], corona[2], corona[3]}, corona[9])
            end
        end
    end
end
--[[
addEventHandler("onClientPreRender", root, function()
	local vehicles = getElementsByType("vehicle")
	for i=1,#vehicles do
		local v = vehicles[i]
		local model = getElementModel(v)
        if data2dfx[model] then
            local matrix = getElementMatrix(v)
			for i=1,#data2dfx[model] do
				local corona = data2dfx[model][i]
                local x, y, z = getPositionFromElementOffset(matrix, corona[5], corona[6], corona[7])
                drawCorona(x, y, z, corona[8]*2, {corona[1],corona[2],corona[3]}, 2)--c[9])
            end
        end
	end
end)]]
