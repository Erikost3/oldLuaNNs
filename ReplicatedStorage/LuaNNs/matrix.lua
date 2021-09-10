----------------------------------
-- Matrix class ------------------
----------------------------------

local Matrix = _G.LuaNNs.Object:subclass {}

-- Validate matrix

function Matrix.validate(...)

    local arrays = {...}

    for i, v in ipairs(arrays) do
        if not v:is_class(Matrix) then return false, "Array is not a matrix" end

        local equal = true

        for i2 = 1, #v do
            equal = equal and #v[i2] == #v[1]
            if not equal then return equal, string.format("[%s]: ", i).."Matrix is not valid because rows have different column size" end
        end
    end

    return true
end

-- Retrieves shape from a matrix

function Matrix.shapes(a)
    
    R = function(a, r)
        if type(a) == "table" then
            r[#r+1] = #a
            if #a > 0 then
                return R(a[1], r)
            end
        end
        return r
    end

    return R(a, {})
end

-- Maps function to every element of matrix

function Matrix.map(a, f)

    assert(Matrix.validate(a))

    local map = Matrix {}
	
	for i = 1, #a do
        map[i] = {}
		for j = 1, #a[1] do
            map[i][j] = f(a, i, j)
        end
	end
    
    return map
end

-- Combine two matrices in different ways

function Matrix.combine(a, b, axis)

    assert(Matrix.validate(a, b))

    if not axis then
        axis = 1
    end

    local combo = a:copy()

    if axis == 1 then

        assert(#a[1] == #b[1], "can't combine rows of matrices if number of columns is not the same")

        for i = 1, #b do
			combo[#a+1] = b[i]
		end

    elseif axis == -1 then

        assert(#a[1] == #b[1], "can't combine columns of matrices if number of rows is not the same")

        for i = 1, #a do
			for j = 1, #b[1] do
				combo[i][#a[i] + 1] = b[j]
			end
		end
    end

    return combo
end

-- Calculate the total sum of elements in a matrix

function Matrix.sum(a, f)

    assert(Matrix.validate(a))

    f = f or function(i, j, v)
        return v
    end

    local sum = 0

    for i = 1, #a do
        for j = 1, #a[1] do
            sum = sum + f(i, j, a[i][j])
        end
    end

    return sum
end

-- Normalize values in matrix

function Matrix.normalize(a, min, max, scale)

    assert(Matrix.validate(a))
    
    min, max, scale = min or 0, max or 1, scale or 1

    local norm = a:copy()

    for i = 1, #a do
        norm[i] = {}
        for j = 1, #a[1] do
            local k = scale*((a[i][j]-min)/(max-min))
            norm[i][j] = k
        end
    end

    return norm
end


-- Calculate dot product between a and b

function Matrix.dot(a, b)

    assert(Matrix.validate(a, b))

    assert(#a[1] == #b, "columns of a"..string.format("(%s,%s)", #a, #a[1]).." must equal the rows of b"..string.format("(%s,%s)", #b, #b[1]))

    local product = Matrix {}

    for i = 1, #a do
		product[i] = {}
		for j = 1, #b[1] do
			product[i][j] = 0
			for k = 1, #a[1] do
				product[i][j] = product[i][j]+(a[i][k] * b[k][j])
			end
		end
	end

    return product
end

-- Calculate scalar product

function Matrix.scalar(a, b)

    assert(type(a) == "number" or type(b) == "number", "no number to calculate scalar with")

    if type(b) == "number" then b, a = a, b end

    assert(Matrix.validate(b))

    local scalar = Matrix {}
	
	for i = 1, #b do
		scalar[i] = {}
		for j = 1, #b[1] do
			scalar[i][j] = a*b[i][j]
		end
	end
    
    return scalar
end

-- Multiply each element of Matrix with same element of other

function Matrix.multiply(a, b)
    
    assert(Matrix.validate(a, b))
    assert(#a == #b and #a[1] == #b[1], "the dimensions of a"..string.format("(%s,%s)", #a, #a[1]).." has to be equal to b"..string.format("(%s,%s)", #b, #b[1]))

    local result = Matrix {}

    for i = 1, #b do
		result[i] = {}
		for j = 1, #b[1] do
			result[i][j] = a[i][j]*b[i][j]
		end
	end

    return result
end

-- Calculate sum of matrices

function Matrix.add(a, b)

    if type(a) == "number" then b, a = a, b end

    if type(b) == "number" then
        assert(Matrix.validate(a))
    else
        assert(Matrix.validate(a, b))
        assert(#a == #b and #a[1] == #b[1], "the dimensions of a"..string.format("(%s,%s)", #a, #a[1]).." has to be equal to b"..string.format("(%s,%s)", #b, #b[1]))
    end

    local sum = Matrix {}

    for i = 1, #a do
		sum[i] = {}
		for j = 1, #a[1] do
			if type(a) == "number" then
                sum[i][j] = a[i][j]+b
            else
                sum[i][j] = a[i][j]+b[i][j]
            end
		end
	end

    return sum
end

-- Transpose matrix

function Matrix.transpose(a)

    assert(Matrix.validate(a))

    local transpose = Matrix {}
        
	for j = 1, #a[1] do
		transpose[j] = {}
		for i = 1, #a do
			transpose[j][i] = a[i][j]
		end
	end

    return transpose
end

-- Calculate unary of matrix

function Matrix.unary(a)
    return Matrix.scalar(-1, a)
end


-- __mul methamethod

function Matrix.__mul(a, b)
    if type(a) == "table" and type(b) == "table" and Matrix.validate(a, b) then
        return Matrix.multiply(a, b)
    else
        return Matrix.scalar(a, b)
    end
end

-- __add methamethod

function Matrix.__add(a, b)
    return Matrix.add(a, b)
end

-- __sub methamethod

function Matrix.__sub(a, b)
    return Matrix.add(a, -b)
end

-- __unm metamethod

function Matrix.__unm(a)
    return Matrix.unary(a)
end

-- __eq metamethod

function Matrix.__eq(a, b)
    
    assert(Matrix.validate(a, b))

    if #a ~= #b or #a[1] ~= #b[1] or type(a) ~= "table" or type(b) ~= "table" then return false end
    
    local same = true
    for i = 1, #a do
        for j = 1, #a[1] do
            same = same and a[i][j] == b[i][j]
            if not same then return same end
        end
    end

    return true
end


-- Initiate Matrix

function Matrix.init(mx)

    function mx:dot(b)
        return Matrix.dot(self, b)
    end

    function mx:scalar(b)
        return Matrix.scalar(self, b)
    end

    function mx:add(b)
        return Matrix.add(self, b)
    end

    function mx:unary()
        return Matrix.unary(self)
    end

    function mx:transpose()
        return Matrix.transpose(self)
    end

    function mx:map(f)
        return Matrix.map(self, f)
    end

    function mx:combine(b, axis)
        return Matrix.combine(self, b, axis)
    end

    function mx:copy()
        return Matrix.copy(self)
    end

    function mx:normalize(min, max, scale)
        return Matrix.normalize(self, min, max, scale)
    end

    function mx:sum(f)
        return Matrix.sum(self, f)
    end

    mx.class = "Matrix"

end

-- Create new matrix

function Matrix.new(...)
    return Matrix(...)
end

-- Create new matrix from array

function Matrix.fromArray(array)
    local mx = Matrix {}

    for i = 1, #array do
        mx[i] = {array[i]}
    end

    return mx
end

-- Randomize new matrix

function Matrix.randomize(x, y, min, max)
    
    local mx = Matrix {}

    local f = function()
        return math.random()
    end

    if min and max then
        f = function()
            return math.random(min, max)
        end
    end

    for i = 1, x do
        mx[i] = {}
        for j = 1, y do
            mx[i][j] = f()
        end
    end

    return mx
end

-- Make a copy of matrix

function Matrix.copy(a)

    assert(Matrix.validate(a))

    local copy = Matrix {}

    for i = 1, #a do
        copy[i] = {}
        for j = 1, #a[1] do
            copy[i][j] = a[i][j]
        end
    end

    return copy
end

-- Check sanity on Matrix class

function Matrix.sanity()

    local mx1, mx2 = Matrix {{1, 2, 3},{4, 5, 6}}, Matrix {{7, 8},{9, 10}, {11, 12}}

    assert(mx1 == mx1, "SANITY CHECK, there is something wrong with the __eq function")
    
    assert(mx1:dot(mx2) == Matrix {{58, 64}, {139, 154}}, "SANITY CHECK, there is something wrong with the dot function")
    
    assert(mx1*2 == Matrix {{2, 4, 6}, {8, 10, 12}}, "SANITY CHECK, there is something wrong with the scalar function")
    assert(mx1*mx1 == Matrix {{1, 4, 9}, {16, 25, 36}}, "SANITY CHECK, there is something wrong with the multiply function")
    
    assert(mx2+mx2 == Matrix {{14, 16}, {18, 20}, {22, 24}}, "SANITY CHECK, there is something wrong with the add function")
    assert(-mx1 == Matrix {{-1, -2, -3},{-4, -5, -6}}, "SANITY CHECK, there is something wrong with the unary function")
    assert(mx1:transpose() == Matrix {{1, 4}, {2, 5}, {3, 6}}, "SANITY CHECK, there is something wrong with the transpose function")
    assert(mx1:sum() == 21)
    assert(Matrix{{2}, {2}, {2}}:normalize(0, 4) == Matrix{{.5}, {.5}, {.5}}, "SANITY CHECK, there is something wrong with the normalize function")
    
    assert(mx1*.1 == mx1:map(function(mx, i, j)
        return mx[i][j]*.1
    end), "SANITY CHECK, there is something wrong with the map function")

end

return Matrix