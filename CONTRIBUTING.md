# Contributing

## Working on this project

To get started working on this project, you'll need:
* Git
* Lua 5.1
* Lemur's dependencies:
	* [LuaFileSystem](https://keplerproject.github.io/luafilesystem/) (`luarocks install luafilesystem`)
* [Luacheck](https://github.com/mpeterv/luacheck) (`luarocks install luacheck`)

Make sure you have all of the Git submodules for this project downloaded, which include a couple extra dependencies used for testing.

Finally, you can run all of this project's tests with:

```sh
lua bin/spec.lua
```
