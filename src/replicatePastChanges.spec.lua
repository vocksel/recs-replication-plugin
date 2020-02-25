return function()
	local ActionType = require(script.Parent.ActionType)
	local createSpy = require(script.Parent.Parent.Tests.createSpy)

	describe("WHEN required", function()
		local replicatePastChanges = require(script.Parent.replicatePastChanges)

		it("SHOULD have the following interface", function()
			expect(replicatePastChanges).to.have.interface(function(t)
				return t.callback
			end)
		end)

		describe("GIVEN a remoteEvent", function()
			local fireClientSpy = createSpy()
			local remoteEvent = {
				FireClient = fireClientSpy.callback,
			}
			describe("WHEN invoked", function()
				local replicatePastChangesInstance = replicatePastChanges(remoteEvent)

				it("SHOULD have the following interface", function()
					expect(replicatePastChangesInstance).to.have.interface(function(t)
						return t.callback
					end)
				end)

				describe("GIVEN a player", function()
					local player = "player"
					describe("WHEN invoked", function()
						it("SHOULD invoked remoteEvent's FireClient with the expected action", function()
							replicatePastChangesInstance(player)

							expect(fireClientSpy.getNumberOfCalls()).to.equal(1)
							fireClientSpy.expectToBeCalledWith(remoteEvent, "player")
							local lastCall = fireClientSpy.getLastCall()
							local action = lastCall[3]
							expect(action).to.be.ok()
							expect(action.type).to.equal(ActionType.Setup)
						end)
					end)
				end)
			end)
		end)
	end)
end