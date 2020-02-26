# Recs Replication Plugin

Recs plugin that allows you to perform replication for adding and removing components, as well as setting properties on a component.

## API

Before you can start using the library, you'll first need to require the ModuleScript from this project.

The ModuleScript will return a function with the following signature:

`Replication(RemoteEvent: remoteEvent) -> ReplicationInstance`

Once you have a ReplicationInstance, you can start to use the following API:

### plugin.client()
`plugin.client() -> plugin`

Creates a client plugin that you feed into Recs.

*Note*: This will throw unless called from the Client.

#### Example
```lua
Recs.Core.new({
	Replication.plugin.client(),
})
```

### plugin.server()
`plugin.server() -> plugin`

Creates a server plugin that you feed into Recs.

*Note*: This will throw unless called from the Server.

#### Example
```lua
Recs.Core.new({
	Replication.plugin.server(),
})
```

### replicate(callback)
`replicate(callback)`

Any calls to a Recs method in this function will replicate to all other players.
The following calls are supported with this method:
- Core:addComponent
	- *The third argument, props, is not yet properly replicated.*
- Core:removeComponent
- Core:addSingleton

*Note*: This should only be used from the Server.

#### Example
```lua
Replication.replicate(function()
	core:addComponent(entity, "Foo")
end)

Replication.replicate(function()
	core:setStateComponent(entity, "Foo", {
		x = 100,
	})
end)

Replication.replicate(function()
	core:removeComponent(entity, "Foo")
end)

Replication.replicate(function()
	core:addSingleton("Bar")
end)
```

### replicatePastChanges
`replicatePastChanges(player)`

Replicates all of the past changes to this Player. This is used for catching up users when they first join.

*Note*: This should only be used from the Server.

#### Example
```lua
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(Replication.replicatePastChanges)
```

All changes are saved, so when the new Player joins they playback all the changes that were made.

This *only* works with entities that both the Server and Client have access to. If you're using instance-based entities, this shouldn't be a problem so long as the instances were created on the server.

However if you have string-based entities, you will need to manually setup the same entity on both sides.

## Full Example
```lua
-- server.lua
local Players = game:GetService("Players")

local RemoteEvent = Instance.new("RemoteEvent")
local Replication = require(game.Path.To.Replication)(RemoteEvent)
local RECS = require(game.Path.To.RECS)

local serverCore = Core.new({
	Replication.plugin.server(),
})

Players.PlayerAdded:Connect(Replication.replicatePastChanges)

serverCore:start()

-- Even if the client has not connected yet,
-- `replicatePastChanges` will propagate this change later
Replication.replicate(function()
	serverCore:addComponent("myEntity", "foo")
end)
```

```lua
-- client.lua
local RemoteEvent = game.Path.To.RemoteEvent
local Replication = require(game.Path.To.Replication)(RemoteEvent)
local RECS = require(game.Path.To.RECS)

local clientCore = Core.new({
	Replication.plugin.client(),
})

clientCore:start()

local myEntityFooComponent = clientCore:getComponent("myEntity", "foo")
print("myEntityFooComponent", myEntityFooComponent)
-- >> myEntityFooComponent table: 0xADDRESS
```

## Contributing

To contribute, please check out the [Contributing guide](CONTRIBUTING.md).
