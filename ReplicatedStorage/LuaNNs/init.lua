_G.LuaNNs = {}

_G.LuaNNs.Object = require(script.object)
_G.LuaNNs.Matrix = require(script.matrix)
_G.LuaNNs.Activations = require(script.activations)
_G.LuaNNs.Layer = require(script.layer)
_G.LuaNNs.Losses = require(script.losses)
_G.LuaNNs.Event = require(script.event)
_G.LuaNNs.Network = require(script.network)
_G.LuaNNs.Summary = require(script.summary)

----------------------------------
-- Module Definitions ------------
----------------------------------

local LuaNNs = {}

LuaNNs.Matrix = _G.LuaNNs.Matrix
LuaNNs.Activations = _G.LuaNNs.Activations
LuaNNs.Layer = _G.LuaNNs.Layer
LuaNNs.Losses = _G.LuaNNs.Losses
LuaNNs.Network = _G.LuaNNs.Network

----------------------------------
-- Sanity checks -----------------
----------------------------------

LuaNNs.Matrix.sanity()
--LuaNNs.Network.sanity()


return LuaNNs
