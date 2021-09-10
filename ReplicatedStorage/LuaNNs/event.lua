----------------------------------
-- Event class -------------------
----------------------------------

local Event = _G.LuaNNs.Object:subclass {}

-- Add connection to Event

function Event.Connect(ev, f)
    assert(type(f) == "function", string.format("Tried to connect %s to event", type(f)))
    table.insert(ev.Connections, f)
    return {Disconnect = function() table.remove(table.remove(table.find(ev.Connections, f))) end}
end

-- Fire connections

function Event.Fire(ev, ...) 
    for i = 1, #ev.Connections do
        local c = ev.Connections[i]

        if type(c) == "function" then
            c(...)
        end
    end
end

-- Initiate the Event class

function Event.init(ev)

    ev.Connections = {}

    function ev:Connect(f)
        return Event.Connect(self, f)
    end

    function ev:Fire(...)
        return Event.Fire(self, ...)
    end

    return ev
end

return Event