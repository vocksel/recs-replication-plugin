local ActionType = require(script.Parent.ActionType)
local replicate = require(script.Parent.replicate)
local createAction = require(script.Parent.createAction)

return function(remoteEvent, history)
	history = history or {}

	return function()
		local plugin = {}

		function plugin:componentAdded(core, entity, component)
			-- TODO: Pass in the props that a component was added with when
			-- replicating.

			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				table.insert(history, action)
				remoteEvent:FireAllClients(action)
			end
		end

		function plugin:componentRemoving(core, entity, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.RemoveComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				table.insert(history, action)
				remoteEvent:FireAllClients(action)
			end
		end

		function plugin:singletonAdded(core, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddSingleton, {
					componentIdentifier = component.className
				})

				table.insert(history, action)
				remoteEvent:FireAllClients(action)
			end
		end

		return plugin
	end
end