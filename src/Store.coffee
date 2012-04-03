Base       = require './Base'
Model      = require './Model'
# ModelQuery = require './ModelQuery'

class Store extends Base

	@define "type", get: -> @config.type

	constructor: (config) ->
		super config

		@models = {}

	register: (model) ->
		# add listeners for:
		# statechanges: dirty, new, 

	get: ->
	find: ->
	create: ->
	delete: ->

module.exports = Store
