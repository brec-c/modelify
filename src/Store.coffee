Base       = require './Base'
# Model      = require './Model'

class Store extends Base

	@define "type", get: -> @config.type

	constructor: (config) ->
		super config

		@models = {}

	registerModel: (model) ->
		# @debug model
		# add listeners for: statechanges: dirty, new, 

	get: ->
	find: ->
	create: ->
	delete: ->

module.exports = Store
