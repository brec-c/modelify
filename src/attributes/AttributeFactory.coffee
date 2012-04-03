Resolver = require '../Util'

class AttributeFactory

	@resolve: (type) -> Resolver.resolve 'attribute', type
	@createAttribute: (attrType, config) -> new @resolve(attrType)(config)

module.exports = AttributeFactory
