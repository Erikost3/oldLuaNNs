----------------------------------
-- Network class -----------------
----------------------------------

-- Add layer to network

local Network = _G.LuaNNs.Object:subclass {}

function Network.addLayer(net, layer)
    if #net.Layers > 0 then
        net.Weights[#net.Weights+1] = _G.LuaNNs.Matrix.randomize(layer.Neurons, net.Layers[#net.Layers].Neurons)
        net.Biases[#net.Biases+1] = _G.LuaNNs.Matrix.randomize(layer.Neurons, 1)
        net.Layers[#net.Layers+1] = layer
    else
        net.Layers[#net.Layers+1] = layer
    end
end

-- Feed data trough network

function Network.feedforward(net, input)

    assert(_G.LuaNNs.Matrix.validate(input))
    -- dont forget to make a net validate function

    local start = os.clock()

    net.Outputs[1] = net.Layers[1].Activation:activate(input)

    for i = 1, #net.Weights do
        
        local layerA, layerB = net.Layers[i], net.Layers[i+1]
		local weights = net.Weights[i]
		local bias = net.Biases[i]

        --print("Processing layer", i)

        --print(weights, net.Outputs[i])

        --for i,v in pairs(net.Weights) do
        --    print(#v, #v[1])
        --end

		net.Outputs[i+1] = weights:dot(net.Outputs[i])
		
		net.Outputs[i+1] =  net.Outputs[i+1] + bias
		net.Outputs[i+1] = layerB.Activation:activate(net.Outputs[i+1])

    end

    net.Summary = _G.LuaNNs.Summary {Title = "Feedforward", ["Processing Time"] = os.clock()-start}

    net.OnFeedforward:Fire(net.Outputs[#net.Outputs], net.Summary)

    return net.Outputs[#net.Outputs] 
end

-- Teach the network something

function Network.backpropagation(net, target)

    assert(_G.LuaNNs.Matrix.validate(target))
    
    -- dont forget to make a net validate function

    assert(#net.Outputs > 0, "No outputs to learn from, did you forget to feedforward before backpropagating?")

    local start = os.clock()

    local diff = target - net.Outputs[#net.Outputs]
    local _error =  diff
	
	---- Gradient descent
	for i = #net.Weights, 1, -1 do

        --print("Adjusting layer:", i)
		
		local layer_error = _error
		
		if i ~= #net.Weights then
			---- Calculate error for each hidden layer
			layer_error = net.Weights[i+1]:transpose():dot(_error)
		end
		
		local next_layer = net.Layers[i+1]
		local layer = net.Layers[i]
		
		---- Calculate the derivative, gradient and delta
		local derivative = net.Layers[i+1].Activation:activate(net.Outputs[i+1], true)
		local gradient = derivative*layer_error
		local delta = gradient:dot(net.Outputs[i]:transpose())
		
		---- Adjust the weights
		net.Weights[i] = (net.Weights[i] + (delta*net.LearningRate))
		net.Biases[i] = net.Biases[i] + (gradient*net.LearningRate)
		
		if i ~= #net.Weights then
			_error = gradient
		end
	end

    --print(target - net.Outputs[#net.Outputs])

    net.Summary = _G.LuaNNs.Summary {Title = "Backpropagation", ProcessingTime = os.clock()-start, Loss = net.LossFunction:compute(diff)}

    net.OnBackpropagation:Fire(net.Summary)

    return net.Outputs[#net.Outputs] 
end

-- Initiate Network

function Network.init(net)

    net.Layers = net.Layers or {}
    net.Weights = net.Weights or {}
    net.Outputs = net.Outputs or {}
    net.Biases = net.Biases or {}
    net.LossFunction = net.LossFunction or _G.LuaNNs.Losses.MeanSquaredError
    net.LearningRate = net.LearningRate or .1
    
    net.OnFeedforward = _G.LuaNNs.Event {}
    net.OnBackpropagation = _G.LuaNNs.Event {}
    
    net.Class = "Network"

    function net:addLayer(layer)
        return Network.addLayer(self, layer)
    end

    function net:addLayers(...)
        for _, v in pairs({...}) do
            self:addLayer(v)
        end
    end

    function net:feedforward(input)
        return Network.feedforward(self, input)
    end

    function net:backpropagate(target)
        return Network.backpropagation(self, target)
    end

    return net
end

return Network