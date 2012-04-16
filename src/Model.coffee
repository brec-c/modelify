{Base}                        = require './core'
Store                         = require './Store'
{AttributeFactory, Attribute} = require './attributes'
TypeRegister                  = require './TypeRegister'
_                             = require 'underscore'
Stateful                      = require 'stateful'

class Model extends Base
	
	# New statechart implementation
	###
	@StateChart
		New:
			transitions: [
				destination: 'Existing'
				action: 'save'
			]
			methods: 
				save: -> Stateful.Success
				
		Existing:
			transitions: [
				destination: 'Existing/Loaded'
				action: 'parse'
			]
			methods:
				parse: -> Stateful.Success
			paths:
				Loaded:
					transitions: [
						destination: 'Existing/Loaded/Editing'
						action: 'startEdit'
					]
					methods: 
						startEdit: -> Stateful.Success
					paths:
						Editing:
							transitions: [
								{
									destination: 'Existing/Loaded'
									action: 'cancel'
								}
								{
									destination: 'Existing/Loaded/Editing/Dirty'
									action: 'save'
								}
							]
							methods:
								cancel: -> Stateful.Success
								save: -> Stateful.Success
							paths:
								Dirty:
									transitions: [
										{destination: 'Existing/Loaded',action: 'commit'}
										{destination: 'Existing/Loaded',action: 'rollback'}
									]
									methods: 
										commit: -> Stateful.Success
										rollback: -> Stateful.Success
	###
	
	
	@addState 'NEW',
		transitions :
			initial : true
			exit    : 'LOCAL, READY'
		methods     : 
			
			buildAttributes: ->
				@attributes = {}

				unless @_schema['id']?
					@_schema['id'] = kind: 'property', name: 'id', type: 'String'

				for name, config of @_schema
					console.log "building attribute for #{name}"
					Object.defineProperty this, name,
						get: -> @get(name)
						set: (value) -> @set(name, value)

					attr = AttributeFactory.createAttribute config.kind, _.extend(config, owner: @)
					@attributes[name] = attr

					attr.on "change",      => @onAttributeChange
					attr.on "stateChange", => @onAttributeStateChange
			
			# now, determine from data passed in if we're an existing model or a new local model
			parse: (obj) ->
				
					
			onAttributeChange: (attribute, newValue, oldValue, metadata) ->
				@eventBuffer = [] unless @eventBuffer
				@eventBuffer.push arguments

			onAttributeStateChange: (attr) ->
				for name, attribute of @attributes
					if attribute.require and attribute.is 'NOT_SET' then return
				@state = 'READY'
			
	@addState 'LOCAL',
		transitions :
			enter   : 'NEW'
			exit    : 'SYNCING'
			
	@addState 'READY',
		transitions :
			enter   : 'NEW,DIRTY,SYNCING,EDITING'
			exit    : 'EDITING'
			
	@addState 'DIRTY',
		transitions :
			enter   : 'EDITING,NEW'
			exit    : 'READY,SYNCING,EDITING'
			
	# @addState 'CONFLICTED',
	# 	transitions :
	# 		enter   : 'DIRTY'
	# 		exit    : 'DIRTY,READY,EDITING'
			
	@addState 'EDITING',
		transitions :
			enter   : 'READY,DIRTY'
			exit    : 'DIRTY,READY'
		methods     :
			
			set: (name, value) ->
				attribute = @attributes[name]
				attribute?.set value
				
			onChange: (changes, metadata) ->
				@eventBuffer = [] @eventBuffer unless @eventBuffer
				@eventBuffer.push arguments

			onAttributeChange: (attribute, newValue, oldValue, metadata) ->
				@eventBuffer = [] unless @eventBuffer
				@eventBuffer.push arguments

	# do we want models to be aware of this?
	@addState 'SYNCING',
		transitions :
			enter   : 'DIRTY, LOCAL'
			exit    : 'READY'
		methods     : 
			
			onAttributeChange: (attribute, newValue, oldValue, metadata) ->
				@eventBuffer = [] unless @eventBuffer
				@eventBuffer.push arguments

	@buildStateChart()

	#
	# Store proxy methods
	#
	@create : -> @store.create.apply @store, arguments
	@get    : -> @store.get.apply    @store, arguments
	@find   : -> @store.find.apply   @store, arguments
	@parse  : -> @store.parse.apply  @store, arguments


	#
	# Model declarative definitions
	#
	@_attribute: (kind, name, type, config = {}) ->
		@::_schema = {} unless @::_schema?
		@::_schema[name] = _.extend config,
			kind: kind
			name: name
			type: type
			
	@property:   (name, type, config) -> @_attribute('property',   name, type, config)
	@reference:  (name, type, config) -> @_attribute('reference',  name, type, config)
	@collection: (name, type, config) -> @_attribute('collection', name, type, config)
	
	@registerModel: (name) -> 
		@::store = new Store type:@
		TypeRegister.addModel name, @

	constructor: (data) ->
		super

		console.log "FIX ME: Need to add in parsing of data and figure out starting off State"

		@buildAttributes()
		# @parse data
		@store.registerModel @

	dispose: -> 
		super
		_.each @attributes, (attr) => attr.dispose()

	update: (name, value, metadata={}) ->
		
		updateAttribute = (attribute, value, metadata) -> attribute?.update value, metadata
		
		if _.isObject name
			metadata = value or {}
			data = name
			data = data.raw() if data instanceof Model

			changes = for name, value of data
				attribute = @attributes[name]
				updateAttribute attribute, value, metadata
		else
			attribute = @attributes[name]
			changes = [updateAttribute(attribute, value, metadata)]

		@onChange changes, metadata
	
	onChange: (changes, metadata) -> @emit 'change', changes, metadata
	
	onAttributeChange: (attribute, newValue, oldValue, metadata) ->
		changeObj =
			property: attribute.name
			newValue: newValue
			oldValue: oldValue
			metadata: metadata

		@emit "change:#{attribute.name}", changeObj
		
	get: (name) ->
		attr = @attributes[name]
		attr?.get()
		
	toString: ->
		sup = super
		if @attributes['id']?.is 'SET' then sup += "[#{@id}]"
		return sup
		
	toJSON: (attributes=@attributes)->
		values = {}
		for name,attr of @attributes
			values[attr.name] = attr.raw() unless attr.is 'NOT_SET'
		return values

module.exports = Model
