{Base, Collection}  = require './core'
uuid                = require 'node-uuid'
_                   = require 'underscore'	

class Store extends Base

	@define "type", get: -> @config.type

	constructor: (config) ->
		super config

		@models = {}

	registerModel: (model) ->                        # Called by the Model that was just created.
		
		model.on 'statechange:DIRTY', (model) => @onModelDirty model
		model.on 'statechange:LOCAL',   (model) => @onModelLocal model

		# try to auto-generate an ID
		unless model.id
			typeString = model.attributes['id'].typeString
			if typeString is 'String'
				model.update 'id', uuid.v1()
			else if typeString is 'Number'
				model.update 'id', _.uniqueId()
			else throw new Error "Missing id on #{model}"
		
		@models[model.id] = model
		
	resolve: (obj) ->
		if _.isArray obj then return (@resolve item for item in obj)
		if obj instanceof Collection then return (@resolve item for item in obj)
		
		return obj if obj instanceof @type
		
		@parse obj
		
	parse: (obj) ->
		if obj.id then model = @get obj.id

		if model then model.update obj
		else model = new @type obj

		model

	create: (data) -> 

	get: (id) -> @models[id] or null	# returns Model (if already exists), expects id
	
	find: ->	# returns Bindings or something like that
		
	delete: ->  # if doesn't exist yet

module.exports = Store
