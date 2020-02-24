return function()
	local ActionType = require(script.Parent.ActionType)
	local createSpy = require(script.Parent.createSpy)

	local function clearSpies(arrayOfSpies)
		for _, spy in ipairs(arrayOfSpies) do
			spy.clear()
		end
	end

	describe("WHEN required", function()
		local createClientPlugin = require(script.Parent.createClientPlugin)

		it("SHOULD have the following interface", function()
			expect(createClientPlugin).to.have.interface(function(t)
				return t.callback
			end)
		end)

		describe("GIVEN a remoteEvent", function()
			local connectedFunc
			local function fireOnClientEvent(...)
				connectedFunc(...)
			end
			local hasEverConnected = false
			local remoteEvent = {
				OnClientEvent = {
					Connect = function(_, func)
						hasEverConnected = true
						connectedFunc = func
					end,
				},
			}

			describe("WHEN invoked", function()
				local createClientPluginInstance = createClientPlugin(remoteEvent)

				it("SHOULD have the following interface", function()
					expect(createClientPluginInstance).to.have.interface(function(t)
						return t.callback
					end)
				end)

				describe("WHEN invoked", function()
					local plugin = createClientPluginInstance()

					it("SHOULD return a valid plugin object", function()
						expect(plugin).to.be.ok()
					end)

					it("SHOULD have the following interface", function()
						expect(plugin).to.have.interface(function(t)
							return t.interface({
								beforeSystemStart = t.callback,
							})
						end)
					end)

					describe("GIVEN a core", function()
						local addComponentSpy = createSpy()
						local removeComponentSpy = createSpy()
						local addSingletonSpy = createSpy()
						local core = {
							addComponent = addComponentSpy.callback,
							removeComponent = removeComponentSpy.callback,
							addSingleton = addSingletonSpy.callback,
						}

						beforeEach(function()
							clearSpies({
								addComponentSpy,
								removeComponentSpy,
								addSingletonSpy,
							})
						end)

						describe("WHEN beforeSystemStart is invoked", function()
							plugin:beforeSystemStart(core)

							it("SHOULD bind to remoteEvent", function()
								expect(hasEverConnected).to.equal(true)
							end)

							describe("GIVEN an action with type AddComponent", function()
								local action = {
									type = ActionType.AddComponent,
									payload = {
										entity = "entity",
										componentIdentifier = "componentIdentifier",
									},
								}
								describe("WHEN OnClientEvent is fired", function()
									it("SHOULD locally addComponent", function()
										fireOnClientEvent(action)

										expect(addComponentSpy.getNumberOfCalls()).to.equal(1)
										addComponentSpy.expectToBeCalledWith(core, "entity", "componentIdentifier")
									end)
								end)
							end)

							describe("GIVEN an action with type RemoveComponent", function()
								local action = {
									type = ActionType.RemoveComponent,
									payload = {
										entity = "entity",
										componentIdentifier = "componentIdentifier",
									},
								}
								describe("WHEN OnClientEvent is fired", function()
									it("SHOULD locally removeComponent", function()
										fireOnClientEvent(action)

										expect(removeComponentSpy.getNumberOfCalls()).to.equal(1)
										removeComponentSpy.expectToBeCalledWith(core, "entity", "componentIdentifier")
									end)
								end)
							end)

							describe("GIVEN an action with type AddSingleton", function()
								local action = {
									type = ActionType.AddSingleton,
									payload = {
										componentIdentifier = "componentIdentifier",
									},
								}
								describe("WHEN OnClientEvent is fired", function()
									it("SHOULD locally addSingleton", function()
										fireOnClientEvent(action)

										expect(addSingletonSpy.getNumberOfCalls()).to.equal(1)
										addSingletonSpy.expectToBeCalledWith(core, "componentIdentifier")
									end)
								end)
							end)

							describe("GIVEN an action with type Setup", function()
								local addComponentAction = {
									type = ActionType.AddComponent,
									payload = {
										entity = "entity",
										componentIdentifier = "addingComponent",
									},
								}
								local removeComponentAction = {
									type = ActionType.RemoveComponent,
									payload = {
										entity = "entity",
										componentIdentifier = "removingComponent",
									},
								}
								local addSingletonAction = {
									type = ActionType.AddSingleton,
									payload = {
										componentIdentifier = "singletonComponent",
									},
								}

								local action = {
									type = ActionType.Setup,
									payload = {
										history = {
											addComponentAction,
											removeComponentAction,
											addSingletonAction,
											addComponentAction,
										},
									},
								}
								describe("WHEN OnClientEvent is fired", function()
									it("SHOULD locally rebuild from history", function()
										fireOnClientEvent(action)

										expect(addComponentSpy.getNumberOfCalls()).to.equal(2)
										addComponentSpy.expectToBeCalledWith(core, "entity", "addingComponent")

										expect(removeComponentSpy.getNumberOfCalls()).to.equal(1)
										removeComponentSpy.expectToBeCalledWith(core, "entity", "removingComponent")

										expect(addSingletonSpy.getNumberOfCalls()).to.equal(1)
										addSingletonSpy.expectToBeCalledWith(core, "singletonComponent")
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end