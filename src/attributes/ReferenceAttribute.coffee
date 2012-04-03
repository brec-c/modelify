Resolver  = require '../Util'
Attribute = require './Attribute'

class ReferenceAttribute extends Attribute

	@declare 'reference'

	constructor: (config) ->
		super
		@type = Resolver.resolve "model", @config.type

module.exports = ReferenceAttribute
