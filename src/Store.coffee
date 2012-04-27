{Base, Collection}  = require './core'
uuid                = require 'node-uuid'
_                   = require 'underscore'	

class Store extends Base

	@define "type", get: -> @config.type

# ---------------------------------------------------------------------------------------

	constructor: (config) ->
		super config

		@models = {}

	registerModel: (model) ->
		model.on 'statechange:Dirty', (model) => @onModelDirty model
		model.on 'statechange:New',   (model) => @onModelNew model

		# try to auto-generate an ID
		unless model.id
			typeString = model.attributes['id'].typeString
			if typeString is 'String'
				model.update 'id', uuid.v1()
			else if typeString is 'Number'
				model.update 'id', _.uniqueId()
			else throw new Error "Missing id on #{model}"
		
		@models[model.id] = model

		@emit "add", model
		
	resolve: (obj) ->
		if _.isArray obj then return (@resolve item for item in obj)
		if obj instanceof Collection then return (@resolve item for item in obj)
		
		return obj if obj instanceof @type
		
		if obj.id then model = @get obj.id

		if model then model.parse obj
		else model = new @type data: obj, state: 'Existing'

		model
		
	create: (data, metadata) -> model = new @type state: 'New', data: data, metadata: metadata

	get: (id) -> @models[id] or null	# returns Model (if already exists), expects id
	
	find: (query) ->	# returns Bindings or something like that

	delete: (modelOrId) ->
		model = if modelOrId instanceof @type then modelOrId else @get modelOrId
		return unless model

		delete @models[model.id]

		@emit "deleting", model

		model.dispose()

module.exports = Store
