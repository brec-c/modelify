module.exports = 

	plugins: {}

	registerPlugin: (type, name, klass) ->
		@plugins[type] = {} unless @plugins[type]?
		@plugins[type][name] = klass
		return klass

	resolve: (type, name) -> @plugins[type][name]

	pascalCase: (str) -> return str[0].toUpperCase() + str.substr(1)
