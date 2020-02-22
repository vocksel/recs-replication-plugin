--[[
	Used for replicating Core changes from the server to client.

	First add `createPlugin()` to the server and client cores. From there, use
	the `replicate` function to control when calls to the Core get replicated.

	For example, if you want to replicate the addition of a Foo component, you
	would do the following:

		replicate(function()
			core:addComponent(entity, "Foo")
		end)

	Inside the function passed to `replicate`, changes made to the Core are
	replicated to all clients.

	For clients that join late, you can setup a PlayerAdded connection to catch
	them up:

		Players.PlayerAdded:Connect(function(player)
			replicatePastChanges(player)
		end)

	All changes are saved, so when the new player joins they playback all the
	changes that were made.

	Note that this _only_ works with entities that both the server and client
	have access to. If you're using instance-based entities, this shouldn't be a
	problem so long as the instances were created on the server.

	However if you have string-based entities, you will need to manually setup
	the same entity on both sides.
]]

local RunService = game:GetService("RunService")

local ActionType = {
	Setup = "Setup",
	AddComponent = "AddComponent",
	RemoveComponent = "RemoveComponent",
	AddSingleton = "AddSingleton",
}

local replication = {
	shouldReplicate = false,
	remote = script.remote,

	-- Keeps track of all the actions that were performed so they can be played
	-- back on new clients.
	history = {},
}

local function createAction(actionType, payload)
	return {
		type = actionType,
		payload = payload,
	}
end

function replication.replicate(callback)
	if RunService:IsServer() then
		replication.shouldReplicate = true
		callback()
		replication.shouldReplicate = false
	end
end

-- FIXME: This won't work well, because when we replay _all_ addComponent or
-- removeComponent calls that happened on the server, this will lead to rapid
-- firing of events in the Core, and could lead to really weird behavior in
-- systems if they iterate while components are being setup.
function replication.replicatePastChanges(player)
	local action = createAction(ActionType.Setup, {
		history = replication.history
	})

	replication.remotes:FireClient(player, action)
end

function replication.createPlugin()
	local plugin = {}

	if RunService:IsServer() then
		function plugin:componentAdded(core, entity, component)
			-- TODO: Pass in the props that a component was added with when
			-- replicating.

			if replication.shouldReplicate then
				local action = createAction(ActionType.AddComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				table.insert(replication.history, action)
				replication.remote:FireAllClients(action)
			end
		end

		function plugin:componentRemoving(core, entity, component)
			if replication.shouldReplicate then
				local action = createAction(ActionType.RemoveComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				table.insert(replication.history, action)
				replication.remote:FireAllClients(action)
			end
		end

		function plugin:singletonAdded(core, component)
			if replication.shouldReplicate then
				local action = createAction(ActionType.RemoveComponent, {
					componentIdentifier = component.className
				})

				table.insert(replication.history, action)
				replication.remote:FireAllClients(action)
			end
		end
	else
		function plugin:coreInit(core)
			local function handleCoreAction(action)
				local payload = action.payload

				if action.type == ActionType.AddComponent then
					core:addComponent(payload.entity, payload.componentIdentifier)
				elseif action.type == ActionType.RemoveComponent then
					core:removeComponent(payload.entity, payload.componentIdentifier)
				elseif action.type == ActionType.AddSingleton then
					core:addSingleton(payload.componentIdentifier)
				end
			end

			replication.remote.OnClientEvent:Connect(function(action)
				if action.type == ActionType.Setup then
					for _, action in ipairs(action.payload.history) do
						handleCoreAction(action)
					end
				else
					handleCoreAction(action)
				end
			end)
		end
	end

	return plugin
end

return replication
