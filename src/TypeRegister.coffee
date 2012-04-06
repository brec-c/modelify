{isNodeJS} = require 'detectify'

_resolve = (typeString) ->

	if isNodeJS then _this = @
	else _this = window

	# console.log "resolving type: #{typeString}"
	# console.log require('util').inspect _this
	
	_this[typeString]


module.exports = 

	plugins: {}

	registerPlugin: (type, name, klass) ->
		@plugins[type] = {} unless @plugins[type]?
		@plugins[type][name] = klass
		
		return klass

	getPlugin: (type, name) -> @plugins[type][name]


	addModel    : (name, klass) -> @registerPlugin 'model', name, klass
	addAttribute: (name, klass) -> @registerPlugin 'attribute', name, klass

	getModel    : (name) -> @getPlugin 'model', name
	getAttribute: (name) -> @getPlugin 'attribute', name
	
	isModel     : (name) -> @plugins['model']?[name]?
	
	resolve     : (type) -> _resolve type

	assertIsType: (value, type) -> type(value) or value
