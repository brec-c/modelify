{Base} = require './core'
uuid   = require 'node-uuid'
_      = require 'underscore'

class Store extends Base

	@define "type", get: -> @config.type

	constructor: (config) ->
		super config

		@models = {}

	registerModel: (model) ->
		model.on 'statechange:DIRTY', (model) => @onModelDirty model
		model.on 'statechange:NEW',   (model) => @onModelNew model

		# try to auto-generate an ID
		unless model.id
			typeString = model.attributes['id'].typeString
			if typeString is 'String'
				model.update 'id', uuid.v1()
			else if typeString is 'Number'
				model.update 'id', _.uniqueId()
			else throw new Error "Missing id on #{model}"
		
		@models[model.id] = model

	get: ->
	find: ->
	create: ->
	delete: ->

module.exports = Store
