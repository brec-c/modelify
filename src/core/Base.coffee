Stateful = require 'stateful'
util = require 'util'

class Base extends Stateful

	@define: (name, methods) -> Object.defineProperty @::, name, methods
	@mixin:  (type) -> 
		@::[name] = method for name, method of type

	constructor: (@config={}) -> super @config
	debug: (obj, depth=1) -> util.log util.inspect obj, true, depth, true

module.exports = Base
