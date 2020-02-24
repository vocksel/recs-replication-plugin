return function()
	describe("WHEN required", function()
		local api = require(script.Parent)

		it("SHOULD have the following interface", function()
			expect(api).to.have.interface(function(t)
				return t.interface({
					plugin = t.interface({
						server = t.callback,
						client = t.callback,
					}),

					replicate = t.callback,
					replicatePastChanges = t.callback,
				})
			end)
		end)
	end)
end