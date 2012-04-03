Attribute = require './Attribute'

class PropertyAttribute extends Attribute

	@declare 'property'

	constructor: (config) ->
		super
		@type = window[@config.type]

module.exports = PropertyAttribute
