local createServerPlugin = require(script.createServerPlugin)
local createClientPlugin = require(script.createClientPlugin)
local replicate = require(script.replicate)
local replicatePastChanges = require(script.replicatePastChanges)
local history = require(script.history)

return function(remoteEvent)
	local historyInstance = history.new()

	return {
		plugin = {
			server = createServerPlugin(remoteEvent, historyInstance),
			client = createClientPlugin(remoteEvent),
		},

		replicate = replicate.callback,
		replicatePastChanges = replicatePastChanges(remoteEvent, historyInstance),
	}
end