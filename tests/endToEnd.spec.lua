return function()
	local createSpy = require(script.Parent.createSpy)
	local Signal = require(script.Parent.Signal)

	local Core = {
		new = function(plugins)
			local function fireIfPlugin(pluginEvent, ...)
				for _, plugin in ipairs(plugins) do
					if plugin[pluginEvent] then
						plugin[pluginEvent](plugin, ...)
					end
				end
			end

			local addComponentSpy = createSpy()
			local addSingletonSpy = createSpy()

			return {
				addComponent = function(...)
					fireIfPlugin("componentAdded", ...)
					addComponentSpy.callback(...)
				end,
				addSingleton = function(...)
					fireIfPlugin("singletonAdded", ...)
					addSingletonSpy.callback(...)
				end,
				start = function(self)
					fireIfPlugin("beforeSystemStart", self)
				end,

				spy = {
					addComponent = addComponentSpy,
					addSingleton = addSingletonSpy,
				}
			}
		end,
	}

	local componentBar = {
		className = "componentBar",
	}

	local singletonComponent = {
		className = "singletonComponent",
	}

	local spyFireAllClients = createSpy()
	local onClientEventSignal = Signal.new()
	local remoteEvent = {
		OnClientEvent = onClientEventSignal,
		FireAllClients = function(_, ...)
			spyFireAllClients.callback(...)
			onClientEventSignal:fire(...)
		end,
		FireClient = function(_, player, ...)
			onClientEventSignal:fire(...)
		end,
	}

	it("SHOULD work according to spec", function()
		local Replication = require(script.Parent.Parent.Source)(remoteEvent)

		-- create the server core
		local serverCore
		do
			serverCore = Core.new({
				Replication.plugin.server(),
			})

			serverCore:start()
		end

		Replication.replicate(function()
			serverCore:addComponent("entityFoo", componentBar)
		end)

		-- * Test: Should handle replication when client connects late
		-- Should have been sent to all clients
		expect(spyFireAllClients.getNumberOfCalls()).to.equal(1)

		-- create a new incoming client
		local clientCore
		do
			clientCore = Core.new({
				Replication.plugin.client(),
			})

			clientCore:start()
		end
		Replication.replicatePastChanges("player")
		-- Should have called addComponent due to replicatePastChanges
		expect(clientCore.spy.addComponent.getNumberOfCalls()).to.equal(1)
		clientCore.spy.addComponent.expectToBeCalledWith(clientCore, "entityFoo", "componentBar")

		-- * Test: Should handle replication when client is connected
		Replication.replicate(function()
			serverCore:addSingleton(singletonComponent)
		end)
		expect(clientCore.spy.addSingleton.getNumberOfCalls()).to.equal(1)
		clientCore.spy.addSingleton.expectToBeCalledWith(clientCore, "singletonComponent")
	end)
end