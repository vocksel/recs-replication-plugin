local ActionType = require(script.Parent.ActionType)
local createAction = require(script.Parent.createAction)
local history = require(script.Parent.history)

return function(remoteEvent)
	return function(player)
		local action = createAction(ActionType.Setup, {
			history = history
		})

		remoteEvent:FireClient(player, action)
	end
end