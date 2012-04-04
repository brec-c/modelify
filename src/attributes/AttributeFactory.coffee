Resolver = require '../Util'

class AttributeFactory

	@resolve: (type) -> 
		console.log "resolving #{type}"
		Resolver.resolve 'attribute', type

	@createAttribute: (attrType, config) -> 
		console.log "creating #{attrType}"
		attr = @resolve(attrType)
		new attr(config)

module.exports = AttributeFactory
