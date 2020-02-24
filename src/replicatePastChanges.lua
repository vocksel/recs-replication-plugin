local ActionType = require(script.Parent.ActionType)
local createAction = require(script.Parent.createAction)

return function(remoteEvent, history)
	history = history or {}

	return function(player)
		local action = createAction(ActionType.Setup, {
			history = history,
		})

		remoteEvent:FireClient(player, action)
	end
end