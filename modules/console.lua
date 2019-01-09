local console = {
	input = "",
	cursor = 1,
	
	maxSize = 16,
	
	log = {"-- Console Log --"}
}

_true_print = print
print = function(...)
	_true_print(...)
	console:appendLine(...)
end

function console:appendLine(...)
	-- TODO
end

return console