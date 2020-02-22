# Recs Replication Plugin

Recs plugin that allows you to perform replication for adding and removing components, as well as setting properties on a component.

## API

**createPlugin()**

Creates the plugin that you feed into Recs.

```lua
Recs.Core.new({
	createPlugin(),
})
```

**replicate(callback)**

Any calls to a Recs method in this function will replicate to all other players.

This can only be used on the server.

```lua
replicate(function()
    self.core:addComponent(entity, "Foo")
end)

replicate(function()
    self.core:removeComponent(entity, "Foo")
end)

replicate(function()
    self.core:setComponentProps(color, {
        value = buttonEntity.Color
    })
end)
```

**replicatePastChanges(player)**

Replicates all of the past changes to this player. This is used for catching up users when they first join.
