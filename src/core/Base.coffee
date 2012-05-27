Stateful = require 'stateful'

class Base extends Stateful

	@mixin:  (type) -> 
		@::[name] = method for name, method of type

	constructor: (@config={}) -> super @config

module.exports = Base
