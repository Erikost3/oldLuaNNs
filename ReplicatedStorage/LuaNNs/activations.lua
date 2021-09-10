----------------------------------
-- Activation functions ----------
----------------------------------

local Activation = _G.LuaNNs.Object:subclass {}

function Activation.init(act)

    assert(act.Name, "activation requires name to be provided")
    assert(act.activation and type(act.activation) == "function", "activation requires an activation function")
    assert(act.derv and type(act.derv) == "function", "activation requires a derivative function")

    act.class = "Activation"

    function act:activate(mx, derv)
        if not derv then
            return self.activation(mx)
        else
            return self.derv(mx)
        end
    end

    return act
end

local Activations = {
    Sigmoid = Activation {
        Name = "Sigmoid", 
        activation = function(mx)
            return mx:map(function(x, i, j)
                return 1/(1+math.exp(-x[i][j]))
            end)
        end,
        derv = function(mx)
            return mx:map(function(x, i, j)
                return x[i][j]*(1-x[i][j])
            end)
        end
    },
    Tanh = Activation {
        Name = "Tanh", 
        activation = function(mx)
            return mx:map(function(x, i, j)
                return (1 - math.exp(-x[i][j]*2)) / (1 + math.exp(-x[i][j]*2))
            end)
        end,
        derv = function(mx)
            return mx:map(function(x, i, j)
                return 1-(x[i][j]^2)
            end)
        end
    },
    ReLU = Activation {
        Name = "ReLU", 
        activation = function(mx)
            return mx:map(function(x, i, j)
                if x[i][j] < 0 then
                    return 0
                else
                    return x[i][j]
                end
            end)
        end,
        derv = function(mx)
            return mx:map(function(x, i, j)
                if x[i][j] > 0 then
                    return 1
                else
                    return 0
                end
            end)
        end
    },
    LeakyReLU = Activation {
        Name = "LeakyReLU", 
        activation = function(mx)
            return mx:map(function(x, i, j)
                if x[i][j] < 0 then
                    return x[i][j]*.1
                else
                    return x[i][j]
                end
            end)
        end,
        derv = function(mx)
            return mx:map(function(x, i, j)
                if x[i][j] > 0 then
                    return .1
                else
                    return 1
                end
            end)
        end
    },
    Softmax = Activation {
        Name = "Softmax", 
        activation = function(mx)
            local sum = 0
            mx:map(function(y, k, l)
                sum = sum + math.exp(y[k][l])
            end)
            return mx:map(function(x, i, j)
                return math.exp(x[i][j])/sum
            end)
        end,
        derv = function(mx)
            return mx:map(function(x, i, j)
                return x[i][j]*(1-x[i][j])
            end)
        end
    },
}

return Activations