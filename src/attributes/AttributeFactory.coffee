TypeRegister = require '../TypeRegister'

class AttributeFactory

	@createAttribute: (attrType, config) -> 
		attr = TypeRegister.getAttribute attrType
		new attr(config)

module.exports = AttributeFactory
