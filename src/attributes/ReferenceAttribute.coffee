Attribute = require './Attribute'

class ReferenceAttribute extends Attribute

	@declare 'reference'

	constructor: (config) ->
		super config
		
		@store = @type.store
		unless @store?
			throw new Error "Invalid type for reference."
			
	raw: -> @value.id?
	
	_applyValue: (ref) ->
		oldValue = @value
		newValue = @store.resolve ref
		unless oldValue? or newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = ReferenceAttribute
