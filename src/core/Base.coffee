Stateful = require 'stateful'
util = require 'util'

class Base extends Stateful

	@define: (name, methods) -> Object.defineProperty @::, name, methods

	constructor: (@config={}) -> super @config
	debug: (obj, depth=1) -> util.log util.inspect obj, true, depth, true

module.exports = Base