return function()
	describe("WHEN required", function()
		local replicate = require(script.Parent.replicate)

		it("SHOULD return the following interface", function()
			expect(replicate).to.have.interface(function(t)
				return t.interface({
					shouldReplicate = t.boolean,
					callback = t.callback,
				})
			end)
		end)

		describe("GIVEN a function", function()
			local function customCallback()
				assert(replicate.shouldReplicate, "did not set replicate.shouldReplicate as expected")
			end
			it("SHOULD set shouldReplicate to true while the function is invoked", function()
				replicate.callback(customCallback)
				expect(replicate.shouldReplicate).to.equal(false)
			end)
		end)
	end)
end