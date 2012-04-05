Attribute = require './Attribute'
Util      = require '../Util'

class PropertyAttribute extends Attribute

	@declare 'property'
	
	@converters:
		'Number' : (value) -> if not value? then null else new Number value
		'Boolean': (value) -> if not value? then null else !!value
		'String' : (value) -> if not value? then null else value.toString()
		
	get: -> @value
	raw: -> @value
	
	_applyValue: (value) ->
		oldValue = @value
		newValue = value # coercion?
		
		if newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = PropertyAttribute
