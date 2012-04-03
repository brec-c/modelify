Stateful = require 'stateful'

class Base extends Stateful

	@define: (name, methods) -> Object.defineProperty @::, name, methods

	constructor: (@config) ->

module.exports = Base