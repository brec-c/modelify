Attribute = require './Attribute'

class Property extends Attribute

	constructor: (config) ->
		super
		@type = window[@config.type]
