local coronas = {}
local coronaTxt = dxCreateTexture("data/corona.png")
local cameraPosition = Vector3(getCameraMatrix())
local shader = dxCreateShader("data/shader.fx")
dxSetShaderValue(shader, "gCoronaTexture", coronaTxt)

function createCorona(x, y, z, size, color, type)
    table.insert(coronas, {
        pos = Vector3(x, y, z),
		posX = x,
		posY = y,
		posZ = z,
        size = size,
        color = color,
        type = type,
    })
end

-- make function that checks if point lies inside triangle
-- input: triangle vertices, point x, y
-- output: true if point lies inside triangle, false otherwise
function pointInTriangle(x1, y1, x2, y2, x3, y3, x, y)
    local a = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3))
    local b = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3))
    local c = 1 - a - b
    return (a >= 0 and a <= 1) and (b >= 0 and b <= 1) and (c >= 0 and c <= 1)
end

function cameraView()
    local matrix = getElementMatrix(getCamera())
    local x1, y1, z1 = getPositionFromElementOffset(matrix, -1350, 1800, 0)
    local x2, y2, z2 = getPositionFromElementOffset(matrix, 1350, 1800, 0)
    local x3, y3, z3 = matrix[4][1], matrix[4][2], matrix[4][3]
    return {
        {x1, y1, z3},
        {x2, y2, z3},
        {x3, y3, z3},
    }
end

-- make function that checks if corona lies inside camera triangle (cameraView)
-- input: corona position, cameraView
-- output: true if corona lies inside cameraView, false otherwise
function isCoronaInView(pos, view)
    local x, y, z = pos.x, pos.y, pos.z
    local x1, y1, z1 = view[1][1], view[1][2], view[1][3]
    local x2, y2, z2 = view[2][1], view[2][2], view[2][3]
    local x3, y3, z3 = view[3][1], view[3][2], view[3][3]
    return pointInTriangle(x1, y1, x2, y2, x3, y3, x, y)
end

function nightTime()
    local h, m = getTime()
    if h == 5 then
        return 1 - (m / 60)
    elseif h > 5 and h < 21 then
        return 0
    elseif h <= 4 then
        return 1
    elseif h > 21 then
        return 1
    elseif h == 21 then
        return m / 60
    end
end

local getScreenFromWorldPosition = getScreenFromWorldPosition
local dxDrawMaterialLine3D = dxDrawMaterialLine3D
local dxSetShaderValue = dxSetShaderValue
local getDistanceBetweenPoints3D = getDistanceBetweenPoints3D
local alphaType = {[0]=255,255,255,255,255,255}

function drawCorona(x, y, z, size, color, type)
    local night = nightTime()
    local dist = getDistanceBetweenPoints3D(cameraPosition, x, y, z)   
	local distRatio = dist/400
	local alpha = distRatio < 1 and distRatio or 1
    if getScreenFromWorldPosition(x, y, z) and dist < 900 then
		alpha = alpha*alphaType[type]*night
        dxSetShaderValue(shader, "fCoronaPosition", x, y, z)
        dxDrawMaterialLine3D(
			x, y, z-size*2,
			x, y, z+size*2,
			shader, size*4, color+(alpha-alpha%1)*0x1000000,
			x, y+1, z
		)
    end
end

addEventHandler("onClientPreRender", root, function()
	local tick = getTickCount()
    local night = nightTime()
    alphaType[2] = interpolateBetween(0, 0, 0, 255, 0, 0, (tick%1500)/1500, "CosineCurve")*night
    alphaType[3] = interpolateBetween(0, 0, 0, 255, 0, 0, (tick%3500)/3500, "CosineCurve")*night
    alphaType[4] = alphaType[3]
    alphaType[6] = alphaType[3]
    local cx,cy,cz = getCameraMatrix()
    local view = cameraView()
    for i=1,#coronas do
		local v = coronas[i]
		local x,y,z = v.posX,v.posY,v.posZ
        local dist = ((x-cx)^2+(y-cy)^2+(z-cz)^2)^0.5
        if dist < 900 then
			local pos = v.pos
			if getScreenFromWorldPosition(pos) then
				local distRatio = dist/400
				local alpha = distRatio < 1 and distRatio or 1
				local size = v.size*alpha
				alpha = alpha*alphaType[v.type]*night
				dxSetShaderValue(shader,"fCoronaPosition",pos)
				dxDrawMaterialLine3D(
					x, y, z-size,
					x, y, z+size,
					shader, size*2, v.color+(alpha-alpha%1)*0x1000000,
					x, y+1, z
				)
			end
        end
    end
end)
