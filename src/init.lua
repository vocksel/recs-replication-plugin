local createServerPlugin = require(script.createServerPlugin)
local createClientPlugin = require(script.createClientPlugin)
local replicate = require(script.replicate)
local replicatePastChanges = require(script.replicatePastChanges)

return {
	plugin = {
		server = createServerPlugin,
		client = createClientPlugin,
	},

	replicate = replicate,
	replicatePastChanges = replicatePastChanges,
}