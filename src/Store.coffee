{Base, Collection}  = require './core'
_                   = require 'underscore'	

class Store extends Base

	@define "type", get: -> @config.type

# ---------------------------------------------------------------------------------------

	constructor: (config) ->
		super config

		@models = {}

# ---------------------------------------------------------------------------------------

	registerModel: (model) ->
		model.on 'statechange:Dirty', (model) => @onModelDirty model
		model.on 'statechange:New',   (model) => @onModelNew model

		# try to auto-generate an ID
		unless model.get 'id' then model.generateId()
		
		@models[model.id] = model

		@emit "add", model
		
	resolve: (obj, metadata, initialState=null) ->
		if _.isArray obj then return (@resolve item for item in obj)
		if obj instanceof Collection then return (@resolve item for item in obj)
		
		return obj if obj instanceof @type

		if _.isNumber obj then obj = id: Number(obj)

		if obj.id then model = @get obj.id

		if model then model.parse obj, metadata
		else
			unless initialState isnt null
				initialState = if obj.id? then "Existing" else "New"
			model = new @type data: obj, state: initialState

		model
		
	create: (data, metadata) -> @resolve data, metadata, 'New'

	get: (id) -> @models[id] or null	# returns Model (if already exists), expects id
	
	find: (query) ->	# returns Bindings or something like that

	delete: (modelOrId) ->
		model = if modelOrId instanceof @type then modelOrId else @get modelOrId
		return unless model

		delete @models[model.id]

		@emit "deleting", model

		model.dispose()

module.exports = Store
