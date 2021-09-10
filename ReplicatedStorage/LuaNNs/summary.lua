----------------------------------
-- Summary class -----------------
----------------------------------

local Summary = _G.LuaNNs.Object:subclass {}

function Summary.__tostring(sum)
    local str = "\nSummary:"

    if sum.Title then
        str = string.format("\n%s Summary:", sum.Title)
    end

    if sum.ProcessingTime then
        str = str..string.format("\nProcessing Time: %s", sum.ProcessingTime)
    end
    
    if sum.Loss then
        str = str..string.format("\nLoss: %s", sum.Loss)
    end

    str = str.."\n\n"

    return str
end

function Summary.init(sum)
    return sum
end

return Summary