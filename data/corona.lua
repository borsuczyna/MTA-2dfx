local coronas = {}
local coronaTxt = dxCreateTexture("data/corona.png")
local cameraPosition = Vector3(getCameraMatrix())
local shader = dxCreateShader("data/shader.fx")
dxSetShaderValue(shader, "gCoronaTexture", coronaTxt)

function createCorona(x, y, z, size, color, type)
    table.insert(coronas, {
        pos = Vector3(x, y, z),
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

function getPositionFromElementOffset2(m,offX,offY,offZ)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

function cameraView()
    local matrix = getElementMatrix(getCamera())
    local x1, y1, z1 = getPositionFromElementOffset2(matrix, -1350, 1800, 0)
    local x2, y2, z2 = getPositionFromElementOffset2(matrix, 1350, 1800, 0)
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

function drawCorona(x, y, z, size, color, type)
    local night = nightTime()
    local dist = getDistanceBetweenPoints3D(cameraPosition, x, y, z)   
    local alpha = 1
    if dist < 180 then
        alpha = math.max((dist-90)/90, 0.2)
    end

    local type2alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()%1500)/1500, "CosineCurve")
    local type3alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()%3500)/3500, "CosineCurve")
    
    if getScreenFromWorldPosition(x, y, z) and dist < 900 then
        if type == 0 then
        elseif type == 2 then
            alpha = alpha*type2alpha
        elseif type == 3 then
            alpha = alpha*type3alpha
        else
            alpha = alpha*type3alpha
        end

        dxSetShaderValue(shader, "fCoronaPosition", x, y, z)
        dxDrawMaterialLine3D(x, y, z - size * 2,
        x, y, z + size * 2,
        shader, size * 4, tocolor(color[1], color[2], color[3], alpha * 255 * night),
        x,1 + y,z)
    end
end

addEventHandler("onClientPreRender", root, function()
    cameraPosition = Vector3(getCameraMatrix())

    local view = cameraView()
    local night = nightTime()
    --[[dxDrawLine3D(view[1][1], view[1][2], view[1][3], view[2][1], view[2][2], view[2][3], tocolor(255, 0, 0, 255), 2, true)
    dxDrawLine3D(view[2][1], view[2][2], view[2][3], view[3][1], view[3][2], view[3][3], tocolor(255, 0, 0, 255), 2, true)
    dxDrawLine3D(view[3][1], view[3][2], view[3][3], view[1][1], view[1][2], view[1][3], tocolor(255, 0, 0, 255), 2, true)]]

    local type2alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()%1500)/1500, "CosineCurve")
    local type3alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()%3500)/3500, "CosineCurve")

    for k,v in pairs(coronas) do
        local pos = v.pos
        local size = v.size/2
        local color = v.color

        local dist = getDistanceBetweenPoints3D(pos, cameraPosition)
        local alpha = 1
        if dist < 180 then
            alpha = math.max((dist-90)/90, 0.2)
        end
        size = size * alpha

        if v.type == 0 then
        elseif v.type == 2 then
            alpha = alpha*type2alpha
        elseif v.type == 3 then
            alpha = alpha*type3alpha
        else
            alpha = alpha*type3alpha
        end

        if dist < 900 and getScreenFromWorldPosition(pos.x, pos.y, pos.z) then
            dxSetShaderValue(shader, "fCoronaPosition", pos.x, pos.y, pos.z)

            dxDrawMaterialLine3D(pos.x, pos.y, pos.z - size * 2,
            pos.x, pos.y, pos.z + size * 2,
            shader, size * 4, tocolor(color[1], color[2], color[3], alpha * 255 * night),
            pos.x,1 + pos.y,pos.z)
        end
    end
end)
