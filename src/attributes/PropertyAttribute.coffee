Attribute = require './Attribute'
Util      = require '../Util'

class PropertyAttribute extends Attribute

	@declare 'property'

	constructor: (config) ->
		super
		@type = Util.resolve[@config.type]

module.exports = PropertyAttribute
