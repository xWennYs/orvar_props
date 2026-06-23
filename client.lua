-- Client-only static prop placer.
-- Props are registered on load (from Config.Props, or via the client export
-- from other resources during their startup). Each prop becomes an ox_lib
-- point: ox_lib runs ONE grid thread, fires onEnter (spawn) / onExit (despawn).
-- World object count stays low = best performance. No server, no sync needed —
-- every client builds the same set on its own start, so late joiners get them.

local points  = {}    -- [id] = CPoint (ox_lib point)
local spawned = {}    -- [id] = entity handle
local nextId  = 0     -- client-local id counter

-- Spawn / despawn -----------------------------------------------------------

local function spawn(data)
    if spawned[data.id] then return end
    if not lib.requestModel(data.model, 10000) then return end

    local obj = CreateObject(data.model, data.x, data.y, data.z, false, false, false)
    SetEntityHeading(obj, data.heading)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)   -- static; frozen + held handle = engine won't cull it
    SetModelAsNoLongerNeeded(data.model)

    spawned[data.id] = obj
end

local function despawn(id)
    local obj = spawned[id]
    if obj and DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    spawned[id] = nil
end

-- Core ----------------------------------------------------------------------

local function placeProp(model, coords, heading)
    if not coords or not coords.x then
        lib.print.error('PlaceProp: invalid coords')
        return nil
    end
    if type(model) == 'string' then model = joaat(model) end

    nextId = nextId + 1
    local id = nextId
    local data = {
        id = id,
        model = model,
        x = coords.x + 0.0,
        y = coords.y + 0.0,
        z = coords.z + 0.0,
        heading = (heading or 0.0) + 0.0,
    }

    points[id] = lib.points.new({
        coords = vec3(data.x, data.y, data.z),
        distance = Config.StreamRadius,
        onEnter = function() spawn(data) end,
        onExit  = function() despawn(id) end,
    })

    return id
end

local function removeProp(id)
    despawn(id)
    if points[id] then
        points[id]:remove()
        points[id] = nil
    end
    return true
end

local function clearProps()
    for id in pairs(points) do removeProp(id) end
end

-- Client exports ------------------------------------------------------------
-- Call from any other CLIENT resource (e.g. ox_inventory item use) on load:
--   local id = exports.orvar_props:PlaceProp('prop_barrel_01a', coords, heading)
--   exports.orvar_props:RemoveProp(id)
--   exports.orvar_props:ClearProps()
-- `coords` can be a vector3 or a table with .x/.y/.z fields.

exports('PlaceProp', placeProp)
exports('RemoveProp', removeProp)
exports('ClearProps', clearProps)

-- Load static props from config on start ------------------------------------

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, p in ipairs(Config.Props) do
        placeProp(p.model, p.coords, p.heading)
    end
end)

-- Clean up on stop so we don't leave orphan objects.
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    clearProps()
end)
