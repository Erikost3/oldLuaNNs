----------------------------------
-- Loss functions ----------------
----------------------------------

local Loss = _G.LuaNNs.Object:subclass {}

function Loss.init(loss)
    
    assert(loss.Name, "loss requires name to be provided")
    assert(loss._function and type(loss._function) == "function", "loss requires an activation function")

    function loss:compute(diff)
        return self._function(diff)
    end

    return loss
end

local Losses = {
    MeanSquaredError = Loss {
        Name = "MeanSquaredError",
        _function = function(diff)
            local square = diff:map(function(mx, i, j) return mx[i][j]^2 end)
            local sum = 0
            square:map(function(mx, i, j) sum = sum + mx[i][j] end)
            return sum
        end
        }
}

return Losses