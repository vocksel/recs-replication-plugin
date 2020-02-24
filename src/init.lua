local createServerPlugin = require(script.createServerPlugin)
local createClientPlugin = require(script.createClientPlugin)
local replicate = require(script.replicate)
local replicatePastChanges = require(script.replicatePastChanges)

local remoteEvent = script:FindFirstChildOfClass("RemoteEvent")

return {
	plugin = {
		server = createServerPlugin(remoteEvent),
		client = createClientPlugin(remoteEvent),
	},

	replicate = replicate.callback,
	replicatePastChanges = replicatePastChanges(remoteEvent),
}