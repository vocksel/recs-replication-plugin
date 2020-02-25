local replicate = {
	shouldReplicate = false,
}

function replicate.callback(func)
	replicate.shouldReplicate = true
	func()
	replicate.shouldReplicate = false
end

return replicate