----------------------------------
-- Layer class -------------------
----------------------------------

local Activations = _G.LuaNNs.Activations

local Layer = _G.LuaNNs.Object:subclass {}

-- Initiate Layer

function Layer.init(layer)

    layer.Neurons = layer.Neurons or 1
    layer.Activation = layer.Activation or Activations.Sigmoid
    layer.Name = layer.Name or "Layer"
    layer.Class = "Layer"

    return Layer
end

return Layer