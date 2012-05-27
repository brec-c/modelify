Attribute = require './Attribute'

util = require('util')

class Reference extends Attribute

	@registerAttribute 'reference'

	constructor: (config) ->
		super config
		
		@store = @type.prototype.store
		unless @store? 
			throw new Error "Invalid type (#{@typeString}) for reference."
			
	raw: -> "ModelType: #{@value.constructor.name}, id: #{@value.id}"
	
	_applyValue: (ref) ->
		oldValue = @value

		newValue = @store.resolve ref

		unless newValue is oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = Reference
