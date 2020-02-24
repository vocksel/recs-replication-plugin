-- luacheck: globals __LEMUR__

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isRobloxCli, ProcessService = pcall(game.GetService, game, "ProcessService")

local TestEZ = require(ReplicatedStorage.TestEZ)

TestEZ.Expectation.extend({
	typedAs = function(value, tFunction)
		local pass, message = tFunction(value)
		if tFunction then
			return {
				pass = pass,
				message = tostring(message),
			}
		else
			return {
				pass = pass,
				message = tostring(message),
			}
		end
	end,
})

local results = TestEZ.TestBootstrap:run({ReplicatedStorage.Source}, TestEZ.Reporters.TextReporterQuiet)

local statusCode = results.failureCount == 0 and 0 or 1

if __LEMUR__ then
	if results.failureCount > 0 then
		os.exit(statusCode)
	end
elseif isRobloxCli then
	ProcessService:Exit(statusCode)
end