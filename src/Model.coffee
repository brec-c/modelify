{Base}                        = require './core'
Store                         = require './Store'
{AttributeFactory, Attribute} = require './attributes'
TypeRegister                  = require './TypeRegister'

_                             = require 'underscore'
uuid                          = require 'node-uuid'
Stateful                      = require 'stateful'

class Model extends Base

# ---------------------------------------------------------------------------------------

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
				destination: 'Loaded'
				action: 'parse'
			]
			methods:
				parse: -> @super_parse.apply @, arguments
			paths:
				Loaded:
					transitions: [
						destination: 'Editing'
						action: 'startEdit'
					]
					methods: 
						startEdit: -> Stateful.Success
					paths:
						Editing:
							transitions: [
								{ destination: 'Existing/Loaded', action: 'cancel' }
								{ destination: 'Dirty', action: 'save' }
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
										{ destination: 'Existing/Loaded',action: 'commit' }
										{ destination: 'Existing/Loaded',action: 'rollback' }
									]
									methods: 
										commit: -> Stateful.Success
										rollback: -> Stateful.Success

# ---------------------------------------------------------------------------------------

	#
	# Store proxy methods
	#
	@create : -> @::store.create.apply  @::store, arguments
	@resolve: -> @::store.resolve.apply @::store, arguments
	@get    : -> @::store.get.apply     @::store, arguments
	@find   : -> @::store.find.apply    @::store, arguments
	@delete : -> @::store.delete.apply  @::store, arguments

# ---------------------------------------------------------------------------------------

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
		@::store = new Store type: @
		TypeRegister.addModel name, @

# ---------------------------------------------------------------------------------------

	constructor: (config) ->
		super

		throw new Error "Must use defined methods for creating new models." unless @config.state?

		@state = @config.state

		@buildAttributes()
		@parse config.data, config.metadata

		@store.registerModel @

	buildAttributes: ->
		@attributes = {}

		console.log "Building Model: #{@constructor.name}"

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

	generateId: ->
		typeString = @attributes['id'].typeString

		if      typeString is 'String' then @updateAttribute 'id', uuid.v1()
		else if typeString is 'Number' then @updateAttribute 'id', _.uniqueId()
		else throw new Error "Missing id on #{@}"

	parse: (jsonObj, metadata) ->
		changes = for name, value of jsonObj
			attribute = @attributes[name]
			@updateAttribute attribute, value, metadata

		changes = _.reject changes, (item) -> not item?

		@onChange changes, metadata

	updateAttribute: (nameOrAttribute, value, metadata) ->
		if typeof nameOrAttribute is 'string'
			attribute = @attributes[nameOrAttribute]
		else if nameOrAttribute instanceof Attribute
			attribute = nameOrAttribute
		else
			throw new Error "Missing attribute: #{nameOrAttribute} from #{_.keys @attributes}"

		console.log "- updating #{attribute.name} to #{value}"
		attribute.update value, metadata
	
	onChange: (changes, metadata) -> @emit 'change', changes, metadata
	
	onAttributeChange: (attribute, newValue, oldValue, metadata) ->
		changeObj =
			property: attribute.name
			newValue: newValue
			oldValue: oldValue
			metadata: metadata

		@emit "change:#{attribute.name}", changeObj

	get: (name) -> @attributes[name]?.get()
		
	toString: ->
		sup = super
		if @attributes['id']?.is 'Loaded' then sup += "[#{@id}]"
		return sup
		
	toJSON: ->
		values = {}
		for name,attr of @attributes
			values[attr.name] = attr.raw()
		return values

module.exports = Model
