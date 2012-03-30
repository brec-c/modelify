Resolver  = require '../Util'
Attribute = require './Attribute'

class ModelReference extends Attribute
	constructor: (config) ->
		super
		@type = Resolver.resolve "model", @config.type
