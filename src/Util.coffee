{isNodeJS} = require 'detectify'

if isNodeJS then _this = @
else _this = window

module.exports = 

	plugins: {}

	registerPlugin: (type, name, klass) ->
		@plugins[type] = {} unless @plugins[type]?
		@plugins[type][name] = klass
		return klass

	resolve: (type, name) -> 
		return @plugins[type][name] if name
		return _this[type]

	pascalCase: (str) -> return str[0].toUpperCase() + str.substr(1)
