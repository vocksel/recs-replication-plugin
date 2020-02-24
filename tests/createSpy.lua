return function()
	local lastCalls = {}
	return {
		callback = function(...)
			table.insert(lastCalls, { ... })
		end,
		getNumberOfCalls = function()
			return #lastCalls
		end,
		expectToBeCalledWith = function(...)
			local lastCall = lastCalls[#lastCalls]
			assert(lastCall, "was never called")

			local expectedParams = { ... }
			for index, expectedValue in ipairs(expectedParams) do
				assert(lastCall[index] == expectedValue, string.format(
					"Expected %s for arg # %s. Got %s instead",
					tostring(expectedValue),
					index,
					tostring(lastCall[index])
				))
			end
		end,
		getLastCall = function()
			return lastCalls[#lastCalls]
		end,
		clear = function()
			lastCalls = {}
		end,
	}
end