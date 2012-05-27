Attribute    = require './Attribute'
TypeRegister = require '../TypeRegister'

class Property extends Attribute

	@registerAttribute 'property'
		
	_applyValue: (value) ->
		oldValue = @value
			
		newValue = TypeRegister.assertIsType value, @type
		
		if newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = Property
