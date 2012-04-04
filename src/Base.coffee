Stateful = require 'stateful'
util = require 'util'

class Base extends Stateful

	@define: (name, methods) -> Object.defineProperty @::, name, methods

	debug: (obj, depth=1) -> util.log util.inspect obj, true, depth, true

	constructor: (@config) ->
		super @config

module.exports = Base