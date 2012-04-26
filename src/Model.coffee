{Base}                        = require './core'
Store                         = require './Store'
{AttributeFactory, Attribute} = require './attributes'
TypeRegister                  = require './TypeRegister'

_                             = require 'underscore'
Stateful                      = require 'stateful'

class Model extends Base
	
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
								set: (name, value) ->
									attribute = @attributes[name]
									attribute?.set value
							paths:
								Dirty:
									transitions: [
										{destination: 'Existing/Loaded',action: 'commit'}
										{destination: 'Existing/Loaded',action: 'rollback'}
									]
									methods: 
										commit: -> Stateful.Success
										rollback: -> Stateful.Success

	#
	# Store proxy methods
	#
	@create : -> @store.create.apply @store, arguments
	@resolve: -> @store.resolve.apply @store, arguments

	@get    : -> @store.get.apply    @store, arguments
	@find   : -> @store.find.apply   @store, arguments

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

	constructor: (config) ->
		super

		throw new Error "Must use defined methods for creating new models." unless @config.state?

		console.log "TODO: add ability to initialize to state to Stateful"
		# @initState @config.state

		@buildAttributes()

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
