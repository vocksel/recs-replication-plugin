return function()
	local function createComponent(className)
		return {
			className = className,
		}
	end

	local ActionType = require(script.Parent.ActionType)
	local replicate = require(script.Parent.replicate)
	local function setShouldReplicate(value)
		replicate.shouldReplicate = value
	end

	describe("WHEN required", function()
		local createServerPlugin = require(script.Parent.createServerPlugin)

		it("SHOULD have the following interface", function()
			expect(createServerPlugin).to.have.interface(function(t)
				return t.callback
			end)
		end)

		describe("GIVEN a remoteEvent", function()
			local history = {}
			local remoteEvent = {
				FireAllClients = function(_, action)
					table.insert(history, action)
				end,
			}
			local function readLatestFireAllClients()
				return history[#history]
			end
			describe("WHEN invoked", function()
				local createServerPluginInstance = createServerPlugin(remoteEvent)

				it("SHOULD have the following interface", function()
					expect(createServerPluginInstance).to.have.interface(function(t)
						return t.callback
					end)
				end)

				describe("WHEN invoked", function()
					local plugin = createServerPluginInstance()

					it("SHOULD return a valid plugin object", function()
						expect(plugin).to.be.ok()
					end)

					it("SHOULD have the following interface", function()
						expect(plugin).to.have.interface(function(t)
							return t.interface({
								componentAdded = t.callback,
								componentRemoving = t.callback,
								singletonAdded = t.callback,
							})
						end)
					end)

					describe("GIVEN shouldReplicate is true", function()
						beforeEach(function()
							setShouldReplicate(true)
						end)
						afterEach(function()
							setShouldReplicate(false)
							history = {}
						end)

						describe("GIVEN an entity and component", function()
							local core = nil
							local entity = "foo"
							local component = createComponent("bar")

							describe("WHEN componentAdded is invoked", function()
								it("SHOULD invoke FireAllClients with the expected action", function()
									plugin:componentAdded(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.be.ok()
									expect(action.type).to.equal(ActionType.AddComponent)
									expect(action.payload).to.be.a("table")
									expect(action.payload.entity).to.equal(entity)
									expect(action.payload.componentIdentifier).to.equal(component.className)
								end)
							end)

							describe("WHEN componentRemoving is invoked", function()
								it("SHOULD invoke FireAllClients with the expected action", function()
									plugin:componentRemoving(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.be.ok()
									expect(action.type).to.equal(ActionType.RemoveComponent)
									expect(action.payload).to.be.a("table")
									expect(action.payload.entity).to.equal(entity)
									expect(action.payload.componentIdentifier).to.equal(component.className)
								end)
							end)

							describe("WHEN singletonAdded is invoked", function()
								it("SHOULD invoke FireAllClients with the expected action", function()
									plugin:singletonAdded(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.be.ok()
									expect(action.type).to.equal(ActionType.AddSingleton)
									expect(action.payload).to.be.a("table")
									expect(action.payload.entity).to.equal(entity)
									expect(action.payload.componentIdentifier).to.equal(component.className)
								end)
							end)
						end)
					end)

					describe("GIVEN shouldReplicate is false", function()
						beforeEach(function()
							setShouldReplicate(false)
						end)
						afterEach(function()
							setShouldReplicate(false)
							history = {}
						end)

						describe("GIVEN an entity and component", function()
							local core = nil
							local entity = "foo"
							local component = createComponent("bar")

							describe("WHEN componentAdded is invoked", function()
								it("SHOULD not invoke FireAllClients", function()
									plugin:componentAdded(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.never.be.ok()
								end)
							end)

							describe("WHEN componentRemoving is invoked", function()
								it("SHOULD not invoke FireAllClients", function()
									plugin:componentRemoving(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.never.be.ok()
								end)
							end)

							describe("WHEN singletonAdded is invoked", function()
								it("SHOULD not invoke FireAllClients", function()
									plugin:singletonAdded(core, entity, component)

									local action = readLatestFireAllClients()
									expect(action).to.never.be.ok()
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end