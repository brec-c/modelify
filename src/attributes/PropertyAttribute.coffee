Attribute = require './Attribute'
Util      = require '../Util'

class PropertyAttribute extends Attribute

	@declare 'property'
	
	_applyValue: (value) ->
		oldValue = @value
		newValue = value # coercion?
		
		if newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = PropertyAttribute
