Attribute = require './Attribute'

class Reference extends Attribute

	@registerAttribute 'reference'

	constructor: (config) ->
		super config
		
		@store = @type.prototype.store
		unless @store? 
			throw new Error "Invalid type (#{@typeString}) for reference."
			
	raw: -> 
		console.log require('util').inspect @value
		@value.id?
	
	_applyValue: (ref) ->
		oldValue = @value
		newValue = @store.resolve ref
		unless oldValue? or newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = Reference
