Stateful   = require 'stateful'
Model      = require './Model'
ModelQuery = require './ModelQuery'

class Store extends Stateful

	@define "type", get: -> @config.type

	constructor: (config) ->
		super config

		@models = {}


	get: ->
	find: ->
	create: ->
	delete: ->

