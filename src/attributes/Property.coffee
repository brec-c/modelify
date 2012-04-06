Attribute    = require './Attribute'
TypeRegister = require '../TypeRegister'

class Property extends Attribute

	@registerAttribute 'property'
	
	# constructor: (config) ->
	# 	super config
	# 	
	# 	@debug @config
	
	_applyValue: (value) ->
		oldValue = @value
		
		# console.log "typeString is #{@typeString}"
		# console.log "type is #{@type}"
		
		newValue = TypeRegister.assertIsType value, @type
		
		if newValue isnt oldValue
			@previous = oldValue
			@value    = newValue
			return true
		return false

module.exports = Property
